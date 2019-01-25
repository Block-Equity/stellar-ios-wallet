//
//  AddressEntryViewSnapshotTests.swift
//  BlockEQSnapshotTests
//
//  Created by Nick DiZazzo on 2019-01-28.
//  Copyright © 2019 BlockEQ. All rights reserved.
//

@testable import BlockEQ
import SnapshotTesting
import XCTest

final class AddressEntryViewSnapshotTests: XCTestCase, SnapshotTest {
    var recordMode: Bool = false
    var defaultFrame = CGRect(x: 0, y: 0, width: 375, height: 205)

    func testEmptyAddressEntryView() {
        let entryView = AddressEntryView(frame: defaultFrame)

        let viewModel = AddressEntryView.ViewModel(labelText: "SEND TO",
                                                   primaryButtonTitle: "Make It So",
                                                   addressFieldPlaceholder: "Placeholder Text",
                                                   addressFieldPrefilledText: nil,
                                                   addressButtonIcon: nil,
                                                   buttonColor: Colors.primaryDark)

        entryView.update(with: viewModel)

        assertSnapshot(matching: entryView, as: .image, record: self.recordMode)
    }

    func testFilledAddressEntryView() {
        let entryView = AddressEntryView(frame: defaultFrame)

        let viewModel = AddressEntryView.ViewModel(labelText: "FUND DESTINATION",
                                                   primaryButtonTitle: "Close Account",
                                                   addressFieldPlaceholder: nil,
                                                   addressFieldPrefilledText: "GBDBJNAZDG7UGK6XR3AQ2AAPGNTSQ3BPKBJFJMMYUIEDJ45ZFLMPH4G2",
                                                   addressButtonIcon: nil,
                                                   buttonColor: Colors.primaryDark)

        entryView.update(with: viewModel)

        assertSnapshot(matching: entryView, as: .image, record: self.recordMode)
    }

    func testCompressedEmptyAddressEntryView() {
        let entryView = AddressEntryView(frame: CGRect(x: 0, y: 0, width: 320, height: 205))

        let viewModel = AddressEntryView.ViewModel(labelText: "FUND DESTINATION",
                                                   primaryButtonTitle: "Close Account",
                                                   addressFieldPlaceholder: "Placeholder Text",
                                                   addressFieldPrefilledText: nil,
                                                   addressButtonIcon: nil,
                                                   buttonColor: Colors.primaryDark)

        entryView.update(with: viewModel)

        assertSnapshot(matching: entryView, as: .image, record: self.recordMode)
    }

    func testCompressFilledAddressEntryView() {
        let entryView = AddressEntryView(frame: CGRect(x: 0, y: 0, width: 320, height: 205))

        let viewModel = AddressEntryView.ViewModel(labelText: "FUND DESTINATION",
                                                   primaryButtonTitle: "Close Account",
                                                   addressFieldPlaceholder: "Placeholder Text",
                                                   addressFieldPrefilledText: "GBDBJNAZDG7UGK6XR3AQ2AAPGNTSQ3BPKBJFJMMYUIEDJ45ZFLMPH4G2",
                                                   addressButtonIcon: nil,
                                                   buttonColor: Colors.primaryDark)

        entryView.update(with: viewModel)

        assertSnapshot(matching: entryView, as: .image, record: self.recordMode)
    }

    func testCustomAddressIcon() {
        let entryView = AddressEntryView(frame: defaultFrame)

        let viewModel = AddressEntryView.ViewModel(labelText: "FUND DESTINATION",
                                                   primaryButtonTitle: "Close Account",
                                                   addressFieldPlaceholder: "Placeholder Text",
                                                   addressFieldPrefilledText: nil,
                                                   addressButtonIcon: UIImage(named: "send"),
                                                   buttonColor: Colors.red)

        entryView.update(with: viewModel)

        assertSnapshot(matching: entryView, as: .image, record: self.recordMode)
    }

    func testWideLayout() {
        let entryView = AddressEntryView(frame: CGRect(x: 0, y: 0, width: 1024, height: 205))

        let viewModel = AddressEntryView.ViewModel(labelText: "FUND DESTINATION",
                                                   primaryButtonTitle: "Close Account",
                                                   addressFieldPlaceholder: "Placeholder Text",
                                                   addressFieldPrefilledText: nil,
                                                   addressButtonIcon: UIImage(named: "send"),
                                                   buttonColor: Colors.primaryDark)

        entryView.update(with: viewModel)

        assertSnapshot(matching: entryView, as: .image, record: self.recordMode)
    }
}

