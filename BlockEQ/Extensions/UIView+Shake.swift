//
//  UIView+Shake.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-03-13.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import UIKit

public extension UIView {
    func shake(count: Float = 4.0, for duration: TimeInterval = 0.3, withTranslation translation: Float = 10) {
        let animation: CABasicAnimation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.repeatCount = count
        animation.duration = duration/TimeInterval(animation.repeatCount)
        animation.autoreverses = true
        animation.byValue = translation
        layer.add(animation, forKey: "shake")
    }
}
