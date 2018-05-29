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
    func pinEntryCompleted(_ vc: PinViewController, pin: String, save: Bool)
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

    var pinViews: [PinDotView]!
    var pin: String = ""
    var isConfirming: Bool = false
    var isCloseDisplayed: Bool = false
    var shouldSavePin: Bool = false
    var mode: DisplayMode = .light

    let notificationGenerator = UINotificationFeedbackGenerator()
    let impactGenerator = UIImpactFeedbackGenerator(style: .light)
    
    weak var delegate: PinViewControllerDelegate?

    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(mode: DisplayMode, pin: String?, confirming: Bool, isCloseDisplayed: Bool, shouldSavePin: Bool) {
        super.init(nibName: String(describing: PinViewController.self), bundle: nil)
        self.pin = pin ?? ""
        self.isConfirming = confirming
        self.isCloseDisplayed = isCloseDisplayed
        self.shouldSavePin = shouldSavePin
        self.mode = mode
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        impactGenerator.prepare()
    }

    func setupView() {
        keyboardView.delegate = self

        var pinDotColor: UIColor
        var pinLineColor: UIColor
        var keyboardTextColor: UIColor

        if self.mode == .dark {
            pinViewHolder.backgroundColor = Colors.primaryDark
            view.backgroundColor = Colors.primaryDark
            keyboardTextColor = .white
            pinLineColor = Colors.white
            pinDotColor = Colors.tertiaryDark
            titleLabel.textColor = Colors.white
        } else {
            pinViewHolder.backgroundColor = .white
            view.backgroundColor = .white
            keyboardTextColor = Colors.primaryDark
            pinLineColor = Colors.darkGray
            pinDotColor = Colors.primaryDark
            titleLabel.textColor = Colors.primaryDark
        }

        keyboardView.update(with: KeyboardViewModel(options: KeyboardOptions.all,
                                                    buttons: [
                                                        ("1", ""),
                                                        ("2", "ABC"),
                                                        ("3", "DEF"),
                                                        ("4", "GHI"),
                                                        ("5", "JKL"),
                                                        ("6", "MNO"),
                                                        ("7", "PQRS"),
                                                        ("8", "TUV"),
                                                        ("9", "WXYZ"),
                                                        ("", ""),
                                                        ("0", ""),
                                                        ("R", "")],
                                                    bottomLeftImage: nil,
                                                    bottomRightImage: UIImage(named: "backspace"),
                                                    labelColor: keyboardTextColor,
                                                    buttonColor: keyboardTextColor,
                                                    backgroundColor: .clear))

        if isConfirming {
            titleLabel.text = "PIN_ENTER_TITLE".localized()
            title = "Confirm Pin"
            navigationItem.title = "Confirm Pin"
            navigationItem.setHidesBackButton(false, animated: false)
        } else {
            titleLabel.text = "PIN_CREATE_TITLE".localized()
            title = "Create Pin"
            navigationItem.title = "Create Pin"
            navigationItem.setHidesBackButton(true, animated: false)
        }

        logoImageView.image = UIImage(named: "logoWhite")
       
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        if isCloseDisplayed {
            let image = UIImage(named:"close")
            let leftBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(self.dismissView))
            navigationItem.leftBarButtonItem = leftBarButtonItem
        }

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
    
    @objc func dismissView() {
        view.endEditing(true)
        
        dismiss(animated: true, completion: nil)
    }
    
    func pinMismatchError() {
        pin = ""

        // Haptic feedback for failing to enter pin correctly
        notificationGenerator.notificationOccurred(.error)

        for pinView in pinViews {
            pinView.shake() {
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
        default: print("???")
        }

        for (index, pinView) in pinViews.enumerated() {
            index < pin.count ? pinView.animateToCircle() : pinView.animateToLine()
        }

        if pin.count == PinViewController.pinLength {
            // Prime the haptic engine
            notificationGenerator.prepare()

            DispatchQueue.main.asyncAfter(deadline: .now() + PinViewController.pinCheckDelay) {
                self.delegate?.pinEntryCompleted(self, pin: self.pin, save: self.shouldSavePin)
            }
        }
    }
}
