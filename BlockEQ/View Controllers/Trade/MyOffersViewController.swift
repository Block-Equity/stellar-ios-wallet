//
//  MyOffersViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-05-23.
//  Copyright © 2018 BlockEQ. All rights reserved.
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

        let sellingAsset = StellarAsset(assetType: offer.selling.assetType,
                                        assetCode: offer.selling.assetCode,
                                        assetIssuer: offer.selling.assetIssuer,
                                        balance: "")

        let buyingAsset = StellarAsset(assetType: offer.buying.assetType,
                                       assetCode: offer.buying.assetCode,
                                       assetIssuer: offer.buying.assetIssuer,
                                       balance: "")

        TradeOperation.postTrade(amount: 0.0000000,
                                 price: (numerator: offer.priceR.numerator, denominator: offer.priceR.denominator),
                                 asset: (selling: sellingAsset, buying: buyingAsset),
                                 offerId: offer.id) { completed in
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
        return offers.count > 0 ? offers.count : 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return offers.count > 0 ?
            offerCell(tableView, indexPath: indexPath) : emptyOrderBookCell(tableView, indexPath: indexPath)
    }

    func offerCell(_ tableView: UITableView, indexPath: IndexPath) -> OffersCell {
        let cell: OffersCell = tableView.dequeueReusableCell(for: indexPath)
        cell.indexPath = indexPath
        cell.delegate = self

        let offer = offers[indexPath.row]

        let text = String(format: "SELL_SUMMARY_FORMAT".localized(),
                          offer.amount.decimalFormatted(),
                          Assets.cellDisplay(shortCode: offer.selling.assetCode),
                          String(Float(offer.amount)! * Float(offer.price)!).decimalFormatted(),
                          Assets.cellDisplay(shortCode: offer.buying.assetCode),
                          offer.price.decimalFormatted())

        cell.offerLabel.text = text

        return cell
    }

    func emptyOrderBookCell(_ tableView: UITableView, indexPath: IndexPath) -> OrderBookEmptyCell {
        let cell: OrderBookEmptyCell = tableView.dequeueReusableCell(for: indexPath)
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
