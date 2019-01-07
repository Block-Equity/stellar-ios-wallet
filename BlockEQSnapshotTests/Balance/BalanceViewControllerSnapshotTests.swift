//
//  BalanceViewControllerSnapshotTests.swift
//  BlockEQSnapshotTests
//
//  Created by Nick DiZazzo on 2019-01-07.
//  Copyright © 2019 BlockEQ. All rights reserved.
//

@testable import BlockEQ
@testable import StellarHub
import SnapshotTesting
import XCTest
import stellarsdk

final class BalanceViewControllerSnapshotTests: XCTestCase, SnapshotTest {
    var recordMode: Bool = false
    var vc = BalanceViewController()

    override func setUp() {
        super.setUp()
        _ = vc.view
    }

    override func tearDown() {
        super.tearDown()
    }

    func testNativeBalance() {
        let account = StellarAccount(accountId: "")
        let asset = StellarAsset(assetType: AssetTypeAsString.NATIVE,
                                 assetCode: nil,
                                 assetIssuer: nil,
                                 balance: "123.45")

        vc.update(with: asset, account: account)

        let oldFrame = vc.view.frame
        vc.view.frame = CGRect(x: 0, y: 0, width: oldFrame.width, height: 800)
        vc.view.layoutSubviews()

        assertSnapshot(matching: vc, as: .image, record: self.recordMode)
    }

    func testNonNativeBalance() {
        let account = StellarAccount(accountId: "")
        let asset = StellarAsset(assetType: AssetTypeAsString.CREDIT_ALPHANUM4,
                                 assetCode: "PTS",
                                 assetIssuer: "GBPG7KRYC3PTKHBXQGRD3GMZ5DB4C3D553ZN2ZLH57LBAQIULVY46Z5F",
                                 balance: "123.45")

        vc.update(with: asset, account: account)
        vc.view.layoutSubviews()

        assertSnapshot(matching: vc, as: .image, record: self.recordMode)
    }
}
