//
//  AssetIssuerCell.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-12-24.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Foundation

final class AssetIssuerCell: UICollectionViewCell, ReusableView, NibLoadableView {
    @IBOutlet var view: UIView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var headerContainer: UIView!
    @IBOutlet weak var priceContainer: UIView!
    @IBOutlet weak var issuerContainer: UIView!
    @IBOutlet weak var assetContainer: UIView!

    let headerView = AssetHeaderView(frame: .zero)
    let priceView = AssetPriceView(frame: .zero)
    let issuerView = AssetIssuerView(frame: .zero)

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
        let nibView: UIView = NibLoader<UIView>(nibName: AssetIssuerCell.nibName).loadView(owner: self)
        contentView.addSubview(nibView)
        contentView.constrainViewToAllEdges(nibView)

        headerContainer.addSubview(headerView)
        headerContainer.constrainViewToAllEdges(headerView)

        priceContainer.addSubview(priceView)
        priceContainer.constrainViewToAllEdges(priceView)

        issuerContainer.addSubview(issuerView)
        issuerContainer.constrainViewToAllEdges(issuerView)
    }

    func setupStyle() {
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 5
        cardView.clipsToBounds = false
        cardView.layer.masksToBounds = false

        headerContainer.backgroundColor = .clear
        priceContainer.backgroundColor = .clear
        issuerContainer.backgroundColor = .clear
        assetContainer.backgroundColor = .clear
    }

    func update(with viewModel: ViewModel) {
        headerView.update(with: viewModel.headerData)
        priceView.update(with: viewModel.priceData)
        issuerView.update(with: viewModel.issuerData)
    }
}

extension AssetIssuerCell {
    struct ViewModel {
        var headerData: AssetHeaderView.ViewModel
        var priceData: AssetPriceView.ViewModel
        var issuerData: AssetIssuerView.ViewModel
    }
}

