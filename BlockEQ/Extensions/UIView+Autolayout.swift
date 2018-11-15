//
//  UIView+Autolayout.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-09-28.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import UIKit

public extension UIView {
    func constraintsForViewToAllEdges(_ view: UIView, insets: UIEdgeInsets = .zero) -> [NSLayoutConstraint] {
        let edges: [NSLayoutConstraint.Attribute] = [.leading, .trailing, .top, .bottom]
        return self.constraintsForView(view, edges: edges, insets: insets)
    }

    func constrainViewToAllEdges(_ view: UIView, insets: UIEdgeInsets = .zero) {
        let edges: [NSLayoutConstraint.Attribute] = [.leading, .trailing, .top, .bottom]
        self.constrainView(view, edges: edges, insets: insets)
    }

    func constrainViewToAllSafeEdges(_ view: UIView) {
        let margins = view.layoutMarginsGuide
        let safeAreaConstraints = [
            leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            topAnchor.constraint(equalTo: margins.topAnchor),
            bottomAnchor.constraint(equalTo: margins.bottomAnchor)
        ]

        self.addConstraints(safeAreaConstraints)
    }

    func constrainView(_ view: UIView,
                       edges: [NSLayoutConstraint.Attribute],
                       insets: UIEdgeInsets = .zero,
                       priority: UILayoutPriority? = nil) {

        let constraints = self.constraintsForView(
            view,
            edges: edges,
            insets: insets,
            priority: priority
        )

        self.addConstraints(constraints)
    }

    func constraintsForView(_ view: UIView,
                            edges: [NSLayoutConstraint.Attribute],
                            insets: UIEdgeInsets, priority: UILayoutPriority? = nil) -> [NSLayoutConstraint] {

        return edges.map({ (edge) -> NSLayoutConstraint in
            return self.constrainView(view, toEdge: edge, insets: insets, priority: priority)
        })
    }

    func constrainView(_ view: UIView,
                       toEdge edge: NSLayoutConstraint.Attribute,
                       insets: UIEdgeInsets = .zero,
                       priority: UILayoutPriority?) -> NSLayoutConstraint {

        view.translatesAutoresizingMaskIntoConstraints = false

        let inset: CGFloat = {
            switch edge {
            case .leading: return insets.left
            case .trailing: return -1 * insets.right
            case .bottom: return -1 * insets.bottom
            case .top: return insets.top
            default: return 0
            }
        }()

        let constraint = NSLayoutConstraint(
            item: view,
            attribute: edge,
            relatedBy: .equal,
            toItem: self,
            attribute: edge,
            multiplier: 1,
            constant: inset
        )

        if let priority = priority {
            constraint.priority = priority
        }
        return constraint
    }

    func forceLayout(width: CGFloat) {
        var frame = self.frame
        frame.size.width = width
        self.frame = frame

        self.setNeedsLayout()
        self.layoutIfNeeded()

        let height = self.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        frame.size.height = height
        self.frame = frame
    }
}
