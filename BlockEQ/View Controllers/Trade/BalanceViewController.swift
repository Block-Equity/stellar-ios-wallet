//
//  BalanceViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-07-12.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import StellarAccountService

class BalanceViewController: UIViewController {

    @IBOutlet var availableBalanceView: UIView!
    @IBOutlet var totalBalanceView: UIView!
    @IBOutlet var availableBalanceLabel: UILabel!
    @IBOutlet var baseReserveAmountLabel: UILabel!
    @IBOutlet var baseReserveValueLabel: UILabel!
    @IBOutlet var minimumBalanceLabel: UILabel!
    @IBOutlet var offersAmountLabel: UILabel!
    @IBOutlet var offersValueLabel: UILabel!
    @IBOutlet var signersAmountLabel: UILabel!
    @IBOutlet var signersValueLabel: UILabel!
    @IBOutlet var totalBalanceLabel: UILabel!
    @IBOutlet var trustlinesAmountLabel: UILabel!
    @IBOutlet var trustlinesValueLabel: UILabel!

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

        availableBalanceView.backgroundColor = Colors.primaryDark
        totalBalanceView.backgroundColor = Colors.primaryDark
    }

    func setLabelValues() {
        availableBalanceLabel.text = stellarAccount.formattedAvailableBalance
        baseReserveAmountLabel.text = String(describing: stellarAccount.totalBaseReserve)
        baseReserveValueLabel.text = stellarAccount.formattedBaseReserve
        trustlinesAmountLabel.text = String(describing: stellarAccount.totalTrustlines)
        trustlinesValueLabel.text = stellarAccount.formattedTrustlines
        offersAmountLabel.text = String(describing: stellarAccount.totalOffers)
        offersValueLabel.text = stellarAccount.formattedOffers
        signersAmountLabel.text = String(describing: stellarAccount.totalSigners)
        signersValueLabel.text = stellarAccount.formattedSigners
        minimumBalanceLabel.text = stellarAccount.formattedMinBalance
        totalBalanceLabel.text = stellarAsset.formattedBalance
    }

    @objc func dismissView() {
        dismiss(animated: true, completion: nil)
    }
}
