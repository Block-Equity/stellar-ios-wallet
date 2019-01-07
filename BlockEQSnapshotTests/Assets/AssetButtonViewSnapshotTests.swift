//
//  AssetButtonViewSnapshotTests.swift
//  BlockEQSnapshotTests
//
//  Created by Nick DiZazzo on 2019-01-07.
//  Copyright © 2019 BlockEQ. All rights reserved.
//

@testable import BlockEQ
import XCTest
import SnapshotTesting

final class AssetButtonViewSnapshotTests: XCTestCase, SnapshotTest {
    var recordMode: Bool = false
    
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
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
}
