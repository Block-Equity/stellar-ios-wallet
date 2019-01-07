//
//  AssetPriceViewSnapshotTests.swift
//  BlockEQSnapshotTests
//
//  Created by Nick DiZazzo on 2019-01-07.
//  Copyright © 2019 BlockEQ. All rights reserved.
//

@testable import BlockEQ
import XCTest
import SnapshotTesting

final class AssetPriceViewSnapshotTests: XCTestCase, SnapshotTest {
    var recordMode: Bool = false
    var priceData: AssetPriceView.ViewModel!
    
    override func setUp() {
        super.setUp()
        priceData = AssetPriceView.ViewModel(amount: "123.45", price: "$13,456.78", hidePrice: false)
    }

    override func tearDown() {
        super.tearDown()
    }

    func testAssetAmount() {
        let assetPrice = AssetPriceView(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
        assetPrice.update(with: priceData)
        assertSnapshot(matching: assetPrice, as: .image, record: self.recordMode)
    }

    func testAssetAmountWithPrice() {
        let assetPrice = AssetPriceView(frame: CGRect(x: 0, y: 0, width: 60, height: 30))

        var priceData = self.priceData!
        priceData.hidePrice = false

        assetPrice.update(with: priceData)
        assertSnapshot(matching: assetPrice, as: .image, record: self.recordMode)
    }

    func testAssetAmountWithPriceWithColors() {
        let assetPrice = AssetPriceView(frame: CGRect(x: 0, y: 0, width: 60, height: 30))

        var priceData = self.priceData!
        priceData.hidePrice = false
        priceData.amountColor = Colors.green
        priceData.priceColor = Colors.red

        assetPrice.update(with: priceData)
        assertSnapshot(matching: assetPrice, as: .image, record: self.recordMode)
    }
}


