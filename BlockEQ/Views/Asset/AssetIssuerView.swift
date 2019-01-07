//
//  IssuerDataView.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-12-24.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Reusable

final class AssetIssuerView: UIView, NibOwnerLoadable {
    @IBOutlet var view: UIView!
    @IBOutlet weak var issuedTitleLabel: UILabel!
    @IBOutlet weak var issuedDescriptionLabel: UILabel!
    @IBOutlet weak var addressTitleLabel: UILabel!
    @IBOutlet weak var addressDescriptionLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.loadNibContent()
        setupStyle()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.loadNibContent()
        setupStyle()
    }

    func setupStyle() {
        issuedTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        addressTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)

        issuedDescriptionLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        addressDescriptionLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        addressDescriptionLabel.lineBreakMode = .byTruncatingMiddle
        addressDescriptionLabel.textAlignment = .left
        issuedDescriptionLabel.textAlignment = .left
    }

    func update(with viewModel: ViewModel) {
        issuedTitleLabel.text = viewModel.issuerTitle
        issuedDescriptionLabel.text = viewModel.issuerDescription
        addressTitleLabel.text = viewModel.addressTitle
        addressDescriptionLabel.text = viewModel.addressDescription
    }
}

extension AssetIssuerView {
    struct ViewModel {
        static let empty = ViewModel(issuerTitle: "", issuerDescription: "", addressTitle: "", addressDescription: "")

        var issuerTitle: String
        var issuerDescription: String
        var addressTitle: String
        var addressDescription: String
    }
}
