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

        headerData = AssetHeaderView.ViewModel(image: nil, assetTitle: "Block Points", assetSubtitle: "PTS")
        longHeaderData = AssetHeaderView.ViewModel(image: nil, assetTitle: "Gene Source Code Chain", assetSubtitle: "GENE (Stronghold)")
        priceData = AssetPriceView.ViewModel(amount: "123.45", price: "$13,456.78")
        longPriceData = AssetPriceView.ViewModel(amount: "210,000,123.45", price: "$99,999,233,456.78")
        issuerData = AssetIssuerView.ViewModel(issuerTitle: "Issued by Block Equity",
                                               issuerDescription: "The official BlockPoints (PTS) token of BlockEQ",
                                               addressTitle: "Issuing Address",
                                               addressDescription: "GDDSCLKSTRNVLLCPNZ2J5SNG5SAMCWIVHWBSRWAGQUP2IPIKPJMFGKQQ")
    }

    override func tearDown() {
        super.tearDown()
    }

    func testAssetHeader() {
        let assetHeader = AssetHeaderView(frame: CGRect(x: 0, y: 0, width: 200, height: 80))
        assetHeader.update(with: headerData)
        assertSnapshot(matching: assetHeader, as: .image, record: self.recordMode)
    }

    func testAssetPrice() {
        let assetPrice = AssetPriceView(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
        assetPrice.update(with: priceData)
        assertSnapshot(matching: assetPrice, as: .image, record: self.recordMode)
    }

    func test1AssetButtons() {
        let assetButtons = AssetButtonView()
        assetButtons.frame = CGRect(x: 0, y: 0, width: 375, height: 40)

        let data = (title: "Button", backgroundColor: Colors.stellarBlue, textColor: Colors.white, enabled: true)
        let threeButtonData = Array<AssetButtonView.ViewModel.ButtonData>(repeating: data, count: 1)
        assetButtons.update(with: AssetButtonView.ViewModel(buttonData: threeButtonData))

        assertSnapshot(matching: assetButtons, as: .image, record: self.recordMode)
    }

    func test2AssetButtons() {
        let assetButtons = AssetButtonView()
        assetButtons.frame = CGRect(x: 0, y: 0, width: 375, height: 40)

        let data = (title: "Button", backgroundColor: Colors.stellarBlue, textColor: Colors.white, enabled: true)
        let threeButtonData = Array<AssetButtonView.ViewModel.ButtonData>(repeating: data, count: 2)
        assetButtons.update(with: AssetButtonView.ViewModel(buttonData: threeButtonData))

        assertSnapshot(matching: assetButtons, as: .image, record: self.recordMode)
    }

    func test3AssetButtons() {
        let assetButtons = AssetButtonView()
        assetButtons.frame = CGRect(x: 0, y: 0, width: 375, height: 40)

        let data = (title: "Button", backgroundColor: Colors.stellarBlue, textColor: Colors.white, enabled: true)
        let threeButtonData = Array<AssetButtonView.ViewModel.ButtonData>(repeating: data, count: 3)
        assetButtons.update(with: AssetButtonView.ViewModel(buttonData: threeButtonData))

        assertSnapshot(matching: assetButtons, as: .image, record: self.recordMode)
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

    func testAssetAmountCell() {
        let assetAmountCell = AssetAmountCell()
        assetAmountCell.frame = cellFrame

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

    func testAssetIssuerCell() {
        let issuerCell = AssetIssuerCell()
        issuerCell.frame = CGRect(x: 0, y: 0, width: 375, height: 180)

        let model = AssetIssuerCell.ViewModel(headerData: headerData, priceData: priceData, issuerData: issuerData)
        issuerCell.update(with: model, indexPath: firstPath)

        assertSnapshot(matching: issuerCell, as: .image, record: self.recordMode)
    }
}
