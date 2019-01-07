//
//  AssetListSnapshotTests.swift
//  BlockEQSnapshotTests
//
//  Created by Nick DiZazzo on 2018-12-27.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

@testable import BlockEQ
import StellarHub
import SnapshotTesting
import XCTest
import stellarsdk

final class AssetListSnapshotTests: XCTestCase, SnapshotTest {
    var recordMode: Bool = false

    let vc = AssetListViewController()
    static let issuer = "GDDSCLKSTRNVLLCPNZ2J5SNG5SAMCWIVHWBSRWAGQUP2IPIKPJMFGKQQ"
    let cadAssetNoBalance = StellarAsset(assetCode: "cad", issuer: AssetListSnapshotTests.issuer)
    let ptsAssetNoBalance = StellarAsset(assetCode: "pts", issuer: AssetListSnapshotTests.issuer)
    let cadAssetBalance = StellarAsset(assetType: AssetTypeAsString.CREDIT_ALPHANUM4,
                                       assetCode: "cad",
                                       assetIssuer: AssetListSnapshotTests.issuer,
                                       balance: "123.45")
    let ptsAssetBalance = StellarAsset(assetType: AssetTypeAsString.CREDIT_ALPHANUM4,
                                       assetCode: "pts",
                                       assetIssuer: AssetListSnapshotTests.issuer,
                                       balance: "456.78")

    override func setUp() {
        super.setUp()

        _ = vc.view
    }

    override func tearDown() {
        super.tearDown()
    }

    func testEmptyAssets() {
        let dataSource = AccountAssetListDataSource(accountAssets: [], availableAssets: [])

        vc.dataSource = dataSource
        vc.reload()

        assertSnapshot(matching: vc, as: .image, record: self.recordMode)
    }

    func testOnlyNativeAsset() {
        let dataSource = AccountAssetListDataSource(accountAssets: [StellarAsset.lumens], availableAssets: [])

        vc.dataSource = dataSource
        vc.reload()

        assertSnapshot(matching: vc, as: .image, record: self.recordMode)
    }

    func testNativeAssetAndAvailableBlockEQAssets() {
        let assets = [cadAssetNoBalance, ptsAssetNoBalance]
        let dataSource = AccountAssetListDataSource(accountAssets: [StellarAsset.lumens], availableAssets: assets)

        vc.dataSource = dataSource
        vc.reload()

        assertSnapshot(matching: vc, as: .image, record: self.recordMode)
    }

    func testAccountWithRemovableAssets() {
        let dataSource = AccountAssetListDataSource(accountAssets: [StellarAsset.lumens,
                                                                    ptsAssetNoBalance,
                                                                    cadAssetNoBalance], availableAssets: [])

        vc.dataSource = dataSource
        vc.reload()

        assertSnapshot(matching: vc, as: .image, record: self.recordMode)
    }

    func testAccountWithNonRemovableAssets() {
        let dataSource = AccountAssetListDataSource(accountAssets: [StellarAsset.lumens,
                                                                    ptsAssetBalance,
                                                                    cadAssetBalance], availableAssets: [])

        vc.dataSource = dataSource
        vc.reload()

        assertSnapshot(matching: vc, as: .image, record: self.recordMode)
    }
}
