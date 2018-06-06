//
//  OrderBookViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-05-23.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import stellarsdk
import UIKit

enum OrderBookType: Int {
    case bid
    case ask
    
    static var all: [OrderBookType] {
        return [.bid, .ask]
    }
}

class OrderBookViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var tableHeaderLabel: UILabel!
    @IBOutlet var tableHeaderView: UIView!
    
    var bids: [OrderbookOfferResponse] = []
    var asks: [OrderbookOfferResponse] = []
    var buyAsset: StellarAsset = StellarAsset()
    var sellAsset: StellarAsset = StellarAsset()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    func setupView() {
        let orderBookNib = UINib(nibName: OrderBookCell.cellIdentifier, bundle: nil)
        tableView.register(orderBookNib, forCellReuseIdentifier: OrderBookCell.cellIdentifier)
        
        let orderBookEmptyNib = UINib(nibName: OrderBookEmptyCell.cellIdentifier, bundle: nil)
        tableView.register(orderBookEmptyNib, forCellReuseIdentifier: OrderBookEmptyCell.cellIdentifier)

        tableView.backgroundColor = Colors.lightBackground
        tableHeaderLabel.textColor = Colors.blueGray
        tableHeaderView.backgroundColor = Colors.white
    }
    
    func setOrderBook(orderBook: OrderbookResponse, buyAsset: StellarAsset, sellAsset: StellarAsset) {
        self.buyAsset = buyAsset
        self.sellAsset = sellAsset
        
        bids = orderBook.bids
        asks = orderBook.asks
        
        tableView.reloadData()
        
        tableHeaderLabel.text = "\(sellAsset.shortCode) - \(buyAsset.shortCode)"
    }
}

extension OrderBookViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return OrderBookType.all.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case OrderBookType.bid.rawValue:
            if bids.count > 0 {
                return bids.count
            }
            
        default:
            if asks.count > 0 {
                return asks.count
            }
        }
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let frame = CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.size.width, height: OrderBookHeaderView.height))
    
        switch section {
        case OrderBookType.bid.rawValue:
            return OrderBookHeaderView(frame: frame, type: .buy, buyAsset: buyAsset.shortCode, sellAsset: sellAsset.shortCode)
        default:
            return OrderBookHeaderView(frame: frame, type: .sell, buyAsset: buyAsset.shortCode, sellAsset: sellAsset.shortCode)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return OrderBookHeaderView.height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case OrderBookType.bid.rawValue:
            if bids.count > 0 {
                return bidOrderBookCell(indexPath: indexPath)
            }
            
        default:
            if asks.count > 0 {
                return askOrderBookCell(indexPath: indexPath)
            }
        }
        
        return emptyOrderBookCell(indexPath: indexPath)
    }
    
    func bidOrderBookCell(indexPath: IndexPath) -> OrderBookCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: OrderBookCell.cellIdentifier, for: indexPath) as! OrderBookCell
        
        let numerator = Float(bids[indexPath.row].priceR.numerator)
        let denominator = Float(bids[indexPath.row].priceR.denominator)
        cell.option1Label.text = bids[indexPath.row].price.decimalFormatted()
        cell.option2Label.text = String(denominator/numerator * bids[indexPath.row].amount.floatValue()).decimalFormatted()
        cell.option3Label.text = bids[indexPath.row].amount.decimalFormatted()
        
        return cell
    }
    
    func askOrderBookCell(indexPath: IndexPath) -> OrderBookCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: OrderBookCell.cellIdentifier, for: indexPath) as! OrderBookCell
        
        cell.option1Label.text = asks[indexPath.row].price.decimalFormatted()
        cell.option2Label.text = asks[indexPath.row].amount.decimalFormatted()
        cell.option3Label.text = String(Float(asks[indexPath.row].price)! * Float(asks[indexPath.row].amount)!).decimalFormatted()
        
        return cell
    }
    
    func emptyOrderBookCell(indexPath: IndexPath) -> OrderBookEmptyCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: OrderBookEmptyCell.cellIdentifier, for: indexPath) as! OrderBookEmptyCell
        return cell
    }
}

extension OrderBookViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case OrderBookType.bid.rawValue:
            if bids.count > 0 {
                return OrderBookCell.rowHeight
            }
            
        default:
            if asks.count > 0 {
                return OrderBookCell.rowHeight
            }
        }
        return OrderBookEmptyCell.rowHeight
    }
}
