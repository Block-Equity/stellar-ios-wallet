//
//  AssetPriceView.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-12-24.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Reusable

final class AssetPriceView: UIView, NibOwnerLoadable {
    @IBOutlet var view: UIView!
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var amountLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!

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
        stackView.backgroundColor = .clear

        amountLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        priceLabel.font = UIFont.systemFont(ofSize: 10, weight: .regular)
    }

    func update(with viewModel: ViewModel) {
        amountLabel.text = viewModel.amount
        priceLabel.text = viewModel.price
        priceLabel.isHidden = viewModel.hidePrice

        amountLabel.textColor = viewModel.amountColor ?? Colors.priceDarkGray
        priceLabel.textColor = viewModel.priceColor ?? Colors.priceLightGray
    }
}

extension AssetPriceView {
    struct ViewModel {
        static let empty = ViewModel(amount: "", price: "", hidePrice: true)

        var amount: String
        var price: String
        var hidePrice: Bool
        var amountColor: UIColor?
        var priceColor: UIColor?

        init(amount: String, price: String, hidePrice: Bool) {
            self.init(amount: amount,
                      price: price,
                      hidePrice: hidePrice,
                      amountColor: nil,
                      priceColor: nil)
        }

        init(amount: String, price: String) {
            self.init(amount: amount, price: price, hidePrice: price.isEmpty, amountColor: nil, priceColor: nil)
        }

        init(amount: String, price: String, hidePrice: Bool, amountColor: UIColor?, priceColor: UIColor?) {
            self.amount = amount
            self.price = price
            self.hidePrice = hidePrice
        }
    }
}
