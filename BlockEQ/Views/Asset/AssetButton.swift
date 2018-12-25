//
//  AssetButton.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-12-24.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Foundation

@IBDesignable
final class AssetButton: UIButton {
    var buttonColor: UIColor? {
        didSet {
            self.backgroundColor = self.buttonColor
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    func setupView() {
        self.backgroundColor = Colors.stellarBlue
        self.layer.cornerRadius = 5
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupView()
    }
}
