//
//  AssetHeaderView.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-12-24.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Foundation

final class AssetHeaderView: UIView, NibLoadableView {
    @IBOutlet var view: UIView!
    @IBOutlet var containerView: UIView!
    @IBOutlet var assetImageView: UIImageView!
    @IBOutlet var assetNameLabel: UILabel!
    @IBOutlet var assetCodeLabel: UILabel!

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
        let nibView: UIView = NibLoader<UIView>(nibName: AssetHeaderView.nibName).loadView(owner: self)
        self.addSubview(nibView)
        self.constrainViewToAllEdges(nibView)
    }

    func setupStyle() {
        containerView.backgroundColor = .clear
        assetImageView.image = UIImage(named: "eth")
        assetNameLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        assetCodeLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
    }

    func update(with viewModel: ViewModel) {
        assetImageView.image = viewModel.image ?? UIImage(named: "pts")
        assetNameLabel.text = viewModel.assetName
        assetCodeLabel.text = viewModel.assetCode
    }
}

extension AssetHeaderView {
    struct ViewModel {
        var image: UIImage?
        var assetName: String
        var assetCode: String
    }
}
