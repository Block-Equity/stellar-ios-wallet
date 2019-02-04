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

    var sourceAddress: StellarAddress?
    var verificationAddress: StellarAddress?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard let address = sourceAddress else { return }
        self.update(with: address, destinationAddress: verificationAddress)
    }

    func setupView() {
        addressEntryView.delegate = self
        scrollView.alwaysBounceVertical = true

        informationLabel.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        informationLabel.textColor = TextColors.greyTest

        title = "MERGE_SCREEN_TITLE".localized()
    }

    func update(with source: StellarAddress, destinationAddress: StellarAddress?) {
        sourceAddress = source
        verificationAddress = destinationAddress

        let entryVM = AddressEntryView.ViewModel(labelText: "DESTINATION_ADDRESS_TITLE".localized().uppercased(),
                                                 primaryButtonTitle: "CLOSE_ACCOUNT_BUTTON_TITLE".localized(),
                                                 addressFieldPlaceholder: "DESTINATION_ADDRESS_PLACEHOLDER".localized(),
                                                 addressFieldPrefilledText: destinationAddress?.string,
                                                 addressButtonIcon: nil,
                                                 buttonColor: Colors.red)

        let accountVM = AddressConfirmationView.ViewModel(labelText: "VERIFICATION_DESCRIPTION".localized(),
                                                          addressText: source.string)

        addressEntryView?.update(with: entryVM)
        verificationView?.update(with: accountVM)
    }

    func toggleCloseAction(enabled: Bool) {
        self.addressEntryView.togglePrimaryAction(enabled: enabled)
    }

    func verify(address text: String?) -> StellarAddress? {
        return StellarAddress(text)
    }

    func displayConfirmation(for address: StellarAddress) {
        let cancelAction = UIAlertAction(title: "CANCEL_ACTION".localized(), style: .cancel, handler: nil)
        let submitAction = UIAlertAction(title: "MERGE_TITLE".localized(), style: .destructive, handler: { _ in
            self.delegate?.requestedMergeAccount(self, destination: address)
        })

        let alert = UIAlertController(title: "MERGE_ACCOUNT_TITLE".localized(),
                                      message: "MERGE_ACCOUNT_MESSAGE".localized(),
                                      preferredStyle: .alert)

        alert.addAction(cancelAction)
        alert.addAction(submitAction)

        self.present(alert, animated: true, completion: nil)
    }

    func showHud() {
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.label.text = "MERGING_ACCOUNT_MESSAGE".localized()
        hud.mode = .indeterminate
    }

    func hideHud() {
        MBProgressHUD.hide(for: view, animated: true)
    }
}

// MARK: - AddressEntryViewDelegate
extension MergeAccountViewController: AddressEntryViewDelegate {
    func selectedPrimaryAction(_ view: AddressEntryView, text: String?) {
        verificationAddress = verify(address: text)

        guard let address = verificationAddress else {
            addressEntryView.invalid()
            return
        }

        guard sourceAddress != address else {
            UIAlertController.simpleAlert(title: "ACCOUNT_MERGE_MALFORMED_TITLE".localized(),
                                          message: "ACCOUNT_MERGE_MALFORMED_MESSAGE".localized(),
                                          presentingViewController: self)
            return
        }

        let exchange: Exchange? = AddressResolver.resolve(address: address)

        guard exchange == nil else {
            UIAlertController.simpleAlert(title: "ACCOUNT_MERGE_EXCHANGE_TITLE".localized(),
                                          message: "ACCOUNT_MERGE_EXCHANGE_MESSAGE".localized(),
                                          presentingViewController: self)
            return
        }

        displayConfirmation(for: address)
    }

    func selectedAddressAction(_ view: AddressEntryView) {
        delegate?.requestedQRScanner(self)
    }

    func updatedAddressText(_ view: AddressEntryView, text: String?) {
        verificationAddress = verify(address: text)
    }

    func stoppedEditingAddress(_ view: AddressEntryView, text: String?) {
        verificationAddress = verify(address: text)
    }
}

// MARK: - FrameworkErrorPresentable
extension MergeAccountViewController: FrameworkErrorPresentable { }
