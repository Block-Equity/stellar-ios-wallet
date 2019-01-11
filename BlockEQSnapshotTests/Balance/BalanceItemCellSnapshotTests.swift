//
//  BalanceItemCellSnapshotTests.swift
//  BlockEQSnapshotTests
//
//  Created by Nick DiZazzo on 2019-01-10.
//  Copyright © 2019 BlockEQ. All rights reserved.
//

@testable import BlockEQ
import SnapshotTesting
import XCTest

final class BalanceItemCellSnapshotTests: XCTestCase, SnapshotTest {
    var recordMode: Bool = false

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testBasicCell() {
        let cell = BalanceItemCell(frame: .zero)
        cell.frame = CGRect(x: 0, y: 0, width: 375, height: 30)

        cell.update(with: BalanceItemCell.ViewModel(title: "Balance Item", amount: "10", value: "1.00", weight: nil))

        assertSnapshot(matching: cell, as: .image, record: self.recordMode)
    }

    func testFontWeightCell() {
        let cell = BalanceItemCell(frame: .zero)
        cell.frame = CGRect(x: 0, y: 0, width: 375, height: 30)

        cell.update(with: BalanceItemCell.ViewModel(title: "Bold Balance Item", amount: "10", value: "0.50", weight: .bold))

        assertSnapshot(matching: cell, as: .image, record: self.recordMode)
    }

    func testCompressedFontWeightCell() {
        let cell = BalanceItemCell(frame: .zero)
        cell.frame = CGRect(x: 0, y: 0, width: 300, height: 30)

        cell.update(with: BalanceItemCell.ViewModel(title: "Bold Balance Item", amount: "100", value: "0.50", weight: .bold))

        assertSnapshot(matching: cell, as: .image, record: self.recordMode)
    }

    func testRoundedCorners() {
        let cell = BalanceItemCell(frame: .zero)
        cell.cornerMask = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]

        cell.frame = CGRect(x: 0, y: 0, width: 375, height: 30)
        cell.cornerMask = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        cell.update(with: BalanceItemCell.ViewModel(title: "Bold Balance Item", amount: "10", value: "0.50", weight: .bold))

        cell.layoutSubviews()

        assertSnapshot(matching: cell, as: .image, record: self.recordMode)
    }
}
