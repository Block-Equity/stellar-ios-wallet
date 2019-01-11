//
//  BalanceHeaderCellSnapshotTests.swift
//  BlockEQSnapshotTests
//
//  Created by Nick DiZazzo on 2019-01-10.
//  Copyright © 2019 BlockEQ. All rights reserved.
//

@testable import BlockEQ
import SnapshotTesting
import XCTest

final class BalanceHeaderCellSnapshotTests: XCTestCase, SnapshotTest {
    var recordMode: Bool = false

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testBasicCell() {
        let cell = BalanceHeader(frame: .zero)
        cell.frame = CGRect(x: 0, y: 0, width: 375, height: 75)

        cell.update(with: BalanceHeader.ViewModel(totalTitle: "Total Balance",
                                                  totalDescription: "1234",
                                                  availableTitle: "Available Balance",
                                                  availableDescription: "1234",
                                                  titleFont: nil,
                                                  descriptionFont: nil))

        cell.layoutSubviews()

        assertSnapshot(matching: cell, as: .image, record: self.recordMode)
    }

    func testCompressedCell() {
        let cell = BalanceHeader(frame: .zero)
        cell.frame = CGRect(x: 0, y: 0, width: 300, height: 75)

        cell.update(with: BalanceHeader.ViewModel(totalTitle: "Total Balance",
                                                      totalDescription: "1234",
                                                      availableTitle: "Available Balance",
                                                      availableDescription: "1234",
                                                      titleFont: nil,
                                                      descriptionFont: nil))

        cell.layoutSubviews()

        assertSnapshot(matching: cell, as: .image, record: self.recordMode)
    }
}
