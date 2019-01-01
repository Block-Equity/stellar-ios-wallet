//
//  BalanceViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-07-12.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import StellarHub

final class BalanceViewController: UIViewController {
    @IBOutlet weak var availableBalanceView: UIView!
    @IBOutlet weak var totalBalanceView: UIView!

    @IBOutlet weak var typeHeaderLabel: UILabel!
    @IBOutlet weak var totalBalanceTitleLabel: UILabel!
    @IBOutlet weak var availableBalanceTitleLabel: UILabel!
    @IBOutlet weak var baseReserveTitleLabel: UILabel!
    @IBOutlet weak var trustlinesTitleLabel: UILabel!
    @IBOutlet weak var offersTitleLabel: UILabel!
    @IBOutlet weak var signersTitleLabel: UILabel!
    @IBOutlet weak var minimumBalanceTitleLabel: UILabel!
    @IBOutlet weak var openTradesTitleLabel: UILabel!

    @IBOutlet weak var availableBalanceLabel: UILabel!
    @IBOutlet weak var totalBalanceLabel: UILabel!
    @IBOutlet weak var minimumBalanceLabel: UILabel!

    @IBOutlet weak var xlmHeaderLabel: UILabel!
    @IBOutlet weak var baseReserveValueLabel: UILabel!
    @IBOutlet weak var offersValueLabel: UILabel!
    @IBOutlet weak var signersValueLabel: UILabel!
    @IBOutlet weak var trustlinesValueLabel: UILabel!
    @IBOutlet weak var openTradesValueLabel: UILabel!

    @IBOutlet weak var amountHeaderLabel: UILabel!
    @IBOutlet weak var baseReserveAmountLabel: UILabel!
    @IBOutlet weak var offersAmountLabel: UILabel!
    @IBOutlet weak var signersAmountLabel: UILabel!
    @IBOutlet weak var trustlinesAmountLabel: UILabel!
    @IBOutlet weak var openTradesAmountLabel: UILabel!

    var stellarAccount: StellarAccount!
    var stellarAsset: StellarAsset!

    init(stellarAccount: StellarAccount, stellarAsset: StellarAsset) {
        super.init(nibName: String(describing: BalanceViewController.self), bundle: nil)
        self.stellarAccount = stellarAccount
        self.stellarAsset = stellarAsset
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setLabelValues()
    }

    func setupView() {
        navigationItem.title = "LUMEN_BALANCE".localized()

        let rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "close"),
                                                 style: .plain,
                                                 target: self,
                                                 action: #selector(self.dismissView))

        navigationItem.rightBarButtonItem = rightBarButtonItem

        typeHeaderLabel.text = "TYPE_HEADER_TITLE".localized()
        amountHeaderLabel.text = "AMOUNT_HEADER_TITLE".localized()
        xlmHeaderLabel.text = "XLM_HEADER_TITLE".localized()

        totalBalanceTitleLabel.text = "TOTAL_BALANCE_TITLE".localized()
        availableBalanceTitleLabel.text = "AVAILABLE_BALANCE_TITLE".localized()
        baseReserveTitleLabel.text = "BASE_AMOUNT_TITLE".localized()
        trustlinesTitleLabel.text = "TRUSTLINES_TITLE".localized()
        offersTitleLabel.text = "OFFERS_TITLE".localized()
        signersTitleLabel.text = "SIGNERS_TITLE".localized()
        minimumBalanceTitleLabel.text = "MINIMUM_BALANCE_TITLE".localized()
        openTradesTitleLabel.text = "OPEN_TRADES_TITLE".localized()

        availableBalanceView.backgroundColor = Colors.primaryDark
        totalBalanceView.backgroundColor = Colors.primaryDark
    }

    func setLabelValues() {
        let lumenTrades = stellarAccount.tradeOffers.filter { $0.sellingAsset == StellarAsset.lumens }
        let tradeValue = lumenTrades.reduce(0) { result, offer in
            return result + offer.amount
        }

        totalBalanceLabel.text = stellarAsset.balance.tradeFormatted
        availableBalanceLabel.text = stellarAccount.availableBalance(for: stellarAsset).tradeFormattedString
        baseReserveAmountLabel.text = String(describing: stellarAccount.totalBaseAmount)
        baseReserveValueLabel.text = stellarAccount.baseAmount.displayFormattedString
        trustlinesAmountLabel.text = String(describing: stellarAccount.totalTrustlines)
        trustlinesValueLabel.text = stellarAccount.formattedTrustlines
        offersAmountLabel.text = String(describing: stellarAccount.totalOffers)
        offersValueLabel.text = stellarAccount.formattedOffers
        signersAmountLabel.text = String(describing: stellarAccount.totalSigners)
        signersValueLabel.text = stellarAccount.formattedSigners
        openTradesValueLabel.text = tradeValue.tradeFormattedString

        let minBalance = stellarAccount.minBalance + tradeValue
        minimumBalanceLabel.text = minBalance.tradeFormattedString
    }

    @objc func dismissView() {
        dismiss(animated: true, completion: nil)
    }
}
