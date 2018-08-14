//
//  UIDevice.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-08-08.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Foundation

extension UIDevice {
    var iPhoneX: Bool {
        return UIScreen.main.nativeBounds.height == 2436
    }
}
