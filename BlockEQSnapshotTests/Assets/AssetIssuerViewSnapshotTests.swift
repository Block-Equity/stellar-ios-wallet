//
//  AssetIssuerViewSnapshotTests.swift
//  BlockEQSnapshotTests
//
//  Created by Nick DiZazzo on 2019-01-07.
//  Copyright © 2019 BlockEQ. All rights reserved.
//

@testable import BlockEQ
import XCTest
import SnapshotTesting

final class AssetIssuerViewSnapshotTests: XCTestCase, SnapshotTest {
    var recordMode: Bool = false
    var issuerData: AssetIssuerView.ViewModel!

    override func setUp() {
        super.setUp()

        issuerData = AssetIssuerView.ViewModel(issuerTitle: "Issued by Block Equity",
                                               issuerDescription: "The official BlockPoints (PTS) token of BlockEQ",
                                               addressTitle: "Issuing Address",
                                               addressDescription: "GDDSCLKSTRNVLLCPNZ2J5SNG5SAMCWIVHWBSRWAGQUP2IPIKPJMFGKQQ")
    }

    override func tearDown() {
        super.tearDown()
    }

    func testAssetIssuerView() {
        let assetIssuer = AssetIssuerView()
        assetIssuer.frame = CGRect(x: 0, y: 0, width: 350, height: 85)

        assetIssuer.update(with: issuerData)

        assertSnapshot(matching: assetIssuer, as: .image, record: self.recordMode)
    }

    func testNarrowAssetIssuerView() {
        let assetIssuer = AssetIssuerView()
        assetIssuer.frame = CGRect(x: 0, y: 0, width: 300, height: 85)

        assetIssuer.update(with: issuerData)

        assertSnapshot(matching: assetIssuer, as: .image, record: self.recordMode)
    }
}
