//
//  UIRoundedButton.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2019-01-08.
//  Copyright © 2019 BlockEQ. All rights reserved.
//

import UIKit

final class UIRoundedButton: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.size.width / 2.0
        clipsToBounds = true
    }
}
