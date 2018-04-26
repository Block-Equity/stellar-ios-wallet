//
//  UIView+NibLoadableView.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-04-25.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import Foundation

protocol NibLoadableView {
    static var nibName: String { get }
    static var bundle: Bundle { get }
}

extension NibLoadableView {
    static var nibName: String {
        return String(describing: Self.self)
    }

    static var bundle: Bundle {
        return Bundle(for: (Self.self as! AnyClass))
    }
}
