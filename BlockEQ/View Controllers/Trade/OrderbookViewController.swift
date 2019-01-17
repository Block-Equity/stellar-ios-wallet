//
//  OrderBookViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-05-23.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk
import StellarHub

protocol OrderbookViewControllerDelegate: AnyObject {
    func requestedTogglePeriodicUpdates(enabled: Bool)
}

final class OrderbookViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var tableHeaderLabel: UILabel!
    @IBOutlet var tableHeaderView: UIView!

    var orderbook: StellarOrderbook? {
        didSet {
            guard let orderbook = orderbook else { return }
            self.buyAsset = orderbook.pair.buying
            self.sellAsset = orderbook.pair.selling
            self.bids = orderbook.bids
            self.asks = orderbook.asks
        }
    }

    weak var delegate: OrderbookViewControllerDelegate?
    var bids: [StellarOrderbookOffer] = []
    var asks: [StellarOrderbookOffer] = []
    var buyAsset = StellarAsset.lumens
    var sellAsset = StellarAsset.lumens

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshView()
        delegate?.requestedTogglePeriodicUpdates(enabled: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.requestedTogglePeriodicUpdates(enabled: true)
    }

    func setupView() {
        tableView.register(cellType: OrderBookCell.self)
        tableView.register(cellType: OrderBookEmptyCell.self)

        tableView.backgroundColor = Colors.lightBackground
        tableHeaderLabel.textColor = Colors.blueGray
        tableHeaderView.backgroundColor = Colors.white
    }

    func refreshView() {
        guard isViewLoaded else { return }
        tableHeaderLabel.text = "\(sellAsset.shortCode) - \(buyAsset.shortCode)"
        tableView.reloadData()
    }

    func setOrderBook(orderbook: StellarOrderbook) {
        self.orderbook = orderbook
        refreshView()
    }
}

// MARK: - UITableViewDataSource
extension OrderbookViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return StellarOrderbook.OrderBookType.all.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = StellarOrderbook.OrderBookType(rawValue: section) else { return 1 }

        switch section {
        case .bid: return bids.count > 0 ? bids.count : 1
        default: return asks.count > 0 ? asks.count : 1
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let section = StellarOrderbook.OrderBookType(rawValue: section) else { return nil }

        let size = CGSize(width: UIScreen.main.bounds.size.width, height: OrderBookHeaderView.height)
        let frame = CGRect(origin: .zero, size: size)
        let type: OrderType = section == .bid ? .buy : .sell

        return OrderBookHeaderView(frame: frame,
                                   type: type,
                                   buyAsset: buyAsset.shortCode,
                                   sellAsset: sellAsset.shortCode)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return OrderBookHeaderView.height
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let section = StellarOrderbook.OrderBookType(rawValue: indexPath.section) {
            switch section {
            case .bid:
                if bids.count > 0 {
                    return bidOrderBookCell(indexPath: indexPath)
                }
            default:
                if asks.count > 0 {
                    return askOrderBookCell(indexPath: indexPath)
                }
            }
        }

        let emptyCell = emptyOrderBookCell(indexPath: indexPath)
        return emptyCell
    }

    func bidOrderBookCell(indexPath: IndexPath) -> OrderBookCell {
        let cell: OrderBookCell = tableView.dequeueReusableCell(for: indexPath)

        let item = bids[indexPath.row]
        let numerator = Decimal(item.numerator)
        let denominator = Decimal(item.denominator)
        let result = denominator / numerator * item.amount.decimalValue

        cell.option1Label.text = item.price.tradeFormatted
        cell.option2Label.text = result.tradeFormattedString
        cell.option3Label.text = item.amount.tradeFormatted

        return cell
    }

    func askOrderBookCell(indexPath: IndexPath) -> OrderBookCell {
        let cell: OrderBookCell = tableView.dequeueReusableCell(for: indexPath)

        let item = asks[indexPath.row]
        cell.option1Label.text = item.price.tradeFormatted
        cell.option2Label.text = item.amount.tradeFormatted
        cell.option3Label.text = item.value.tradeFormattedString

        return cell
    }

    func emptyOrderBookCell(indexPath: IndexPath) -> OrderBookEmptyCell {
        let cell: OrderBookEmptyCell = tableView.dequeueReusableCell(for: indexPath)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension OrderbookViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let section = StellarOrderbook.OrderBookType(rawValue: indexPath.section) else { return 0 }

        switch section {
        case .bid where bids.count > 0: return OrderBookCell.rowHeight
        case .ask where asks.count > 0 : return OrderBookCell.rowHeight
        default: return OrderBookEmptyCell.rowHeight
        }
    }
}
