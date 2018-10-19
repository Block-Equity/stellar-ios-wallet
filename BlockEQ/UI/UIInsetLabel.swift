//
//  UIInsetLabel.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-10-18.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import UIKit

@IBDesignable
class UIInsetLabel: UILabel {
    @IBInspectable public var bottomInset: CGFloat {
        get { return edgeInsets.bottom }
        set { edgeInsets.bottom = newValue }
    }

    @IBInspectable public var leftInset: CGFloat {
        get { return edgeInsets.left }
        set { edgeInsets.left = newValue }
    }

    @IBInspectable public var rightInset: CGFloat {
        get { return edgeInsets.right }
        set { edgeInsets.right = newValue }
    }

    @IBInspectable public var topInset: CGFloat {
        get { return edgeInsets.top }
        set { edgeInsets.top = newValue }
    }

    var edgeInsets: UIEdgeInsets = .zero

    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets.init(top: edgeInsets.top,
                                       left: edgeInsets.left,
                                       bottom: edgeInsets.bottom,
                                       right: edgeInsets.right)

        super.drawText(in: rect.inset(by: insets))
    }
}
