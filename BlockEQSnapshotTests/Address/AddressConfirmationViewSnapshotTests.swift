//
//  AddressConfirmationViewSnapshotTests.swift
//  BlockEQSnapshotTests
//
//  Created by Nick DiZazzo on 2019-01-28.
//  Copyright © 2019 BlockEQ. All rights reserved.
//

@testable import BlockEQ
import SnapshotTesting
import XCTest

final class AddressConfirmationViewSnapshotTests: XCTestCase, SnapshotTest {
    var recordMode: Bool = false
    var defaultFrame = CGRect(x: 0, y: 0, width: 375, height: 105)

    func testConfirmationView() {
        let view = AddressConfirmationView(frame: CGRect(x: 0, y: 0, width: 375, height: 105))
        let viewModel = AddressConfirmationView.ViewModel(labelText: "Please verify that the address below is the account you intend to close.",
                                                          addressText: "GCCD6AJOYZCUAQLX32ZJF2MKFFAUJ53PVCFQI3RHWKL3V47QYE2BNAUT")
        view.update(with: viewModel)

        assertSnapshot(matching: view, as: .image, record: self.recordMode)
    }

    func testCompressedView() {
        let view = AddressConfirmationView(frame: CGRect(x: 0, y: 0, width: 320, height: 105))
        let viewModel = AddressConfirmationView.ViewModel(labelText: "Please verify that the address below is the account you intend to close.",
                                                          addressText: "GCCD6AJOYZCUAQLX32ZJF2MKFFAUJ53PVCFQI3RHWKL3V47QYE2BNAUT")
        view.update(with: viewModel)

        assertSnapshot(matching: view, as: .image, record: self.recordMode)
    }

    func testWideView() {
        let view = AddressConfirmationView(frame: CGRect(x: 0, y: 0, width: 768, height: 105))
        let viewModel = AddressConfirmationView.ViewModel(labelText: "Please verify that the address below is the account you intend to close.",
                                                          addressText: "GCCD6AJOYZCUAQLX32ZJF2MKFFAUJ53PVCFQI3RHWKL3V47QYE2BNAUT")
        view.update(with: viewModel)

        assertSnapshot(matching: view, as: .image, record: self.recordMode)
    }
}
