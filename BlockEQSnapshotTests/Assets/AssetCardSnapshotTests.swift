//
//  AssetCardSnapshotTests.swift
//  BlockEQTests
//
//  Created by Nick DiZazzo on 2018-12-24.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

@testable import BlockEQ
import SnapshotTesting
import XCTest

final class AssetCardSnapshotTests: XCTestCase, SnapshotTest {
    var recordMode: Bool = false
    var headerData: AssetHeaderView.ViewModel!
    var longHeaderData: AssetHeaderView.ViewModel!
    var priceData: AssetPriceView.ViewModel!
    var longPriceData: AssetPriceView.ViewModel!
    var issuerData: AssetIssuerView.ViewModel!
    let cellFrame = CGRect(x: 0, y: 0, width: 375, height: 100)
    let firstPath = IndexPath(row: 0, section: 0)

    override func setUp() {
        super.setUp()

        headerData = AssetHeaderView.ViewModel(image: UIImage(named: "pts"), imageURL: BlockEQURL.assetIcon("pts").url, assetTitle: "Block Points", assetSubtitle: "PTS")
        longHeaderData = AssetHeaderView.ViewModel(image: UIImage(named: "pts"), imageURL: BlockEQURL.assetIcon("pts").url, assetTitle: "Gene Source Code Chain", assetSubtitle: "GENE (Stronghold)")
        priceData = AssetPriceView.ViewModel(amount: "123.45", price: "$13,456.78", hidePrice: true)
        longPriceData = AssetPriceView.ViewModel(amount: "210,000,123.45", price: "$99,999,233,456.78")
        issuerData = AssetIssuerView.ViewModel(issuerTitle: "Issued by Block Equity",
                                               issuerDescription: "The official BlockPoints (PTS) token of BlockEQ",
                                               addressTitle: "Issuing Address",
                                               addressDescription: "GDDSCLKSTRNVLLCPNZ2J5SNG5SAMCWIVHWBSRWAGQUP2IPIKPJMFGKQQ")
    }

    override func tearDown() {
        super.tearDown()
    }

    func testAssetAmountCell() {
        let assetAmountCell = AssetAmountCell()
        assetAmountCell.frame = cellFrame

        let model = AssetAmountCell.ViewModel(headerData: headerData, priceData: priceData)
        assetAmountCell.update(with: model, indexPath: firstPath)

        assertSnapshot(matching: assetAmountCell, as: .image, record: self.recordMode)
    }

    func testAssetAmountCellWithPrice() {
        let assetAmountCell = AssetAmountCell()
        assetAmountCell.frame = cellFrame

        var priceData = self.priceData!
        priceData.hidePrice = false

        let model = AssetAmountCell.ViewModel(headerData: headerData, priceData: priceData)
        assetAmountCell.update(with: model, indexPath: firstPath)

        assertSnapshot(matching: assetAmountCell, as: .image, record: self.recordMode)
    }

    func testAssetAmountCellWithNoImage() {
        let assetAmountCell = AssetAmountCell()
        assetAmountCell.frame = cellFrame

        let headerData = AssetHeaderView.ViewModel(image: nil, imageURL: nil, assetTitle: "Block Points", assetSubtitle: "PTS")
        let model = AssetAmountCell.ViewModel(headerData: headerData, priceData: priceData)
        assetAmountCell.update(with: model, indexPath: firstPath)

        assertSnapshot(matching: assetAmountCell, as: .image, record: self.recordMode)
    }

    func testAssetAmountCellWithPriceAndNoImage() {
        let assetAmountCell = AssetAmountCell()
        assetAmountCell.frame = cellFrame

        var priceData = self.priceData!
        priceData.hidePrice = false

        let headerData = AssetHeaderView.ViewModel(image: nil, imageURL: nil, assetTitle: "Block Points", assetSubtitle: "PTS")
        let model = AssetAmountCell.ViewModel(headerData: headerData, priceData: priceData)
        assetAmountCell.update(with: model, indexPath: firstPath)

        assertSnapshot(matching: assetAmountCell, as: .image, record: self.recordMode)
    }

    func testLongAssetAmount() {
        let assetAmountCell = AssetAmountCell()
        assetAmountCell.frame = cellFrame

        let model = AssetAmountCell.ViewModel(headerData: longHeaderData, priceData: longPriceData)
        assetAmountCell.update(with: model, indexPath: firstPath)

        assertSnapshot(matching: assetAmountCell, as: .image, record: self.recordMode)
    }

    func testLongAssetAmountWithPrice() {
        let assetAmountCell = AssetAmountCell()
        assetAmountCell.frame = cellFrame

        var priceData = self.longPriceData!
        priceData.hidePrice = false

        let model = AssetAmountCell.ViewModel(headerData: longHeaderData, priceData: priceData)
        assetAmountCell.update(with: model, indexPath: firstPath)

        assertSnapshot(matching: assetAmountCell, as: .image, record: self.recordMode)
    }

    func testAssetAddCell() {
        let assetManageCell = AssetManageCell()
        assetManageCell.frame = cellFrame

        let model = AssetManageCell.ViewModel(headerData: headerData, mode: .add)
        assetManageCell.update(with: model, indexPath: firstPath)

        assertSnapshot(matching: assetManageCell, as: .image, record: self.recordMode)
    }

    func testAssetRemoveCell() {
        let assetManageCell = AssetManageCell()
        assetManageCell.frame = cellFrame

        let model = AssetManageCell.ViewModel(headerData: headerData, mode: .remove)
        assetManageCell.update(with: model, indexPath: firstPath)

        assertSnapshot(matching: assetManageCell, as: .image, record: self.recordMode)
    }

    func testAssetActionCell() {
        let actionCell = AssetActionCell()
        actionCell.frame = CGRect(x: 0, y: 0, width: 375, height: 130)

        let buttonColor = UIColor(red: 0.086, green: 0.712, blue: 0.905, alpha: 1.000)
        let image = UIImage(named: "xlm")
        headerData.image = image

        let data = (title: "Button", backgroundColor: buttonColor, textColor: Colors.white, enabled: true)
        let threeButtonData = Array<AssetButtonView.ViewModel.ButtonData>(repeating: data, count: 3)
        let buttonData = AssetButtonView.ViewModel(buttonData: threeButtonData)

        let model = AssetActionCell.ViewModel(headerData: headerData, priceData: priceData, buttonData: buttonData)
        actionCell.update(with: model, indexPath: firstPath)

        assertSnapshot(matching: actionCell, as: .image, record: self.recordMode)
    }

    func testAssetActionCellWithPrice() {
        let actionCell = AssetActionCell()
        actionCell.frame = CGRect(x: 0, y: 0, width: 375, height: 130)

        let buttonColor = UIColor(red: 0.086, green: 0.712, blue: 0.905, alpha: 1.000)
        let image = UIImage(named: "xlm")
        headerData.image = image

        let data = (title: "Button", backgroundColor: buttonColor, textColor: Colors.white, enabled: true)
        let threeButtonData = Array<AssetButtonView.ViewModel.ButtonData>(repeating: data, count: 3)
        let buttonData = AssetButtonView.ViewModel(buttonData: threeButtonData)

        var priceData = self.priceData!
        priceData.hidePrice = false

        let model = AssetActionCell.ViewModel(headerData: headerData, priceData: priceData, buttonData: buttonData)
        actionCell.update(with: model, indexPath: firstPath)

        assertSnapshot(matching: actionCell, as: .image, record: self.recordMode)
    }

    func testAssetIssuerCell() {
        let issuerCell = AssetIssuerCell()
        issuerCell.frame = CGRect(x: 0, y: 0, width: 375, height: 200)

        let model = AssetIssuerCell.ViewModel(headerData: headerData, priceData: priceData, issuerData: issuerData)
        issuerCell.update(with: model, indexPath: firstPath)

        assertSnapshot(matching: issuerCell, as: .image, record: self.recordMode)
    }

    func testAssetIssuerCellWithPrice() {
        let issuerCell = AssetIssuerCell()
        issuerCell.frame = CGRect(x: 0, y: 0, width: 375, height: 200)

        var priceData = self.priceData!
        priceData.hidePrice = false

        let model = AssetIssuerCell.ViewModel(headerData: headerData, priceData: priceData, issuerData: issuerData)
        issuerCell.update(with: model, indexPath: firstPath)

        assertSnapshot(matching: issuerCell, as: .image, record: self.recordMode)
    }
}
