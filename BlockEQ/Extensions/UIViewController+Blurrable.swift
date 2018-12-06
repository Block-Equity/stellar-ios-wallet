//
//  UIViewController+Blurrable.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-12-06.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Foundation

protocol Blurrable: AnyObject {
    var blurContainerView: UIView? { get }
    var toggleButton: UIButton? { get }
    var concealingView: UIVisualEffectView { get }
    var blurEffect: UIBlurEffect { get }
    var revealed: Bool { get set }

    func toggleVisibility(revealText: String, concealText: String)
    func blur(labelText: String, animated: Bool, timeInterval: TimeInterval)
    func unblur(labelText: String, animated: Bool, timeInterval: TimeInterval)
}

extension Blurrable where Self: UIViewController {
    func toggleVisibility(revealText: String, concealText: String) {
        if revealed {
            blur(labelText: revealText)
        } else {
            unblur(labelText: concealText)
        }

        revealed.toggle()
    }

    func blur(labelText: String, animated: Bool = true, timeInterval: TimeInterval = 0.5) {
        if animated {
            UIView.animate(withDuration: timeInterval) { self.concealingView.effect = self.blurEffect }
        } else {
            concealingView.effect = blurEffect
        }

        toggleButton?.setTitle(labelText, for: .normal)
    }

    func unblur(labelText: String, animated: Bool = true, timeInterval: TimeInterval = 0.5) {
        if animated {
            UIView.animate(withDuration: timeInterval) { self.concealingView.effect = nil }
        } else {
            concealingView.effect = nil
        }

        toggleButton?.setTitle(labelText, for: .normal)
    }
}
