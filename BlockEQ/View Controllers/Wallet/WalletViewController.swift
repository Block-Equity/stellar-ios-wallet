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
    func selectLearnMore(_ viewController: WalletViewController)
}

final class WalletViewController: UIViewController {
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var availableBalanceLabel: UILabel!
    @IBOutlet var balanceLabel: UILabel!
    @IBOutlet var coinLabel: UILabel!
    @IBOutlet var emptyViewTitleLabel: UILabel!
    @IBOutlet var headerBackgroundView: UIView!
    @IBOutlet var availableBalanceView: UIView!
    @IBOutlet var emptyView: UIView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var tableViewHeader: UIView!
    @IBOutlet var tableViewHeaderLeftLabel: UILabel!
    @IBOutlet var tableViewHeaderRightLabel: UILabel!
    @IBOutlet var logoImageView: UIImageView!
    @IBOutlet var assetBalanceButton: UIButton!
    @IBOutlet var assetListButton: UIButton!
    @IBOutlet var inactiveStateView: UIView!
    @IBOutlet var inactiveImageView: UIImageView!
    @IBOutlet var inactiveDescriptionLabel: UILabel!

    override var preferredStatusBarStyle: UIStatusBarStyle { return .default }

    weak var delegate: WalletViewControllerDelegate?
    var navigationContainer: AppNavigationController?
    var state: WalletState = .inactive(StellarAccount.stub)
    var dataSource: WalletDataSource?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationItem.setHidesBackButton(true, animated: false)
        navigationController?.setNavigationBarHidden(false, animated: true)

        if let network = UserDefaults.standard.string(forKey: "setting.network"), network == "Testnet" {
            navigationItem.title = network
        } else {
            navigationItem.title = "TITLE_TAB_WALLET".localized()
        }

        inactiveStateView.alpha = 1
        toggleInactiveState(dataSource != nil)

        tableView?.dataSource = self.dataSource
        tableView?.reloadData()
    }

    func setupView() {
        tableView.delegate = self
        tableView.register(cellType: TransactionHistoryCell.self)

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

        assetBalanceButton.setTitle("BALANCE_INFORMATION".localized(), for: .normal)
        inactiveDescriptionLabel.text = "NEW_ACCOUNT_DESCRIPTION".localized()
        inactiveDescriptionLabel.textColor = Colors.darkGray

        inactiveImageView.image = UIImage(named: "wallet-large")
        inactiveImageView.tintColor = Colors.darkGrayTransparent
        inactiveImageView.contentMode = .scaleAspectFit

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

    func toggleInactiveState(_ hidden: Bool, animated: Bool = true) {
        var targetAlpha: CGFloat

        if hidden {
            targetAlpha = CGFloat(0)
        } else {
            targetAlpha = CGFloat(1)
            tableView?.backgroundView = inactiveStateView
            inactiveStateView.alpha = 0
        }

        inactiveStateView.isHidden = hidden

        let interval: TimeInterval = animated ? 0.2 : 0

        if !hidden {
            self.tableView?.backgroundView = self.inactiveStateView
        }

        UIView.animate(withDuration: interval, animations: {
            self.inactiveStateView.alpha = targetAlpha
        }, completion: { _ in
            if hidden { self.tableView?.backgroundView = nil }
        })
    }

    func clear() {
        dataSource = nil
        tableView?.reloadData()

        state = WalletState.inactive(StellarAccount.stub)
        update(with: state.viewModel)
    }

    func update(with viewModel: ViewModel, animated: Bool = true) {
        let interval: TimeInterval = animated ? 0.2 : 0

        UIView.animate(withDuration: interval) {
            self.headerBackgroundView.backgroundColor = viewModel.headerBackgroundColor
            self.inactiveImageView.tintColor = viewModel.imageTint
            self.inactiveImageView.image = viewModel.emptyImage

            self.coinLabel.text = viewModel.assetText
            self.balanceLabel.text = viewModel.balanceText
            self.availableBalanceLabel.text = viewModel.balanceHeaderText
            self.inactiveDescriptionLabel.text = viewModel.inactiveDescriptionText
            self.assetBalanceButton.setTitle(viewModel.balanceButtonTitle, for: .normal)

            self.availableBalanceView.isHidden = !viewModel.showBalanceHeader
            self.assetListButton.isHidden = !viewModel.showAssetListButton
            self.assetBalanceButton.isHidden = !viewModel.showBalanceButton

            if viewModel.showActivityIndicator {
                self.activityIndicator.startAnimating()
            } else {
                self.activityIndicator.stopAnimating()
            }
        }
    }

    func update(with account: StellarAccount, asset: StellarAsset) {
        guard self.isViewLoaded else { return }

        if account.isStub {
            state = WalletState.inactive(account)
        } else {
            dataSource = WalletDataSource(account: account, asset: asset)
            state = WalletState.active(asset, account)
        }

        update(with: state.viewModel)
        toggleInactiveState(dataSource != nil)

        tableView?.dataSource = dataSource
        tableView?.reloadData()

        tableView.isUserInteractionEnabled = dataSource != nil
    }
}

// MARK: Interface Actions
extension WalletViewController {
    @IBAction func selectHeaderButton() {
        switch state {
        case .active:
            guard let asset = dataSource?.asset else { return }
            delegate?.selectBalance(self, for: asset)
        case .inactive:
            delegate?.selectLearnMore(self)
        }
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
}

extension WalletViewController {
    enum WalletState {
        case inactive(StellarAccount)
        case active(StellarAsset, StellarAccount)

        var viewModel: ViewModel {
            switch self {
            case .inactive(let account):
                return inactiveViewModel(account: account)
            case .active(let asset, let account):
                let metadata = AssetMetadata(shortCode: asset.shortCode, issuer: asset.assetIssuer)
                return ViewModel(headerBackgroundColor: Colors.primaryDark,
                                 emptyImage: UIImage(named: "wallet-large"),
                                 imageTint: Colors.lightGray,
                                 assetText: metadata.displayNameWithShortCode,
                                 balanceText: asset.balance.displayFormatted,
                                 balanceHeaderText: account.formattedAvailableBalance(for: asset),
                                 balanceButtonTitle: "BALANCE_INFORMATION".localized(),
                                 inactiveDescriptionText: "",
                                 showActivityIndicator: false,
                                 showBalanceHeader: true,
                                 showAssetListButton: true,
                                 showBalanceButton: true)
            }
        }

        func inactiveViewModel(account: StellarAccount) -> ViewModel {
            var image = UIImage(named: "wallet-large")
            var color = Colors.lightGray

            var backgroundColor = Colors.primaryDark
            var assetText = ""
            var balanceText = ""
            var balanceHeaderText = ""
            var inactiveDescriptionText = ""
            var showActivityIndicator = false

            if KeychainHelper.hasFetchedData {
                assetText = "EXISTING_ACCOUNT_REFRESHING".localized()
                balanceText = "EXISTING_ACCOUNT_UPDATING".localized()
                inactiveDescriptionText = "EXISTING_ACCOUNT_INACTIVE".localized()
                showActivityIndicator = true
            } else {
                if let cachedQRCode = try? CacheManager.shared.qrCodes.object(forKey: account.accountId) {
                    image = cachedQRCode.withRenderingMode(.alwaysTemplate)
                    color = Colors.darkGrayTransparent
                }

                backgroundColor = Colors.darkGrayTransparent
                assetText = "NEW_ACCOUNT_FUNDING_REQUIRED".localized()
                balanceText = Decimal(0).displayFormattedString
                balanceHeaderText = "NEW_ACCOUNT_MINIMUM_BALANCE".localized()
                inactiveDescriptionText = "NEW_ACCOUNT_INACTIVE".localized()
                showActivityIndicator = false
            }

            return ViewModel(headerBackgroundColor: backgroundColor,
                             emptyImage: image,
                             imageTint: color,
                             assetText: assetText,
                             balanceText: balanceText,
                             balanceHeaderText: balanceHeaderText,
                             balanceButtonTitle: "",
                             inactiveDescriptionText: inactiveDescriptionText,
                             showActivityIndicator: showActivityIndicator,
                             showBalanceHeader: false,
                             showAssetListButton: false,
                             showBalanceButton: false)
        }
    }

    struct ViewModel {
        var headerBackgroundColor: UIColor
        var emptyImage: UIImage?
        var imageTint: UIColor

        var assetText: String
        var balanceText: String
        var balanceHeaderText: String
        var balanceButtonTitle: String
        var inactiveDescriptionText: String

        var showActivityIndicator: Bool
        var showBalanceHeader: Bool
        var showAssetListButton: Bool
        var showBalanceButton: Bool
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
        case .assetHeader:
            return availableBalanceView
        case .effectList:
            return tableViewHeader
        default:
            let visible = dataSource?.effects.count == 0
            return visible ? emptyView : nil
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let section = WalletDataSource.Section(rawValue: section) else { return 0 }

        switch section {
        case .assetHeader:
            return availableBalanceView.isHidden ? 0 : availableBalanceView.frame.size.height
        case .effectList:
            return tableViewHeader.frame.size.height
        default:
            let visible = dataSource?.effects.count == 0
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
