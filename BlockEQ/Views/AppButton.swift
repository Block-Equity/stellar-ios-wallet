//
//  NextButton.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-03-09.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import UIKit

class AppButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    private func setupView() {
        backgroundColor = Colors.primaryDark
        setTitleColor(Colors.white, for: .normal)
    }

    public func setEnabled() {
        isEnabled = true
        alpha = Alphas.opaque
    }

    public func setDisabled() {
        isEnabled = false
        alpha = Alphas.transparent
    }
}
