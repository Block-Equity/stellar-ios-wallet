//
//  KeyboardView.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-05-24.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import Foundation

enum KeyboardButton {
    case number(Int)
    case left, right
    case unrecognized
}

protocol KeyboardViewDelegate: AnyObject {
    func selected(key: KeyboardButton, action: UIEvent)
}

struct KeyboardOptions: OptionSet {
    let rawValue: Int
    static let keyLabels = KeyboardOptions(rawValue: 1 << 0)
    static let leftButton = KeyboardOptions(rawValue: 1 << 1)
    static let rightButton = KeyboardOptions(rawValue: 1 << 2)
    static let all: KeyboardOptions = [.keyLabels, .leftButton, .rightButton]
}

struct KeyboardViewModel {
    typealias KeyboardButton = (title: String, label: String)
    var options: KeyboardOptions
    var buttons: [KeyboardButton]
    var bottomLeftImage: UIImage?
    var bottomRightImage: UIImage?

    var labelColor: UIColor
    var buttonColor: UIColor
    var backgroundColor: UIColor

    var keyFont = UIFont.systemFont(ofSize: 24, weight: .medium)
    var leftFont = UIFont.systemFont(ofSize: 14, weight: .medium)
    var rightFont = UIFont.systemFont(ofSize: 14, weight: .medium)

    init(options: KeyboardOptions,
         buttons: [KeyboardButton],
         bottomLeftImage: UIImage?,
         bottomRightImage: UIImage?,
         labelColor: UIColor,
         buttonColor: UIColor,
         backgroundColor: UIColor) {
        self.options = options
        self.buttons = buttons
        self.bottomLeftImage = bottomLeftImage
        self.bottomRightImage = bottomRightImage
        self.labelColor = labelColor
        self.buttonColor = buttonColor
        self.backgroundColor = backgroundColor
    }
}

class KeyboardView: UIView {
    @IBOutlet var contentView: UIView!

    weak var delegate: KeyboardViewDelegate?

    /// The numeric buttons in the view, from top left to bottom right
    @IBOutlet var keyButtons: [UIButton]!

    /// The labels for the numeric buttons in the view, from top left to bottom right
    @IBOutlet var keyLabels: [UILabel]!

    /// The button on the bottom left
    @IBOutlet weak var leftConfigurableButton: UIButton!

    /// The button on the bottom right
    @IBOutlet weak var rightConfigurableButton: UIButton!

    /// The label for the button on the bottom left
    @IBOutlet weak var leftConfigurableLabel: UILabel!

    /// The label for the button on the bottom right
    @IBOutlet weak var rightConfigurableLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    func commonInit() {
        Bundle.main.loadNibNamed("KeyboardView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        self.backgroundColor = .clear
    }

    /// The action when any button is pressed in the KeyboardView
    ///
    /// - Parameters:
    ///   - sender: The UIButton triggering this action.
    ///   - event: The UIEvent received.
    @IBAction func selectedButton(_ sender: Any, forEvent event: UIEvent) {
        guard let button = sender as? UIButton else {
            return
        }

        var key: KeyboardButton

        switch button {
        case _ where button == keyButtons[0]: key = .number(1)
        case _ where button == keyButtons[1]: key = .number(2)
        case _ where button == keyButtons[2]: key = .number(3)
        case _ where button == keyButtons[3]: key = .number(4)
        case _ where button == keyButtons[4]: key = .number(5)
        case _ where button == keyButtons[5]: key = .number(6)
        case _ where button == keyButtons[6]: key = .number(7)
        case _ where button == keyButtons[7]: key = .number(8)
        case _ where button == keyButtons[8]: key = .number(9)
        case _ where button == keyButtons[10]: key = .number(0)
        case _ where button == leftConfigurableButton: key = .left
        case _ where button == rightConfigurableButton: key = .right
        default: key = .unrecognized
        }

        delegate?.selected(key: key, action: event)
    }

    /// Configures the KeyboardView with the provided options
    ///
    /// - Parameter viewModel: The configuration model for the keyboard view.
    func update(with viewModel: KeyboardViewModel) {
        assert(keyButtons.count == viewModel.buttons.count, "Mismatched label count!")
        assert(keyLabels.count == viewModel.buttons.count, "Mismatched title count!")

        for label in keyLabels.enumerated() {
            keyLabels[label.offset].text = viewModel.buttons[label.offset].label
            keyLabels[label.offset].isHidden = !viewModel.options.contains(.keyLabels)
            keyLabels[label.offset].textColor = viewModel.labelColor
        }

        for button in keyButtons.enumerated() {
            keyButtons[button.offset].setTitle(viewModel.buttons[button.offset].title, for: .normal)
            keyButtons[button.offset].setTitleColor(viewModel.buttonColor, for: .normal)
            keyButtons[button.offset].titleLabel?.font = viewModel.keyFont
        }

        let leftHidden = !viewModel.options.contains(.leftButton)
        leftConfigurableButton.isHidden = leftHidden
        leftConfigurableLabel.isHidden = leftHidden
        leftConfigurableButton.setImage(viewModel.bottomLeftImage, for: .normal)
        leftConfigurableButton.tintColor = viewModel.buttonColor
        leftConfigurableButton.titleLabel?.font = viewModel.leftFont

        let rightHidden = !viewModel.options.contains(.rightButton)
        rightConfigurableButton.isHidden = rightHidden
        rightConfigurableLabel.isHidden = rightHidden
        rightConfigurableButton.setImage(viewModel.bottomRightImage, for: .normal)
        rightConfigurableButton.tintColor = viewModel.buttonColor
        rightConfigurableButton.titleLabel?.font = viewModel.rightFont

        if viewModel.bottomLeftImage != nil {
            leftConfigurableButton.setTitle(nil, for: .normal)
        }

        if viewModel.bottomRightImage != nil {
            rightConfigurableButton.setTitle(nil, for: .normal)
        }

        backgroundColor = viewModel.backgroundColor
    }
}
