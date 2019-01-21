//
//  Common.swift
//  StellarHubTests
//
//  Created by Nick DiZazzo on 2018-12-19.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk
@testable import StellarHub

func stubCoreService() -> CoreServiceProtocol {
    let seed = "SBCATWZ7RYZK2VY4D5RLVJQGSRLEJXM4PTAA5ZZLIQIGBGQITV6YRAKJ"
    let mnemonic = "a mnemonic for testing"
    let stubKeyPair = try! KeyPair(secretSeed: seed)

    let pubData = Data(bytes: stubKeyPair.publicKey.bytes)
    let privData = Data(bytes: stubKeyPair.privateKey!.bytes)

    let stubSecretManager = StubSecretManager(publicKey: pubData,
                                              privateKey: privData,
                                              secretSeed: seed,
                                              mnemonic: mnemonic)

    let env = StellarConfig.HorizonAPI.custom("localhost")
    let sdk = StellarSDK(withHorizonUrl: env.urlString)
    let core = StubCoreService(sdk: sdk, api: env, secretManager: stubSecretManager, keyPair: stubKeyPair)

    return core
}
