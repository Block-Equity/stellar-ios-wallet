//
//  AssetAmountCell.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-12-24.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Foundation

final class AssetAmountCell: UICollectionViewCell, ReusableView, NibLoadableView {
    @IBOutlet var view: UIView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var headerContainer: UIView!
    @IBOutlet weak var priceContainer: UIView!

    let headerView = AssetHeaderView(frame: .zero)
    let priceView = AssetPriceView(frame: .zero)

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
        let nibView: UIView = NibLoader<UIView>(nibName: AssetAmountCell.nibName).loadView(owner: self)
        contentView.addSubview(nibView)
        contentView.constrainViewToAllEdges(nibView)

        headerContainer.addSubview(headerView)
        headerContainer.constrainViewToAllEdges(headerView)

        priceContainer.addSubview(priceView)
        priceContainer.constrainViewToAllEdges(priceView)
    }

    func setupStyle() {
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 5
        cardView.clipsToBounds = false
        cardView.layer.masksToBounds = false
    }

    func update(with viewModel: ViewModel) {
        headerView.update(with: viewModel.headerData)
        priceView.update(with: viewModel.priceData)
    }
}

extension AssetAmountCell {
    struct ViewModel {
        var headerData: AssetHeaderView.ViewModel
        var priceData: AssetPriceView.ViewModel
    }
}
