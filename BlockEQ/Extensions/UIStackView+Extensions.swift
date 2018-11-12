//
//  UIStackView+Extensions.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-11-13.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

extension UIStackView {
    /// Removes all views contained within the stack view.
    func removeAllArrangedSubviews() {
        let removedSubviews = arrangedSubviews.reduce([]) { (allSubviews, subview) -> [UIView] in
            self.removeArrangedSubview(subview)
            return allSubviews + [subview]
        }

        removedSubviews.forEach({ $0.removeFromSuperview() })
    }
}
