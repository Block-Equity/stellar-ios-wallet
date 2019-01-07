//
//  AssetButton.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-12-24.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Reusable

@IBDesignable
final class AssetButton: UIButton {

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.15,
                           delay: 0,
                           options: [.beginFromCurrentState, .allowUserInteraction],
                           animations: {
                self.alpha = self.isHighlighted ? 0.5 : 1
            }, completion: nil)
        }
    }

    var buttonColor: UIColor? {
        didSet {
            backgroundColor = buttonColor
        }
    }

    init() {
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    func setupView() {
        layer.cornerRadius = 5
        backgroundColor = Colors.stellarBlue
        translatesAutoresizingMaskIntoConstraints = false

        setTitle("Button", for: .normal)
        setTitleColor(Colors.white, for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        titleLabel?.textColor = Colors.white
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupView()
    }
}
