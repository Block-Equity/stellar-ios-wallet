//
//  AssetHeaderViewSnapshotTests.swift
//  BlockEQSnapshotTests
//
//  Created by Nick DiZazzo on 2019-01-07.
//  Copyright © 2019 BlockEQ. All rights reserved.
//

@testable import BlockEQ
import XCTest
import SnapshotTesting

final class AssetHeaderViewSnapshotTests: XCTestCase, SnapshotTest {
    var recordMode: Bool = false
    var headerData: AssetHeaderView.ViewModel!
    
    override func setUp() {
        super.setUp()
        headerData = AssetHeaderView.ViewModel(image: UIImage(named: "pts"),
                                               imageURL: BlockEQURL.assetIcon("pts").url,
                                               assetTitle: "Block Points",
                                               assetSubtitle: "PTS")
    }

    override func tearDown() {
        super.tearDown()
    }

    func testAssetHeader() {
        let assetHeader = AssetHeaderView(frame: CGRect(x: 0, y: 0, width: 200, height: 80))
        assetHeader.update(with: headerData)
        assertSnapshot(matching: assetHeader, as: .image, record: self.recordMode)
    }

    func testAssetHeaderNoImage() {
        let assetHeader = AssetHeaderView(frame: CGRect(x: 0, y: 0, width: 200, height: 80))
        headerData.image = nil
        assetHeader.update(with: headerData)
        assertSnapshot(matching: assetHeader, as: .image, record: self.recordMode)
    }
}

