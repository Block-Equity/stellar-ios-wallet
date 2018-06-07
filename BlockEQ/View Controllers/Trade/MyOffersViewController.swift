//
//  MyOffersViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-05-23.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import stellarsdk
import UIKit

class MyOffersViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    var offers: [OfferResponse] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    func setupView() {
        let offerNib = UINib(nibName: OffersCell.cellIdentifier, bundle: nil)
        tableView.register(offerNib, forCellReuseIdentifier: OffersCell.cellIdentifier)
        
        let orderBookEmptyNib = UINib(nibName: OrderBookEmptyCell.cellIdentifier, bundle: nil)
        tableView.register(orderBookEmptyNib, forCellReuseIdentifier: OrderBookEmptyCell.cellIdentifier)
        
        tableView.backgroundColor = Colors.lightBackground
    }
    
    func setOffers(offers: PageResponse<OfferResponse>) {
        self.offers = offers.records
        tableView.reloadData()
    }
    
    func cancelOffer(indexPath: IndexPath) {
        showHud()
        
        let offer = offers[indexPath.row]
        
        let sellingAsset = StellarAsset(assetType: offer.selling.assetType, assetCode: offer.selling.assetCode, assetIssuer: offer.selling.assetIssuer, balance: "")
        
        let buyingAsset = StellarAsset(assetType: offer.buying.assetType, assetCode: offer.buying.assetCode, assetIssuer: offer.buying.assetIssuer, balance: "")
        
        TradeOperation.postTrade(amount: 0.0000000, numerator: offer.priceR.numerator, denominator: offer.priceR.denominator, sellingAsset: sellingAsset, buyingAsset: buyingAsset, offerId: offer.id) { completed in
            
            if completed {
                self.offers.remove(at: indexPath.row)
                self.tableView.reloadData()
            }
            
            self.hideHud()
        }
    }
    
    func showHud() {
        let hud = MBProgressHUD.showAdded(to: (navigationController?.view)!, animated: true)
        hud.label.text = "Cancelling Offer..."
        hud.mode = .indeterminate
    }
    
    func hideHud() {
        MBProgressHUD.hide(for: (navigationController?.view)!, animated: true)
    }
}

extension MyOffersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if offers.count > 0 {
            return offers.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if offers.count > 0 {
            return offerCell(indexPath: indexPath)
        }
        return emptyOrderBookCell(indexPath: indexPath)
    }
    
    func offerCell(indexPath: IndexPath) -> OffersCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: OffersCell.cellIdentifier, for: indexPath) as! OffersCell
        cell.indexPath = indexPath
        cell.delegate = self
        
        let offer = offers[indexPath.row]
        
        let text = "Sell \(offer.amount.decimalFormatted()) \(Assets.cellDisplay(shortCode: offer.selling.assetCode)) for \(String(Float(offer.amount)! * Float(offer.price)!).decimalFormatted()) \(Assets.cellDisplay(shortCode: offer.buying.assetCode)) at a price of \(offer.price.decimalFormatted())"
        cell.offerLabel.text = text
        
        return cell
    }
    
    func emptyOrderBookCell(indexPath: IndexPath) -> OrderBookEmptyCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: OrderBookEmptyCell.cellIdentifier, for: indexPath) as! OrderBookEmptyCell
        return cell
    }
}

extension MyOffersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if offers.count > 0 {
            return OffersCell.rowHeight
        }
        return OrderBookEmptyCell.rowHeight
    }
}

extension MyOffersViewController: OffersCellDelegate {
    func deleteOffer(indexPath: IndexPath) {
        cancelOffer(indexPath: indexPath)
    }
}
