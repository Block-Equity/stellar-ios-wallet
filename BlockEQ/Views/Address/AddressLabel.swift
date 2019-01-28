//
//  AddressLabel.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2019-01-28.
//  Copyright © 2019 BlockEQ. All rights reserved.
//

import Foundation

final class AddressLabel: UIView {
    static let defaultInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
    let innerLabel = UILabel(frame: .zero)

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

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.size.height / 2
        clipsToBounds = true
    }

    func setupView() {
        leftInset = AddressLabel.defaultInsets.left
        rightInset = AddressLabel.defaultInsets.right
        topInset = AddressLabel.defaultInsets.top
        bottomInset = AddressLabel.defaultInsets.bottom

        addSubview(innerLabel)
        constrainViewToAllEdges(innerLabel, insets: edgeInsets)

        backgroundColor = Colors.primaryDark

        innerLabel.lineBreakMode = .byTruncatingMiddle
        innerLabel.backgroundColor = .clear
        innerLabel.textColor = Colors.white
        innerLabel.textAlignment = .center
        innerLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
    }

    func update(with address: String?, color: UIColor? = Colors.primaryDark) {
        backgroundColor = color
        innerLabel.text = address
    }

    override func prepareForInterfaceBuilder() {
        setupView()
        update(with: innerLabel.text)
    }
}
