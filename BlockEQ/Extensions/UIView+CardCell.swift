//
//  UIView+CardCell.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-12-31.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Foundation

protocol StylableCardCell: AnyObject {
    var cardInset: UIEdgeInsets { get }
    var cardView: UIView! { get }
    var preferredWidth: CGFloat? { get set }

    var cardLeftInset: NSLayoutConstraint! { get }
    var cardBottomInset: NSLayoutConstraint! { get }
    var cardTopInset: NSLayoutConstraint! { get }
    var cardRightInset: NSLayoutConstraint! { get }

    func applyCardStyle()
    func select()
}

extension StylableCardCell where Self: UICollectionViewCell {
    func applyCardStyle() {
        cardView.layer.cornerRadius = 5
        cardView.backgroundColor = .white
        cardView.clipsToBounds = false
        cardView.layer.shadowColor = Colors.black.cgColor
        cardView.layer.masksToBounds = false
        cardView.layer.shadowRadius = 4
        cardView.layer.shadowOffset = CGSize(width: 0, height: 3)
        cardView.layer.shadowOpacity = 0.25

        cardLeftInset.constant = cardInset.left
        cardRightInset.constant = cardInset.right
        cardTopInset.constant = cardInset.top
        cardBottomInset.constant = cardInset.bottom
    }

    func cellLayoutAttributes(attributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        setNeedsLayout()
        layoutIfNeeded()

        let size = contentView.systemLayoutSizeFitting(attributes.size)
        var newFrame = attributes.frame

        if let cellWidth = preferredWidth {
            newFrame.size.width = cellWidth
        } else {
            newFrame.size.width = size.width
        }

        newFrame.size.height = size.height
        attributes.frame = newFrame

        return attributes
    }

    func select() {
        cardView.backgroundColor = Colors.lightGray

        UIView.animate(withDuration: 0.25, animations: {
            self.cardView.backgroundColor = .white
        }, completion: nil)
    }
}
