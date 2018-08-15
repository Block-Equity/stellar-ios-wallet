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
    typealias AuthenticationOptions = (cancellable: Bool, presentVC: Bool, forcedStyle: AuthenticationStyle?)

    /// Errors relating to authenticating the user.
    ///
    /// - pinMismatchError: The pin didn't matched the stored value.
    /// - pinUnsetError: There was no pin set.
    /// - biometricLockout: The user is locked out from using biometric authentication.
    /// - biometricAuthenticationError: The user failed biometric authentication multiple times.
    /// - biometryUnavailable: Biometric authentication isn't available (likely denied prompt)
    /// - biometryNotEnrolled: Biometric authentication isn't set up
    /// - biometryCancelled: The system, user, or application cancelled an authentication request.
    /// - biometryFallback: The app should revert to using app-specific pin entry for authentication.
    /// - unknown: ¯\_(ツ)_/¯
    enum AuthenticationError: LocalizedError {
        case pinMismatchError
        case pinUnsetError
        case biometricLockout
        case biometricAuthenticationError
        case biometryUnavailable
        case biometryNotEnrolled
        case biometryCancelled
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

    /// The authentication context used for biometric authorization
    private let authContext: LAContext

    /// The authentication policy to use in LocalAuthentication
    private static let authPolicy = LAPolicy.deviceOwnerAuthenticationWithBiometrics

    /// The view controller to display when using pin entry
    private var pinViewController: PinViewController?

    /// The view controller to display when using biometric authentication
    private var blankAuthController: AuthenticationViewController?

    /// A container that the authentication view controllres may be added to
    private var container: UIViewController

    /// The authentication operation mode for the coordinator
    private var mode: AuthenticationMode = .challenge

    /// Internal state to determine if a second pin view controller should be displayed
    private var confirmPin: Bool = false

    /// Options that this authentication coordinator is configured with.
    private var options: AuthenticationOptions = (cancellable: false, presentVC: false, forcedStyle: nil)

    /// Internal state to track the pin the user entered, when first creating a pin code
    private var firstPin: String?

    /// The last `UIViewController` visible before presenting the authentication view controllers
    private weak var previousViewController: UIViewController?

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

        guard SecurityOptionHelper.check(.pinEnabled) && KeychainHelper.hasPin() else {
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
    static func biometricsAvailable() -> Bool {
        let policy = AuthenticationCoordinator.authPolicy
        let context = LAContext()
        let available = AuthenticationCoordinator.evaluateLAPolicy(policy, context: context) == nil
        context.invalidate()

        return available
    }
}

// MARK: - Private / internal methods
extension AuthenticationCoordinator {
    private func presentAuthenticationChallenge() {
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
        let authVC = AuthenticationViewController()
        blankAuthController = authVC

        pushPresentOrMove(authVC, on: container, animated: false)
        biometricChallenge()
    }

    private func presentPinAuth() {
        let pinVC = PinViewController(mode: .dark, creating: false, isCloseDisplayed: options.cancellable)
        pinVC.delegate = self
        pinViewController = pinVC

        pushPresentOrMove(pinVC, on: container, animated: false)
    }

    private func setNewAuthenticationPin() {
        confirmPin = true

        let pinVC = PinViewController(mode: .light, creating: confirmPin, isCloseDisplayed: false)
        pinVC.delegate = self
        pinViewController = pinVC

        pushPresentOrMove(pinVC, on: container, animated: true)
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
        switch (error) {
        case LAError.appCancel: return .biometryCancelled
        case LAError.userCancel: return .biometryCancelled
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
                    self.removeAuthenticationView(with: context,
                                                  viewController: self.blankAuthController) { [unowned self] ctxt in
                        self.delegate?.authenticationCompleted(self, options: ctxt)
                    }
                } else {
                    let authError = AuthenticationCoordinator.convertLocalAuthenticationError(error as? LAError)
                    let context = AuthenticationContext(savedPin: false, mode: .biometric, cancelled: authError == .biometryCancelled)

                    os_log("ERROR: %@", authError?.localizedDescription ?? "")

                    // If cancelled or fallback, we need to present the pin entry flow before removing auth views
                    if authError == .biometryCancelled || authError == .biometryFallback {
                        self.options.forcedStyle = .pin
                        self.removeAuthenticationView(with: context, viewController: self.blankAuthController) { _ in
                            self.authenticate()
                        }
                    } else {
                        self.removeAuthenticationView(with: context,
                                                      viewController: self.blankAuthController) { [unowned self] ctxt in
                            self.delegate?.authenticationFailed(self, error: authError, options: ctxt)
                        }
                    }
                }
            }
        }
    }

    private func pushPresentOrMove(_ vc: UIViewController, on container: UIViewController, animated: Bool = false) {
        previousViewController = container.childViewControllers.last

        if let navController = container as? UINavigationController {
            navController.pushViewController(vc, animated: animated)
        } else if options.presentVC {
            container.present(vc, animated: true, completion: nil)
        } else {
            container.moveToViewController(vc,
                                           fromViewController: previousViewController,
                                           animated: animated, completion: nil)
        }
    }

    private func removeAuthenticationView(with context: AuthenticationContext,
                                          viewController: UIViewController?,
                                          completion: AuthenticationCompletion? = nil) {
        if container is UINavigationController {
            completion?(context)
        } else if let vc = viewController, options.presentVC {
            vc.dismiss(animated: true) {
                completion?(context)
            }
        } else if let vc = viewController, let previousVC = previousViewController {
            container.moveToViewController(previousVC, fromViewController: vc, animated: false, completion: nil)
            completion?(context)
        } else {
            completion?(context)
        }
    }
}

extension AuthenticationCoordinator: PinViewControllerDelegate {
    func pinEntryCompleted(_ vc: PinViewController, pin: String) {
        if mode == .setPin && confirmPin {
            let pinVC = PinViewController(mode: .light, creating: false, isCloseDisplayed: false)
            pinVC.delegate = self

            pinViewController = pinVC
            confirmPin = false
            firstPin = pin

            pushPresentOrMove(pinVC, on: container, animated: true)
        } else if mode == .setPin && !confirmPin {
            if KeychainHelper.check(pin: pin, comparePin: firstPin) {
                firstPin = nil
                KeychainHelper.save(pin: pin)
                SecurityOptionHelper.clear()

                let context = AuthenticationContext(savedPin: false, mode: .pin, cancelled: false)
                self.removeAuthenticationView(with: context, viewController: vc) { [unowned self] ctxt in
                    self.delegate?.authenticationCompleted(self, options: ctxt)
                }
            } else {
                os_log("ERROR: %@", AuthenticationError.pinMismatchError.localizedDescription)
                vc.pinMismatchError()
            }
        } else {
            if KeychainHelper.check(pin: pin) {
                let context = AuthenticationContext(savedPin: false, mode: .pin, cancelled: false)
                self.removeAuthenticationView(with: context, viewController: vc) { [unowned self] ctxt in
                    self.delegate?.authenticationCompleted(self, options: ctxt)
                }
            } else {
                os_log("ERROR: %@", AuthenticationError.pinMismatchError.localizedDescription)
                vc.pinMismatchError()
            }
        }
    }

    func pinEntryCancelled(_ vc: PinViewController) {
        let context = AuthenticationContext(savedPin: false, mode: .pin, cancelled: true)
        self.removeAuthenticationView(with: context, viewController: vc) { [unowned self] ctxt in
            self.delegate?.authenticationCancelled(self, options: ctxt)
        }
    }
}

extension AuthenticationCoordinator.AuthenticationError {
    var localizedDescription: String {
        switch self {
        case .pinMismatchError: return "Pin mismatched keychain value."
        case .pinUnsetError: return "User does not have pin code set."
        case .biometricLockout: return "User is locked out from local authentication."
        case .biometricAuthenticationError: return "Authentication failed after numerous attempts."
        case .biometryUnavailable: return "Biometric authentication is unavailable."
        case .biometryNotEnrolled: return "User is not entrolled for biometric authentication."
        case .biometryCancelled: return "Biometric authentication was cancelled."
        case .biometryFallback: return "Fallback to password authentication requested."
        case .unknown: return "Unknown error!"
        }
    }
}
