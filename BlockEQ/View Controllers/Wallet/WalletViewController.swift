//
//  WalletViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-03-09.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk
import StellarHub

protocol WalletViewControllerDelegate: AnyObject {
    func selectedEffect(_ viewController: WalletViewController, effect: StellarEffect)
    func selectedWalletSwitch(_ viewController: WalletViewController)
    func selectedReceive(_ viewController: WalletViewController)
    func selectedSend(_ viewController: WalletViewController, for asset: StellarAsset)
    func selectBalance(_ viewController: WalletViewController, for asset: StellarAsset)
}

class WalletViewController: UIViewController {
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var availableBalanceLabel: UILabel!
    @IBOutlet var balanceLabel: UILabel!
    @IBOutlet var coinLabel: UILabel!
    @IBOutlet var emptyViewTitleLabel: UILabel!
    @IBOutlet var headerBackgroundView: UIView!
    @IBOutlet var availableBalanceView: UIView!
    @IBOutlet var emptyView: UIView!
    @IBOutlet var tableView: UITableView?
    @IBOutlet var tableViewHeader: UIView!
    @IBOutlet var tableViewHeaderLeftLabel: UILabel!
    @IBOutlet var tableViewHeaderRightLabel: UILabel!
    @IBOutlet var logoImageView: UIImageView!
    @IBOutlet var assetBalanceButton: UIButton!

    override var preferredStatusBarStyle: UIStatusBarStyle { return .default }

    weak var delegate: WalletViewControllerDelegate?
    var navigationContainer: AppNavigationController?
    var dataSource: WalletDataSource?
    var showBalanceHeader: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationItem.setHidesBackButton(true, animated: false)
        navigationController?.setNavigationBarHidden(false, animated: true)

        self.refreshAssetHeader()

        if self.dataSource != nil {
            activityIndicator.stopAnimating()
        }

        tableView?.dataSource = self.dataSource
        tableView?.reloadData()
    }

    func setupView() {
        tableView?.delegate = self
        tableView?.register(cellType: TransactionHistoryCell.self)

        let leftBarButtonItem = UIBarButtonItem(title: "ITEM_RECEIVE".localized(),
                                                style: .plain,
                                                target: self,
                                                action: #selector(self.receiveFunds))

        let rightBarButtonItem = UIBarButtonItem(title: "ITEM_SEND".localized(),
                                                 style: .plain,
                                                 target: self,
                                                 action: #selector(self.sendFunds))

        navigationItem.rightBarButtonItem = rightBarButtonItem
        navigationItem.leftBarButtonItem = leftBarButtonItem
        navigationItem.title = "TITLE_TAB_WALLET".localized()

        assetBalanceButton.setTitle("BALANCE_INFORMATION".localized(), for: .normal)

        availableBalanceView.backgroundColor = Colors.backgroundDark
        headerBackgroundView.backgroundColor = Colors.primaryDark
        coinLabel.textColor = Colors.white
        balanceLabel.textColor = Colors.white
        emptyViewTitleLabel.textColor = Colors.darkGray
        tableViewHeaderLeftLabel.textColor = Colors.darkGrayTransparent
        tableViewHeaderRightLabel.textColor = Colors.darkGrayTransparent
        tableView?.backgroundColor = Colors.lightBackground
        tableView?.separatorStyle = .none
    }

    @IBAction func selectBalance() {
        guard let asset = dataSource?.asset else { return }
        delegate?.selectBalance(self, for: asset)
    }

    @IBAction func displayWalletSwitcher() {
        delegate?.selectedWalletSwitch(self)
    }

    @objc func sendFunds() {
        guard let asset = dataSource?.asset else { return }
        delegate?.selectedSend(self, for: asset)
    }

    @objc func receiveFunds() {
        delegate?.selectedReceive(self)
    }

    func update(with account: StellarAccount, asset: StellarAsset) {
        dataSource = WalletDataSource(account: account, asset: asset)

        guard self.isViewLoaded else { return }

        self.refreshAssetHeader()

        activityIndicator.stopAnimating()

        tableView?.dataSource = dataSource
        tableView?.reloadData()
    }

    func refreshAssetHeader() {
        if let asset = self.dataSource?.asset, let account = self.dataSource?.account {
            let metadata = AssetMetadata(shortCode: asset.shortCode)
            self.showBalanceHeader = true //asset.isNative
            self.coinLabel.text = metadata.displayNameWithShortCode
            self.balanceLabel.text = asset.balance.displayFormatted
            self.availableBalanceLabel.text = account.formattedAvailableBalance(for: asset)
        }
    }
}

extension WalletViewController: AccountUpdatable {
    func updated(account: StellarAccount) {
        if let currentAsset = dataSource?.asset {
            self.update(with: account, asset: currentAsset)
        } else if let asset = account.assets.first {
            self.update(with: account, asset: asset)
        }
    }
}

extension WalletViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let section = WalletDataSource.Section(rawValue: section) else { return nil }

        switch section {
        case .assetHeader: return showBalanceHeader ? availableBalanceView : nil
        case .effectList: return tableViewHeader
        default:
            let visible = !activityIndicator.isAnimating && dataSource?.effects.count == 0
            return visible ? emptyView : nil
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let section = WalletDataSource.Section(rawValue: section) else { return 0 }

        switch section {
        case .assetHeader: return showBalanceHeader ? availableBalanceView.frame.size.height : 0
        case .effectList: return tableViewHeader.frame.size.height
        default:
            let visible = !activityIndicator.isAnimating && dataSource?.effects.count == 0
            return visible ? emptyView.frame.size.height : 0
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TransactionHistoryCell.rowHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let effect = self.dataSource?.effects[indexPath.row],
            WalletDataSource.supportedDetails.contains(effect.type) else { return }

        delegate?.selectedEffect(self, effect: effect)
    }
}
