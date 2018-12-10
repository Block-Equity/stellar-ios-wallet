//
//  StellarPaymentData.swift
//  StellarHub
//
//  Created by Nick DiZazzo on 2018-10-24.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk

public struct StellarPaymentData {
    let address: StellarAddress
    let amount: Decimal
    let memo: String?
    let asset: StellarAsset

    public init(address: StellarAddress, amount: Decimal, memo: String?, asset: StellarAsset) {
        self.address = address
        self.amount = amount
        self.memo = memo
        self.asset = asset
    }

    var destinationKeyPair: KeyPair? {
        return try? KeyPair(accountId: address.string)
    }
}
