//
//  UIImage+CALayer.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-04-28.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import Foundation

extension CALayer {
    func image() -> UIImage? {
        UIGraphicsBeginImageContext(self.frame.size)

        guard let currentContext = UIGraphicsGetCurrentContext() else { return nil }
        self.render(in: currentContext)

        guard let outputImage = UIGraphicsGetImageFromCurrentImageContext() else { return nil }

        UIGraphicsEndImageContext()

        return outputImage
    }
}
