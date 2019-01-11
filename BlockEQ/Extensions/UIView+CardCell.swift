//
//  UIView+CardCell.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-12-31.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Foundation

// MARK: - StylableCard
protocol StylableCard {
    var cardView: UIView! { get }
    func cardStyle(view: UIView)
}

extension StylableCard {
    func cardStyle(view: UIView) {
        view.backgroundColor = .white
        view.clipsToBounds = true
        view.layer.masksToBounds = false
        view.layer.cornerRadius = 5
        view.layer.shadowRadius = 3
        view.layer.shadowColor = Colors.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 3)
        view.layer.shadowOpacity = 0.05
    }
}

// MARK: - RoundableCardCell
protocol RoundableCardCell {
    var cornerMask: CACornerMask? { get }
}

// MARK: - SizeableCardCell
protocol SizeableCardCell {
    var preferredWidth: CGFloat? { get set }
    var preferredHeight: CGFloat? { get set }
}

extension SizeableCardCell where Self: UICollectionViewCell {
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

        if let cellHeight = preferredHeight {
            newFrame.size.height = cellHeight
        } else {
            newFrame.size.height = size.height
        }

        attributes.frame = newFrame

        return attributes
    }
}

// MARK: - StylableBalanceCell
protocol StylableBalanceCell: StylableCard, SizeableCardCell, RoundableCardCell { }

// MARK: - StylableAssetCell
protocol StylableAssetCell: StylableCard, SizeableCardCell, RoundableCardCell {
    func select()
}

extension StylableAssetCell where Self: UICollectionViewCell {
    func select() {
        cardView.backgroundColor = Colors.lightGray

        UIView.animate(withDuration: 0.25, animations: {
            self.cardView.backgroundColor = .white
        }, completion: nil)
    }
}
