//
//  MyOffersViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-05-23.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk
import StellarHub

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
        tableView.register(cellType: OrderBookEmptyCell.self)
        tableView.register(cellType: OffersCell.self)
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

    func displayCancelFailure(_ error: FrameworkError) {
        self.hideHud()

        let fallbackTitle = "ERROR_TITLE".localized()
        let fallbackMessage = "CANCEL_TRADE_ERROR".localized()
        self.displayFrameworkError(error, fallbackData: (title: fallbackTitle, message: fallbackMessage))
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
        let sellingMetadata = AssetMetadata(shortCode: offer.sellingAsset.shortCode)
        let buyingMetadata = AssetMetadata(shortCode: offer.buyingAsset.shortCode)

        let text = String(format: "SELL_SUMMARY_FORMAT".localized(),
                          offer.amount.displayFormattedString,
                          sellingMetadata.shortCode,
                          offer.value.displayFormattedString,
                          buyingMetadata.shortCode,
                          offer.price.displayFormatted)

        cell.offerLabel.text = text

        return cell
    }

    func emptyOrderBookCell(_ tableView: UITableView, indexPath: IndexPath) -> OrderBookEmptyCell {
        let cell: OrderBookEmptyCell = tableView.dequeueReusableCell(for: indexPath)
        return cell
    }
}

// MARK: - FrameworkErrorPresentable
extension MyOffersViewController: FrameworkErrorPresentable { }

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
