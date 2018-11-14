//
//  Diagnostic+Extensions.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-11-15.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import StellarAccountService

extension WalletDiagnostic.CreationMethod {
    static func from(mnemonic: StellarRecoveryMnemonic, recovered: Bool) -> WalletDiagnostic.CreationMethod {
        var creationMethod: WalletDiagnostic.CreationMethod = .unknown

        if recovered {
            creationMethod = mnemonic.type == .twelve ? .recoveredMnemonic12 : .recoveredMnemonic24
        } else {
            creationMethod = mnemonic.type == .twentyFour ? .createdMnemonic12 : .createdMnemonic24
        }

        return creationMethod
    }
}
