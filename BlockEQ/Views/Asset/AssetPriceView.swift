//
//  AssetPriceView.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-12-24.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Foundation

final class AssetPriceView: UIView, NibLoadableView {
    @IBOutlet var view: UIView!
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var amountLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!

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
        let nibView: UIView = NibLoader<UIView>(nibName: AssetPriceView.nibName).loadView(owner: self)
        self.addSubview(nibView)
        self.constrainViewToAllEdges(nibView)
    }

    func setupStyle() {
        stackView.backgroundColor = .clear
        amountLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        priceLabel.font = UIFont.systemFont(ofSize: 9, weight: .regular)
    }

    func update(with viewModel: ViewModel) {
        amountLabel.text = viewModel.amount
        priceLabel.text = viewModel.price
    }
}

extension AssetPriceView {
    struct ViewModel {
        var amount: String
        var price: String
    }
}
