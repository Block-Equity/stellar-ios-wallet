//
//  OrderBookHeaderView.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-05-27.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Reusable

enum OrderType: Int {
    case buy
    case sell
}

class OrderBookHeaderView: UIView, NibOwnerLoadable {

    @IBOutlet weak var option1Label: UILabel!
    @IBOutlet weak var option2Label: UILabel!
    @IBOutlet weak var option3Label: UILabel!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var view: UIView!

    static let height: CGFloat = 71.0

    init(frame: CGRect, type: OrderType, buyAsset: String, sellAsset: String) {
        super.init(frame: frame)
        self.loadNibContent()
        setupView(type: type, buyAsset: buyAsset, sellAsset: sellAsset)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.loadNibContent()
        setupView(type: .buy, buyAsset: "", sellAsset: "")
    }

    private func setupView(type: OrderType, buyAsset: String, sellAsset: String) {
        switch type {
        case .buy:
            titleView.backgroundColor = Colors.green
            titleLabel.text = "Buy Offers"
        case .sell:
            titleView.backgroundColor = Colors.red
            titleLabel.text = "Sell Offers"
        }

        option1Label.text = "\(buyAsset) Price"
        option2Label.text = "\(sellAsset) Amount"
        option3Label.text = "\(buyAsset) Value"

        option1Label.textColor = Colors.darkGray
        option2Label.textColor = Colors.darkGray
        option3Label.textColor = Colors.darkGray
    }
}
