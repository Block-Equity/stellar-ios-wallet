//
//  OrderBookViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-05-23.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import stellarsdk
import UIKit

class OrderBookViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    var bids: [OrderbookOfferResponse] = []
    var asks: [OrderbookOfferResponse] = []
    var buyAsset: StellarAsset = StellarAsset()
    var sellAsset: StellarAsset = StellarAsset()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    func setupView() {
        let tableViewNib = UINib(nibName: OrderBookCell.cellIdentifier, bundle: nil)
        tableView.register(tableViewNib, forCellReuseIdentifier: OrderBookCell.cellIdentifier)

        tableView.backgroundColor = Colors.lightBackground
    }
    
    func setOrderBook(orderBook: OrderbookResponse, buyAsset: StellarAsset, sellAsset: StellarAsset) {
        self.buyAsset = buyAsset
        self.sellAsset = sellAsset
        
        bids = orderBook.bids
        asks = orderBook.asks
        
        tableView.reloadData()
    }
}

extension OrderBookViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return bids.count
        default:
            return asks.count
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let frame = CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.size.width, height: OrderBookHeaderView.height))
    
        switch section {
        case 0:
            return OrderBookHeaderView(frame: frame, type: .buy, buyAsset: buyAsset.shortCode, sellAsset: sellAsset.shortCode)
        default:
            return OrderBookHeaderView(frame: frame, type: .sell, buyAsset: buyAsset.shortCode, sellAsset: sellAsset.shortCode)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return OrderBookHeaderView.height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: OrderBookCell.cellIdentifier, for: indexPath) as! OrderBookCell
        switch indexPath.section {
        case 0:
            let numerator = Float(bids[indexPath.row].priceR.numerator)
            let denominator = Float(bids[indexPath.row].priceR.denominator)
            cell.option1Label.text = bids[indexPath.row].amount.decimalFormatted()
            cell.option2Label.text = String(denominator/numerator * bids[indexPath.row].amount.floatValue()).decimalFormatted()
            cell.option3Label.text = String(denominator/numerator).decimalFormatted()
        default:
            let numerator = Float(asks[indexPath.row].priceR.numerator)
            let denominator = Float(asks[indexPath.row].priceR.denominator)
            cell.option1Label.text = asks[indexPath.row].price.decimalFormatted()
            cell.option2Label.text = asks[indexPath.row].amount.decimalFormatted() 
            cell.option3Label.text = String(denominator/numerator).decimalFormatted()
        }
        
        return cell
    }
}

extension OrderBookViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return OrderBookCell.rowHeight
    }
}
