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
    @IBOutlet var containerView: UIView!
    @IBOutlet var assetImageView: UIImageView!
    @IBOutlet var assetNameLabel: UILabel!
    @IBOutlet var assetCodeLabel: UILabel!

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
        containerView.backgroundColor = .clear
        assetImageView.image = UIImage(named: "eth")
        assetNameLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        assetCodeLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
    }

    func update(with viewModel: ViewModel) {
        assetImageView.image = viewModel.image ?? UIImage(named: "pts")
        assetNameLabel.text = viewModel.assetTitle
        assetCodeLabel.text = viewModel.assetSubtitle
    }
}

extension AssetHeaderView {
    struct ViewModel {
        var image: UIImage?
        var assetTitle: String
        var assetSubtitle: String
    }
}
