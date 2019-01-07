//
//  AssetButtons.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-12-24.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Reusable

protocol AssetButtonsDelegate: AnyObject {
    func selectedButton(button: AssetButton, at index: Int)
}

final class AssetButtonView: UIView, Reusable, NibOwnerLoadable {
    static let ButtonCount = 3
    static let ButtonSpacing = CGFloat(10)

    @IBOutlet var view: UIView!
    @IBOutlet weak var stackView: UIStackView!

    weak var delegate: AssetButtonsDelegate?

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
        translatesAutoresizingMaskIntoConstraints = false
        view.translatesAutoresizingMaskIntoConstraints = false

        backgroundColor = .clear
        view.backgroundColor = .clear
        stackView.backgroundColor = .clear

        stackView.spacing = AssetButtonView.ButtonSpacing
    }

    func update(with viewModel: ViewModel) {
        stackView.removeAllArrangedSubviews()

        for index in stride(from: AssetButtonView.ButtonCount - 1, to: -1, by: -1) {
            let button = AssetButton()
            if index < viewModel.buttonData.count {
                let data = viewModel.buttonData[index]
                button.setTitle(data.title, for: .normal)
                button.setTitleColor(data.textColor, for: .normal)
                button.buttonColor = data.backgroundColor
                button.isEnabled = data.enabled
                button.addTarget(self, action: #selector(selectedButton(_:)), for: .touchUpInside)
                button.tag = index
            } else {
                button.alpha = 0
                button.isEnabled = false
            }

            stackView.addArrangedSubview(button)
        }
    }

    @objc func selectedButton(_ sender: AssetButton) {
        delegate?.selectedButton(button: sender, at: sender.tag)
    }
}

//swiftlint:disable nesting
extension AssetButtonView {
    struct ViewModel {
        static let empty = ViewModel(buttonData: [])

        typealias ButtonData = (title: String, backgroundColor: UIColor, textColor: UIColor, enabled: Bool)
        var buttonData: [ButtonData]
    }
}
//swiftlint:enable nesting
