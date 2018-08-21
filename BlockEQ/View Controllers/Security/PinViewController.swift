//
//  PinViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-03-09.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import UIKit
import Foundation

protocol PinViewControllerDelegate: class {
    func pinEntryCompleted(_ vc: PinViewController, pin: String)
    func pinEntryCancelled(_ vc: PinViewController)
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

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init(mode: DisplayMode, creating: Bool, isCloseDisplayed: Bool) {
        super.init(nibName: String(describing: PinViewController.self), bundle: nil)
        self.pin = ""
        self.isCreating = creating
        self.isCloseDisplayed = isCloseDisplayed
        self.mode = mode
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

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
    }

    func setupView() {
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

        logoImageView.image = UIImage(named: "logo")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)

        if isCloseDisplayed {
            let image = UIImage(named: "close")
            let leftBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(self.dismissView))
            navigationItem.leftBarButtonItem = leftBarButtonItem
        }

        keyboardView.delegate = self
    }

    @objc func dismissView() {
        view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }

    func pinMismatchError() {
        pin = ""

        // Haptic feedback for failing to enter pin correctly
        notificationGenerator.notificationOccurred(.error)

        for pinView in pinViews {
            pinView.shake {
                pinView.animateToLine()
            }
        }
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
            notificationGenerator.prepare()

            DispatchQueue.main.asyncAfter(deadline: .now() + PinViewController.pinCheckDelay) {
                self.delegate?.pinEntryCompleted(self, pin: self.pin)
            }
        }
    }
}

extension PinViewController: AuthenticatingViewController { }
