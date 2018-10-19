//
//  MyOffersViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-05-23.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk
import StellarAccountService

protocol MyOffersViewControllerDelegate: AnyObject {
    func cancelTrade(offerId: Int, assetPair: StellarAssetPair, price: Price)
}

class MyOffersViewController: UIViewController {

    @IBOutlet var tableView: UITableView!

    weak var delegate: MyOffersViewControllerDelegate?

    var offers: [StellarAccountOffer] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    func setupView() {
        tableView.registerCell(type: OrderBookEmptyCell.self)
        tableView.registerCell(type: OffersCell.self)
        tableView.backgroundColor = Colors.lightBackground
    }

    func refreshView() {
        guard self.isViewLoaded else { return }
        self.tableView.reloadData()
    }

    func showHud() {
        let hud = MBProgressHUD.showAdded(to: (navigationController?.view)!, animated: true)
        hud.label.text = "CANCELLING_OFFER".localized()
        hud.mode = .indeterminate
    }

    func hideHud() {
        MBProgressHUD.hide(for: (navigationController?.view)!, animated: true)
    }

    func displayCancelFailure() {
        self.hideHud()

        UIAlertController.simpleAlert(title: "ERROR_TITLE".localized(),
                                      message: "CANCEL_TRADE_ERROR".localized(),
                                      presentingViewController: self)
    }

    func setOffers(_ offers: [StellarAccountOffer]) {
        self.offers = offers
        self.refreshView()
    }

    func remove(offerId: Int) {
        hideHud()

        if let offerIndex = offers.firstIndex(where: { offer -> Bool in
            return offer.identifier == offerId
        }) {
            self.offers.remove(at: offerIndex)
            self.tableView.reloadData()
        }
    }
}

// MARK: - UITableViewDataSource
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
                          offer.amount.displayFormattedString,
                          Assets.cellDisplay(shortCode: offer.sellingAsset.assetCode),
                          offer.value.displayFormattedString,
                          Assets.cellDisplay(shortCode: offer.buyingAsset.assetCode),
                          offer.price.decimalFormatted)

        cell.offerLabel.text = text

        return cell
    }

    func emptyOrderBookCell(_ tableView: UITableView, indexPath: IndexPath) -> OrderBookEmptyCell {
        let cell: OrderBookEmptyCell = tableView.dequeueReusableCell(for: indexPath)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension MyOffersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return offers.count > 0 ? OffersCell.rowHeight : OrderBookEmptyCell.rowHeight
    }
}

// MARK: - OffersCellDelegate
extension MyOffersViewController: OffersCellDelegate {
    func deleteOffer(indexPath: IndexPath) {
        showHud()

        let offer = offers[indexPath.row]

        let assetPair = StellarAssetPair(buying: offer.buyingAsset, selling: offer.sellingAsset)
        let offerPrice = Price(numerator: offer.numerator, denominator: offer.denominator)
        delegate?.cancelTrade(offerId: offer.identifier, assetPair: assetPair, price: offerPrice)
    }
}
