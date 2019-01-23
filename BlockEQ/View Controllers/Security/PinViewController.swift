//
//  PinViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-03-09.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import UIKit
import Foundation

protocol PinViewControllerDelegate: class {
    func pinEntryCompleted(_ viewController: PinViewController, pin: String)
    func pinEntryCancelled(_ viewController: PinViewController)
}

class PinViewController: UIViewController {
    enum DisplayMode {
        case light
        case dark
    }

    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet var pinViewHolder: UIView!
    @IBOutlet var pinView1: PinDotView!
    @IBOutlet var pinView2: PinDotView!
    @IBOutlet var pinView3: PinDotView!
    @IBOutlet var pinView4: PinDotView!
    @IBOutlet weak var keyboardView: KeyboardView!

    static let pinCheckDelay = 0.5
    static let pinLength = 4

    var pinViews: [PinDotView] = []
    var pin: String = ""
    var isCreating: Bool = false
    var isCloseDisplayed: Bool = false
    var mode: DisplayMode = .light

    let notificationGenerator = UINotificationFeedbackGenerator()
    let impactGenerator = UIImpactFeedbackGenerator(style: .light)

    weak var delegate: PinViewControllerDelegate?

    override var preferredStatusBarStyle: UIStatusBarStyle {
        if mode == .dark { return .lightContent }
        return .default
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        keyboardView.isUserInteractionEnabled = true
        impactGenerator.prepare()

        var pinDotColor: UIColor
        var pinLineColor: UIColor
        var keyboardTextColor: UIColor

        if self.mode == .dark {
            keyboardTextColor = .white
            pinLineColor = Colors.white
            pinDotColor = Colors.white
        } else {
            keyboardTextColor = Colors.primaryDark
            pinLineColor = Colors.primaryDark
            pinDotColor = Colors.primaryDark
        }

        let kbButtons = isCloseDisplayed ? KeyboardHelper.cancelKeypadButtons : KeyboardHelper.basicKeypadButtons
        keyboardView.update(with: KeyboardViewModel(options: KeyboardOptions.all,
                                                    buttons: kbButtons,
                                                    bottomLeftImage: nil,
                                                    bottomRightImage: UIImage(named: "backspace"),
                                                    labelColor: keyboardTextColor,
                                                    buttonColor: keyboardTextColor,
                                                    backgroundColor: .clear))

        pinViews = [pinView1, pinView2, pinView3, pinView4]

        let viewModel = PinDotViewModel(circleDiameter: 15,
                                        lineHeight: 2,
                                        lineColor: pinLineColor,
                                        dotColor: pinDotColor,
                                        shakeColor: Colors.red,
                                        shakeOffset: 30)

        for pinView in pinViews {
            pinView.update(with: viewModel)
            pinView.reset()
        }

        setNeedsStatusBarAppearanceUpdate()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        pin = ""
    }

    func setupView() {
        logoImageView.image = UIImage(named: "logo")

        if isCloseDisplayed {
            let leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "close"),
                                                    style: .plain,
                                                    target: self,
                                                    action: #selector(self.dismissView))
            navigationItem.leftBarButtonItem = leftBarButtonItem
        } else {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "CANCEL_ACTION".localized(),
                                                               style: .plain,
                                                               target: self,
                                                               action: #selector(self.popView))
        }

        keyboardView.delegate = self
    }

    func update(with viewModel: ViewModel) {
        self.mode = viewModel.mode
        self.isCreating = viewModel.isCreating
        self.isCloseDisplayed = viewModel.isCloseDisplayed

        if self.mode == .dark {
            pinViewHolder.backgroundColor = Colors.backgroundDark
            view.backgroundColor = Colors.backgroundDark
            titleLabel.textColor = Colors.white
        } else {
            pinViewHolder.backgroundColor = .white
            view.backgroundColor = .white
            titleLabel.textColor = Colors.primaryDark
        }

        var longTitle: String
        var shortTitle: String

        if isCreating {
            longTitle = "PIN_CREATE_TITLE".localized()
            shortTitle = "PIN_CREATE_SHORT".localized()
        } else {
            longTitle = "PIN_ENTER_TITLE".localized()
            shortTitle = "PIN_CONFIRM_SHORT".localized()
        }

        titleLabel.text = longTitle
        title = shortTitle
        navigationItem.title = shortTitle
    }

    @objc func dismissView() {
        view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }

    @objc func popView() {
        view.endEditing(true)
        navigationController?.popToRootViewController(animated: true)
    }

    func pinMismatchError() {
        pin = ""

        // Haptic feedback for failing to enter pin correctly
        notificationGenerator.notificationOccurred(.error)

        for pinView in pinViews {
            pinView.shake {
                pinView.animateToLine()
                self.keyboardView.isUserInteractionEnabled = true
            }
        }
    }
}

extension PinViewController {
    struct ViewModel {
        var isCreating: Bool
        var isCloseDisplayed: Bool
        var mode: DisplayMode
    }
}

extension PinViewController: KeyboardViewDelegate {
    func selected(key: KeyboardButton, action: UIEvent) {

        // Light haptic feedback for pressing a keyboard key
        impactGenerator.impactOccurred()

        switch key {
        case .number(let num):
            guard pin.count < PinViewController.pinLength else { return }
            pin += String(num)
        case .right:
            guard pin.count > 0 else { return }
            let index = pin.index(pin.startIndex, offsetBy: pin.count-1)
            pin = String(pin[..<index])
        case .left where self.isCloseDisplayed == true:
            delegate?.pinEntryCancelled(self)
        default:
            print("Unhandled button")
        }

        for (index, pinView) in pinViews.enumerated() {
            index < pin.count ? pinView.animateToCircle() : pinView.animateToLine()
        }

        if pin.count == PinViewController.pinLength {
            keyboardView.isUserInteractionEnabled = false
            notificationGenerator.prepare()

            DispatchQueue.main.asyncAfter(deadline: .now() + PinViewController.pinCheckDelay) {
                self.delegate?.pinEntryCompleted(self, pin: self.pin)
            }
        }
    }
}

extension PinViewController: AuthenticatingViewController { }
