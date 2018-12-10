//
//  StellarAssetPair.swift
//  StellarHub
//
//  Created by Nick DiZazzo on 2018-10-25.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

public struct StellarAssetPair {
    public let buying: StellarAsset
    public let selling: StellarAsset

    public init(buying: StellarAsset, selling: StellarAsset) {
        self.buying = buying
        self.selling = selling
    }
}

extension StellarAssetPair: Equatable { }
