//
//  AuthenticationCoordinator.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-08-11.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Foundation
import LocalAuthentication
import os.log

//swiftlint:disable file_length
protocol AuthenticationCoordinatorDelegate: AnyObject {
    /// Called when the coordinator is successful in validating the user's identity.
    ///
    /// - Parameters:
    ///   - coordinator: The coordinator used to validate the user's authentication method.
    ///   - options: Context object containing information about how the validation was processed.
    func authenticationCompleted(_ coordinator: AuthenticationCoordinator,
                                 options: AuthenticationCoordinator.AuthenticationContext?)

    /// Called when the authentication process is cancelled before completing successfully.
    ///
    /// - Parameter coordinator: The coordinator used to validate the user's authentication method.
    func authenticationCancelled(_ coordinator: AuthenticationCoordinator,
                                 options: AuthenticationCoordinator.AuthenticationContext)

    /// Called when the coordinator fails to successfully validate the desired authentication method.
    ///
    /// - Parameters:
    ///   - coordinator: The coordinator used to validate the user's authentication method.
    ///   - error: The error encountered during the authentication process.
    func authenticationFailed(_ coordinator: AuthenticationCoordinator,
                              error: AuthenticationCoordinator.AuthenticationError?,
                              options: AuthenticationCoordinator.AuthenticationContext)
}

/**
 The `AuthenticationCoordinator` is responsibile for the validation of the user's pin (or biometric authentication) and
 management of the view hierarchy supporting that.
 
 The intended use for the `AuthenticationCoordinator` is that it be instantiated every time you wish to validate the
 user's pin / biometric authentication.
 */
final class AuthenticationCoordinator {
    /// A context object that the delegate can use to gain information about how user authentication was processed.
    struct AuthenticationContext {
        var savedPin: Bool = false
        var mode: AuthenticationStyle = .pin
        var cancelled: Bool = false
    }

    /// A typealias for the callback used when finalizing authentication.
    typealias AuthenticationCompletion = (AuthenticationContext) -> Void

    /// A typealias for options that may be passed into the authentication coordinator.
    typealias AuthenticationOptions = (cancellable: Bool,
        presentVC: Bool,
        forcedStyle: AuthenticationStyle?,
        limitPinEntries: Bool)

    /// Errors relating to authenticating the user.
    ///
    /// - pinMismatchError: The pin didn't matched the stored value.
    /// - pinUnsetError: There was no pin set.
    /// - biometricLockout: The user is locked out from using biometric authentication.
    /// - biometricAuthenticationError: The user failed biometric authentication multiple times.
    /// - biometryUnavailable: Biometric authentication isn't available (likely denied prompt)
    /// - biometryNotEnrolled: Biometric authentication isn't set up
    /// - biometryCancelled: The system, or application cancelled an authentication request.
    /// - biometryUserCancelled: The user cancelled an authentication request.
    /// - biometryFallback: The app should revert to using app-specific pin entry for authentication.
    /// - unknown: ¯\_(ツ)_/¯
    enum AuthenticationError: LocalizedError {
        case pinMismatchError
        case pinUnsetError
        case pinMaxAttemptsError
        case biometricLockout
        case biometricAuthenticationError
        case biometryUnavailable
        case biometryNotEnrolled
        case biometryCancelled
        case biometryUserCancelled
        case biometryFallback
        case unknown
    }

    /// The style of authentication the coordinator should check.
    ///
    /// - pin: Use PIN-based authentication
    /// - biometric: FaceID / TouchID
    enum AuthenticationStyle {
        case pin
        case biometric
    }

    /// The mode the authentication coordinator should operate in.
    ///
    /// - challenge: The coordinator should only check an already existing pin.
    /// - setPin: The coordinator should set a new pin for the user.
    enum AuthenticationMode {
        case challenge
        case setPin
    }

    // The maximum number of allowed pin entries before failing
    private static let maximumFailedPinAttempts: Int = 3

    /// The authentication policy to use in LocalAuthentication
    private static let authPolicy = LAPolicy.deviceOwnerAuthenticationWithBiometrics

    /// The authentication context used for biometric authorization
    private let authContext: LAContext

    /// The view controller to display when using pin entry
    private lazy var pinViewController: PinViewController = {
        let pinVC = PinViewController()
        _ = pinVC.view
        pinVC.delegate = self

        return pinVC
    }()

    /// The view controller to display when using pin entry
    private lazy var confirmPinViewController: PinViewController = {
        let pinVC = PinViewController()
        _ = pinVC.view
        pinVC.delegate = self

        return pinVC
    }()

    /// The view controller to display when using biometric authentication
    private lazy var blankAuthController: BlankAuthenticationViewController = {
        let authVC = BlankAuthenticationViewController()
        _ = authVC.view
        authVC.delegate = self

        return authVC
    }()

    /// A container that the authentication view controllres may be added to
    private var container: UIViewController

    /// The authentication operation mode for the coordinator
    private var mode: AuthenticationMode = .challenge

    /// Internal state to determine if a second pin view controller should be displayed
    private var confirmPin: Bool = false

    /// Options that this authentication coordinator is configured with.
    private var options: AuthenticationOptions = (cancellable: false,
                                                  presentVC: false,
                                                  forcedStyle: nil,
                                                  limitPinEntries: true)

    /// Internal state to track the pin the user entered, when first creating a pin code
    private var firstPin: String?

    /// Internal state to track the number of failed pin attempts
    private var failedPinAttempts: Int = 0

    /// The class to notify of authentication events
    weak var delegate: AuthenticationCoordinatorDelegate?

    /// Initializer for an authentication coordinator that manages the UI and validation of credentials.
    ///
    /// - Parameters:
    ///   - container: A `UIViewController` that will be used to contain a hierarchy of authentication view controllers.
    ///   - present: A flag indicating if the coordinator should present on the container instead of transitioning.
    ///   - force: The mode in which the coordinator should operate, either pin entry, or biometric.
    init(container: UIViewController, options: AuthenticationOptions) {
        self.container = container
        self.options = options
        authContext = LAContext()
    }

    /// The authenticate method begins the authentication process for the user's pin, or biometric identity.
    func authenticate() {
        mode = .challenge

        guard SecurityOptionHelper.check(.pinEnabled) && KeychainHelper.hasPin else {
            os_log("WARNING: %@", AuthenticationError.pinUnsetError.localizedDescription)
            return
        }

        presentAuthenticationChallenge()
    }

    /// This method is responsible for starting the pin creation process.
    func createPinAuthentication() {
        mode = .setPin
        setNewAuthenticationPin()
    }

    /// Used to determine if biometric authentication is available (FaceID / TouchID).
    ///
    /// - Returns: True if FaceID / TouchID are currently available, or false otherwise.
    static var biometricsAvailable: Bool {
        let policy = AuthenticationCoordinator.authPolicy
        let context = LAContext()
        let available = AuthenticationCoordinator.evaluateLAPolicy(policy, context: context) == nil

        return available
    }

    deinit {
        self.failedPinAttempts = 0
        removeAuthentication(viewController: blankAuthController,
                             with: AuthenticationContext(savedPin: false, mode: .pin, cancelled: false))
        removeAuthentication(viewController: pinViewController,
                             with: AuthenticationContext(savedPin: false, mode: .biometric, cancelled: false))
    }
}

// MARK: - Private / internal methods
extension AuthenticationCoordinator {
    private func presentAuthenticationChallenge() {

        dismissApplicationKeyboard()

        var useBiometrics = SecurityOptionHelper.check(.useBiometrics)
        let biometricsAvailable = AuthenticationCoordinator.evaluateLAPolicy(AuthenticationCoordinator.authPolicy,
                                                                             context: self.authContext) == nil

        if let mode = options.forcedStyle, mode == .pin {
            useBiometrics = false
        }

        if biometricsAvailable && useBiometrics {
            presentBiometricAuth()
        } else {
            presentPinAuth()
        }
    }

    private func presentBiometricAuth() {
        pushPresentOrMove(blankAuthController, on: container, animated: false)
        biometricChallenge()
    }

    private func presentPinAuth() {
        pinViewController.update(with: PinViewController.ViewModel(isCreating: false,
                                                                   isCloseDisplayed: options.cancellable,
                                                                   mode: .dark))

        pushPresentOrMove(pinViewController, on: container, animated: false)
    }

    private func setNewAuthenticationPin() {
        confirmPin = true

        pinViewController.update(with: PinViewController.ViewModel(isCreating: confirmPin,
                                                                   isCloseDisplayed: false,
                                                                   mode: .light))

        pushPresentOrMove(pinViewController, on: container, animated: true)
    }

    private static func evaluateLAPolicy(_ policy: LAPolicy, context: LAContext) -> AuthenticationError? {
        var error: NSError?

        guard context.canEvaluatePolicy(policy, error: &error) else {
            return convertLocalAuthenticationError(LAError(_nsError: error!))
        }

        return nil
    }

    private static func convertLocalAuthenticationError(_ error: LAError?) -> AuthenticationError? {
        guard let error = error else { return nil }
        switch error {
        case LAError.appCancel: return .biometryCancelled
        case LAError.userCancel: return .biometryUserCancelled
        case LAError.systemCancel: return .biometryCancelled
        case LAError.userFallback: return .biometryFallback
        case LAError.authenticationFailed: return .biometricAuthenticationError
        case LAError.biometryLockout: return .biometricLockout
        case LAError.biometryNotAvailable: return .biometryUnavailable
        case LAError.biometryNotEnrolled: return .biometryNotEnrolled
        default: return .unknown
        }
    }

    private func biometricChallenge() {
        let reasonString = "BIOMETRIC_AUTH_TITLE".localized()
        let policy = AuthenticationCoordinator.authPolicy
        authContext.evaluatePolicy(policy, localizedReason: reasonString) { [unowned self] success, error in
            DispatchQueue.main.async {
                if success {
                    let context = AuthenticationContext(savedPin: false, mode: .biometric, cancelled: false)
                    self.removeAuthentication(viewController: self.blankAuthController,
                                              with: context) { [unowned self] ctxt in
                        self.delegate?.authenticationCompleted(self, options: ctxt)
                    }
                } else {
                    let authError = AuthenticationCoordinator.convertLocalAuthenticationError(error as? LAError)
                    let cancelled = authError == .biometryCancelled || authError == .biometryUserCancelled
                    let context = AuthenticationContext(savedPin: false, mode: .biometric, cancelled: cancelled)

                    os_log("ERROR: %@", authError?.localizedDescription ?? "")

                    // If cancelled or fallback, we need to present the pin entry flow before removing auth views
                    if authError == .biometryFallback {
                        self.options.forcedStyle = .pin
                        self.removeAuthentication(viewController: self.blankAuthController,
                                                  with: context,
                                                  animated: false, completion: nil)
                        self.authenticate()
                    } else if authError == .biometryUserCancelled || authError == .biometryCancelled {
                        self.blankAuthController.displayAuthButton()
                        self.delegate?.authenticationCancelled(self, options: context)
                    } else {
                        self.removeAuthentication(viewController: self.blankAuthController,
                                                  with: context) { [unowned self] ctxt in
                            self.delegate?.authenticationFailed(self, error: authError, options: ctxt)
                        }
                    }
                }
            }
        }
    }

    private func pushPresentOrMove(_ viewController: UIViewController,
                                   on container: UIViewController,
                                   animated: Bool = false) {
        if options.presentVC {
            container.present(viewController, animated: true, completion: nil)
        } else if let navController = container as? UINavigationController {
            navController.pushViewController(viewController, animated: animated)
        } else {
            container.moveToViewController(viewController, fromViewController: nil, animated: animated, completion: nil)
        }
    }

    private func removeAuthentication(viewController: UIViewController?,
                                      with context: AuthenticationContext,
                                      animated: Bool = true,
                                      completion: AuthenticationCompletion? = nil) {
        if let viewController = viewController as? AuthenticatingViewController {
            viewController.dismissAuthentication(animated: animated) {
                completion?(context)
            }
        } else {
            os_log("ERROR: %@", "Unknown view controller specified for removal!")
            completion?(context)
        }

        container.setNeedsStatusBarAppearanceUpdate()
    }

    private func dismissApplicationKeyboard() {
        UIApplication.shared.keyWindow?.rootViewController?.view.endEditing(true)
    }
}

extension AuthenticationCoordinator: PinViewControllerDelegate {
    func pinEntryCompleted(_ viewController: PinViewController, pin: String) {
        if mode == .setPin && confirmPin {
            confirmPinViewController.update(with: PinViewController.ViewModel(isCreating: false,
                                                                              isCloseDisplayed: false,
                                                                              mode: .light))

            confirmPin = false
            firstPin = pin

            pushPresentOrMove(confirmPinViewController, on: container, animated: true)
        } else if mode == .setPin && !confirmPin {
            if KeychainHelper.check(pin: pin, comparePin: firstPin) {
                firstPin = nil
                KeychainHelper.save(pin: pin)
                SecurityOptionHelper.clear()

                let context = AuthenticationContext(savedPin: false, mode: .pin, cancelled: false)
                self.removeAuthentication(viewController: viewController, with: context) { [unowned self] ctxt in
                    self.delegate?.authenticationCompleted(self, options: ctxt)
                }
            } else {
                failedPinAttempt(viewController: viewController)
            }
        } else {
            if KeychainHelper.check(pin: pin) {
                let context = AuthenticationContext(savedPin: false, mode: .pin, cancelled: false)
                self.removeAuthentication(viewController: viewController, with: context) { [unowned self] ctxt in
                    self.delegate?.authenticationCompleted(self, options: ctxt)
                }
            } else {
                failedPinAttempt(viewController: viewController)
            }
        }
    }

    func pinEntryCancelled(_ viewController: PinViewController) {
        let context = AuthenticationContext(savedPin: false, mode: .pin, cancelled: true)
        self.removeAuthentication(viewController: viewController, with: context) { [unowned self] ctxt in
            self.delegate?.authenticationCancelled(self, options: ctxt)
        }
    }

    private func failedPinAttempt(viewController: PinViewController) {
        failedPinAttempts += 1
        viewController.pinMismatchError()
        os_log("ERROR: %@, attempts: %d",
               AuthenticationError.pinMismatchError.localizedDescription,
               failedPinAttempts)

        guard options.limitPinEntries else { return }

        if failedPinAttempts >= AuthenticationCoordinator.maximumFailedPinAttempts {
            let context = AuthenticationContext(savedPin: false, mode: .pin, cancelled: false)
            self.delegate?.authenticationFailed(self, error: AuthenticationError.pinMaxAttemptsError, options: context)
        }
    }
}

extension AuthenticationCoordinator: BlankAuthenticationViewControllerDelegate {
    func authenticate(_ viewController: BlankAuthenticationViewController) {
        self.authenticate()
    }
}

extension AuthenticationCoordinator.AuthenticationError {
    var localizedDescription: String {
        switch self {
        case .pinMismatchError: return "Pin mismatched keychain value."
        case .pinUnsetError: return "User does not have pin code set."
        case .pinMaxAttemptsError: return "User has reached the maximum number of PIN attempts."
        case .biometricLockout: return "User is locked out from local authentication."
        case .biometricAuthenticationError: return "Authentication failed after numerous attempts."
        case .biometryUnavailable: return "Biometric authentication is unavailable."
        case .biometryNotEnrolled: return "User is not entrolled for biometric authentication."
        case .biometryCancelled: return "Biometric authentication was cancelled."
        case .biometryUserCancelled: return "Biometric authentication was cancelled by the user."
        case .biometryFallback: return "Fallback to password authentication requested."
        case .unknown: return "Unknown error!"
        }
    }
}
//swiftlint:enable file_length
