//
//  CacheAccountQROperation.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2019-01-18.
//  Copyright © 2019 BlockEQ. All rights reserved.
//

import StellarHub
import Cache

final class CacheAccountQROperation: Operation {
    let addressString: String
    let imageScale = CGFloat(10)

    init(accountId: String) {
        addressString = accountId
    }

    override func main() {
        let qrMap = QRMap(with: addressString, correctionLevel: .full)
        guard let image = qrMap.scaledTemplateImage(scale: imageScale) else { return }

        let storage = CacheManager.shared.qrCodes
        do {
            try storage.setObject(image, forKey: addressString)
            print("Caching image for \(addressString)")
        } catch let error {
            print(error)
        }
    }
}
