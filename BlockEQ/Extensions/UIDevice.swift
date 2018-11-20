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

    var shortScreen: Bool {
        return UIScreen.main.nativeBounds.height <= 1136
    }

    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
}

extension UIDevice.BatteryState {
    var stateString: String {
        switch self {
        case .charging: return "Charging"
        case .unplugged: return "Unplugged"
        case .full: return "Full"
        case .unknown: return "Unknown"
        }
    }
}
