//
//  AssetButtons.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-12-24.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Reusable

protocol AssetButtonsDelegate: AnyObject {
    func selectedFirstButton(button: AssetButton)
    func selectedSecondButton(button: AssetButton)
    func selectedThirdButton(button: AssetButton)
}

final class AssetButtonView: UIView, Reusable, NibOwnerLoadable {
    static let ButtonSpacing = 15

    @IBOutlet var view: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var button1: AssetButton!
    @IBOutlet weak var button2: AssetButton!
    @IBOutlet weak var button3: AssetButton!
    @IBOutlet var buttonCollection: [AssetButton]!

    weak var delegate: AssetButtonsDelegate?
    var buttonWidth = CGFloat(85)

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.loadNibContent()
        setupStyle()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.loadNibContent()
        setupStyle()
    }

    func setupStyle() {
        stackView.spacing = CGFloat(AssetButtonView.ButtonSpacing)
    }

    func update(with viewModel: ViewModel) {
        for button in buttonCollection.enumerated() {
            if button.offset < viewModel.buttonData.count {
                let data = viewModel.buttonData[button.offset]
                button.element.setTitle(data.title, for: .normal)
                button.element.setTitleColor(data.textColor, for: .normal)
                button.element.buttonColor = data.backgroundColor
                button.element.isEnabled = data.enabled
            } else {
                button.element.isEnabled = false
                button.element.alpha = 0
            }
        }
    }
}

//swiftlint:disable nesting
extension AssetButtonView {
    struct ViewModel {
        typealias ButtonData = (title: String, backgroundColor: UIColor, textColor: UIColor, enabled: Bool)
        var buttonData: [ButtonData]
    }
}
//swiftlint:enable nesting

extension AssetButtonView {
    @IBAction func selectedFirstButton(_ sender: Any) {
        delegate?.selectedFirstButton(button: button1)
    }

    @IBAction func selectedSecondButton(_ sender: Any) {
        delegate?.selectedFirstButton(button: button2)
    }

    @IBAction func selectedThirdButton(_ sender: Any) {
        delegate?.selectedFirstButton(button: button3)
    }
}
