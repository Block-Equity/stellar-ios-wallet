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
    var buttonColor: UIColor? {
        didSet {
            backgroundColor = buttonColor
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    func setupView() {
        layer.cornerRadius = 5
        backgroundColor = Colors.stellarBlue

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
