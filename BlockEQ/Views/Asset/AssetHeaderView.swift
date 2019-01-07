//
//  AssetHeaderView.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-12-24.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Reusable

final class AssetHeaderView: UIView, NibOwnerLoadable {
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

        assetImageView.image = UIImage(named: "eth")
        assetNameLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        assetCodeLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
    }

    func update(with viewModel: ViewModel) {
        assetImageView.image = viewModel.image
        assetNameLabel.text = viewModel.assetTitle
        assetCodeLabel.text = viewModel.assetSubtitle

        if viewModel.image == nil {
            assetImageView.isHidden = true
            imageWidthConstraint.constant = 0
//            imageSpacingConstraint.constant = 0
        } else {
            assetImageView.isHidden = false
            imageWidthConstraint.constant = 60
//            imageSpacingConstraint.constant = 15
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
        static let empty = ViewModel(image: nil, assetTitle: "", assetSubtitle: "")

        var image: UIImage?
        var assetTitle: String
        var assetSubtitle: String
    }
}
