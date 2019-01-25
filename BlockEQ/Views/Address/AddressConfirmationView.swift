//
//  AddressConfirmationView.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2019-01-28.
//  Copyright © 2019 BlockEQ. All rights reserved.
//

import Reusable

@IBDesignable
final class AddressConfirmationView: UIView, NibOwnerLoadable {
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var addressLabel: AddressLabel!

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
        topBorder(with: ViewColors.viewBorderColor, width: 1)
        bottomBorder(with: ViewColors.viewBorderColor, width: 1)

        descriptionLabel.text = "VERIFICATION_DESCRIPTION".localized()
        descriptionLabel.textColor = TextColors.greyLabelText
        descriptionLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
    }

    func update(with viewModel: ViewModel) {
        descriptionLabel.text = viewModel.labelText
        addressLabel.update(with: viewModel.addressText)
    }

    override func prepareForInterfaceBuilder() {
        setupView()
        update(with: ViewModel(labelText: "VERIFICATION_DESCRIPTION".localized(),
                               addressText: "TEST_ADDRESS".localized()))
    }
}

extension AddressConfirmationView {
    struct ViewModel {
        let labelText: String
        let addressText: String
    }
}
