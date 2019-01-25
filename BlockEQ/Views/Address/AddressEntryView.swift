//
//  AddressEntryView.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2019-01-28.
//  Copyright © 2019 BlockEQ. All rights reserved.
//

import Reusable

protocol AddressEntryViewDelegate: AnyObject {
    func selectedPrimaryAction(_ view: AddressEntryView)
    func selectedAddressAction(_ view: AddressEntryView)
    func updatedAddressText(_ view: AddressEntryView, text: String?)
    func stoppedEditingAddress(_ view: AddressEntryView, text: String?)
}

final class AddressEntryView: UIView, NibOwnerLoadable {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var addressButton: AppButton!
    @IBOutlet weak var nextButton: AppButton!

    weak var delegate: AddressEntryViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.loadNibContent()
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.loadNibContent()
        setupView()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    func setupView() {
        self.topBorder(with: ViewColors.viewBorderColor, width: 1)
        self.bottomBorder(with: ViewColors.viewBorderColor, width: 1)

        titleLabel.textColor = TextColors.greyLabelText
        addressTextField.textColor = TextColors.greyTextFieldText
        addressButton.tintColor = Colors.white

        titleLabel.text = "SEND_TO".localized().uppercased()
        nextButton.setTitle("ADDRESS_ENTRY_BUTTON_LABEL".localized(), for: .normal)
        addressButton.setImage(UIImage(named: "camera"), for: .normal)

        addressTextField.placeholder = "DESTINATION_ADDRESS_PLACEHOLDER".localized()
        addressTextField.clearButtonMode = .whileEditing
    }

    func update(with viewModel: ViewModel) {
        let image = viewModel.addressButtonIcon?.withRenderingMode(.alwaysTemplate) ?? UIImage(named: "camera")

        titleLabel.text = viewModel.labelText
        addressTextField.text = viewModel.addressFieldPrefilledText
        addressTextField.placeholder = viewModel.addressFieldPlaceholder

        addressButton.setImage(image, for: .normal)
        nextButton.setTitle(viewModel.primaryButtonTitle, for: .normal)

        nextButton.backgroundColor = viewModel.buttonColor
    }

    func togglePrimaryAction(enabled: Bool) {
        nextButton.isEnabled = enabled
    }
}

// MARK: - IBActions
extension AddressEntryView {
    @IBAction func finishedEditingAddress(_ sender: Any) {
        delegate?.stoppedEditingAddress(self, text: addressTextField.text)
    }

    @IBAction func updatedAddress(_ sender: Any) {
        delegate?.updatedAddressText(self, text: addressTextField.text)
    }

    @IBAction func selectedAddressButton(_ sender: Any) {
        delegate?.selectedAddressAction(self)
    }

    @IBAction func selectedPrimaryButton(_ sender: Any) {
        delegate?.selectedPrimaryAction(self)
    }
}

extension AddressEntryView {
    struct ViewModel {
        let labelText: String
        let primaryButtonTitle: String
        let addressFieldPlaceholder: String?
        let addressFieldPrefilledText: String?
        let addressButtonIcon: UIImage?
        let buttonColor: UIColor?
    }
}
