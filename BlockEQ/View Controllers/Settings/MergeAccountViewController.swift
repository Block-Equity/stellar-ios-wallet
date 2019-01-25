//
//  MergeAccountViewController.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2019-02-01.
//  Copyright © 2019 BlockEQ. All rights reserved.
//

import StellarHub

protocol MergeAccountViewControllerDelegate: AnyObject {
    func requestedMergeAccount(_ viewController: MergeAccountViewController, destination: StellarAddress)
    func requestedQRScanner(_ viewController: MergeAccountViewController)
}

final class MergeAccountViewController: UIViewController {
    @IBOutlet private weak var verificationView: AddressConfirmationView!
    @IBOutlet private weak var addressEntryView: AddressEntryView!
    @IBOutlet private weak var informationLabel: UILabel!
    @IBOutlet private weak var scrollView: UIScrollView!

    weak var delegate: MergeAccountViewControllerDelegate?

    var verificationAddress: StellarAddress?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    func setupView() {
        addressEntryView.delegate = self
        scrollView.alwaysBounceVertical = true

        let defaultVerification = AddressConfirmationView.ViewModel(labelText: "VERIFICATION_DESCRIPTION".localized(),
                                                                    addressText: "ACCOUNT ADDRESS")

        let entryVM = AddressEntryView.ViewModel(labelText: "DESTINATION_ADDRESS_TITLE".localized().uppercased(),
                                                 primaryButtonTitle: "CLOSE_ACCOUNT_BUTTON_TITLE".localized(),
                                                 addressFieldPlaceholder: "DESTINATION_ADDRESS_PLACEHOLDER".localized(),
                                                 addressFieldPrefilledText: nil,
                                                 addressButtonIcon: nil,
                                                 buttonColor: Colors.red)

        verificationView.update(with: defaultVerification)
        addressEntryView.update(with: entryVM)

        informationLabel.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        informationLabel.textColor = TextColors.greyTest
    }

    func update(with address: String) {
        verificationView.update(with:
            AddressConfirmationView.ViewModel(labelText: "VERIFICATION_DESCRIPTION".localized(), addressText: address)
        )
    }

    func toggleCloseAction(enabled: Bool) {
        self.addressEntryView.togglePrimaryAction(enabled: enabled)
    }

    func verify(address text: String?) {
        verificationAddress = StellarAddress(text)
        toggleCloseAction(enabled: verificationAddress != nil)
    }
}

extension MergeAccountViewController: AddressEntryViewDelegate {
    func selectedPrimaryAction(_ view: AddressEntryView) {
        guard let address = verificationAddress else {
            print("some error")
            return
        }

        delegate?.requestedMergeAccount(self, destination: address)
    }

    func selectedAddressAction(_ view: AddressEntryView) {
        delegate?.requestedQRScanner(self)
    }

    func updatedAddressText(_ view: AddressEntryView, text: String?) {
        verify(address: text)
    }

    func stoppedEditingAddress(_ view: AddressEntryView, text: String?) {
        verify(address: text)
    }
}
