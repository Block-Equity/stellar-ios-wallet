//
//  MergeAccountViewControllerSnapshotTests.swift
//  BlockEQSnapshotTests
//
//  Created by Nick DiZazzo on 2019-02-01.
//  Copyright © 2019 BlockEQ. All rights reserved.
//

@testable import BlockEQ
import SnapshotTesting
import XCTest

final class MergeAccountViewControllerSnapshotTests: XCTestCase, SnapshotTest {
    var recordMode = false

    func testMergeAccountViewController() {
        let mergeVC = MergeAccountViewController()
        _ = mergeVC.view

        mergeVC.update(with: "TEST_ADDRESS".localized())

        assertSnapshot(matching: mergeVC, as: .image, record: self.recordMode)
    }

    func testMergeAccountViewControllerWide() {
        let mergeVC = MergeAccountViewController()
        _ = mergeVC.view

        mergeVC.view.frame = CGRect(x: 0, y: 0, width: 768, height: 1024)

        mergeVC.update(with: "TEST_ADDRESS".localized())

        assertSnapshot(matching: mergeVC, as: .image, record: self.recordMode)
    }
}
