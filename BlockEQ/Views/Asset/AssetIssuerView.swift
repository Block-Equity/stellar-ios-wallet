//
//  IssuerDataView.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-12-24.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Foundation

final class AssetIssuerView: UIView, NibLoadableView {
    @IBOutlet var view: UIView!
    @IBOutlet weak var labelContainer: UIStackView!
    @IBOutlet weak var issuedTitleLabel: UILabel!
    @IBOutlet weak var issuedDescriptionLabel: UILabel!
    @IBOutlet weak var addressTitleLabel: UILabel!
    @IBOutlet weak var addressDescriptionLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupStyle()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
        setupStyle()
    }

    func setupView() {
        let nibView: UIView = NibLoader<UIView>(nibName: AssetIssuerView.nibName).loadView(owner: self)
        self.addSubview(nibView)
        self.constrainViewToAllEdges(nibView)
    }

    func setupStyle() {
        labelContainer.spacing = 10
        issuedTitleLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        addressTitleLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)

        issuedDescriptionLabel.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        addressDescriptionLabel.font = UIFont.systemFont(ofSize: 9, weight: .regular)
        addressDescriptionLabel.lineBreakMode = .byTruncatingMiddle
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
        var issuerTitle: String
        var issuerDescription: String
        var addressTitle: String
        var addressDescription: String
    }
}
