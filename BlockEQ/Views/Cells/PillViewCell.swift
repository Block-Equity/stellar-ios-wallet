//
//  PillViewCell.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-03-09.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Reusable

final class PillViewCell: UICollectionViewCell, NibReusable {
    static let cellPadding = CGFloat(10)
    static let edgeInsets = UIEdgeInsets(top: PillViewCell.cellPadding / 2,
                                         left: PillViewCell.cellPadding,
                                         bottom: PillViewCell.cellPadding / 2,
                                         right: PillViewCell.cellPadding)

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var indexLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupStyle()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        indexLabel.text = nil
        titleLabel.text = nil

        setupStyle()
    }

    func setupStyle() {
        backgroundColor = Colors.white
        layer.borderColor = Colors.lightGray.cgColor
        layer.borderWidth = 1.0
        layer.cornerRadius = 5.0

        contentView.translatesAutoresizingMaskIntoConstraints = false

        topConstraint.constant = PillViewCell.edgeInsets.top
        bottomConstraint.constant = PillViewCell.edgeInsets.bottom
        leftConstraint.constant = PillViewCell.edgeInsets.left
        rightConstraint.constant = PillViewCell.edgeInsets.right

        titleLabel.textColor = Colors.darkGray
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        titleLabel.textAlignment = .left

        indexLabel.textColor = Colors.lightGray
        indexLabel.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        indexLabel.textAlignment = .left
    }

    func update(label: String, text: String) {
        indexLabel.text = label
        titleLabel.text = text
    }

    override func preferredLayoutAttributesFitting(
        _ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        setNeedsLayout()
        layoutIfNeeded()

        let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
        var frame = layoutAttributes.frame

        frame.size.width = ceil(size.width)
        frame.size.height = ceil(size.height)
        layoutAttributes.frame = frame

        return layoutAttributes
    }
}
