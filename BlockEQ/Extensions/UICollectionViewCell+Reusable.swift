//
//  UICollectionViewCell+Reusable.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-12-28.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Reusable

public extension NibOwnerLoadable where Self: UICollectionViewCell {
    func loadNibContent() {
        let layoutAttributes: [NSLayoutConstraint.Attribute] = [.top, .leading, .bottom, .trailing]
        for case let view as UIView in Self.nib.instantiate(withOwner: self, options: nil) {
            view.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(view)
            NSLayoutConstraint.activate(layoutAttributes.map { attribute in
                NSLayoutConstraint(
                    item: view, attribute: attribute,
                    relatedBy: .equal,
                    toItem: contentView, attribute: attribute,
                    multiplier: 1, constant: 0.0
                )
            })
        }
    }
}
