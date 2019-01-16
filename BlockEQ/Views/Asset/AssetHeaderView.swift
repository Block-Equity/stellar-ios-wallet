//
//  AssetHeaderView.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-12-24.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Reusable
import Imaginary

final class AssetHeaderView: UIView, NibOwnerLoadable {
    static let defaultCurrencyIcon = UIImage(named: "currency-generic")

    @IBOutlet var view: UIView!
    @IBOutlet var assetImageView: UIImageView!
    @IBOutlet var assetNameLabel: UILabel!
    @IBOutlet var assetCodeLabel: UILabel!
    @IBOutlet weak var imageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackView: UIStackView!

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
        view.backgroundColor = .clear

        assetImageView.image = AssetHeaderView.defaultCurrencyIcon
        assetNameLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        assetCodeLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
    }

    func update(with viewModel: ViewModel) {
        assetNameLabel.text = viewModel.assetTitle
        assetCodeLabel.text = viewModel.assetSubtitle

        assetImageView.isHidden = false
        imageWidthConstraint.constant = 50

        if viewModel.imageURL == nil && viewModel.image == nil {
            assetImageView.isHidden = true
            imageWidthConstraint.constant = 0
        } else if let url = viewModel.imageURL {
            assetImageView.setImage(url: url, placeholder: AssetHeaderView.defaultCurrencyIcon)
        } else if let image = viewModel.image {
            assetImageView.image = image
        } else if viewModel.image == nil {
            assetImageView.image = AssetHeaderView.defaultCurrencyIcon
        }

        if viewModel.assetSubtitle.isEmpty {
            assetCodeLabel.isHidden = true
        } else {
            assetCodeLabel.isHidden = false
        }
    }
}

extension AssetHeaderView {
    struct ViewModel {
        static let empty = ViewModel(image: AssetHeaderView.defaultCurrencyIcon,
                                     imageURL: nil,
                                     assetTitle: "",
                                     assetSubtitle: "")

        var image: UIImage?
        var imageURL: URL?
        var assetTitle: String
        var assetSubtitle: String
    }
}
