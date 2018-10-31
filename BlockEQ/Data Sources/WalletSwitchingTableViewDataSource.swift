//
//  WalletSwitchingDataSource.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-10-23.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import StellarAccountService

protocol WalletDataSourceDelegate: AnyObject {
    func updateInflation(_ dataSource: WalletSwitchingDataSource)
    func createTrustLine(_ dataSource: WalletSwitchingDataSource, to address: StellarAddress, asset: StellarAsset)
    func remove(_ dataSource: WalletSwitchingDataSource, asset: StellarAsset)
    func add(_ dataSource: WalletSwitchingDataSource, asset: StellarAsset)
}

final class WalletSwitchingDataSource: NSObject {
    enum Section: Int {
        case userAssets
        case supportedAssets

        var sectionRowHeight: CGFloat {
            switch self {
            case .supportedAssets: return 70
            case .userAssets: return 70
            }
        }

        static let all: [Section] = [.userAssets, .supportedAssets]
    }

    weak var delegate: WalletDataSourceDelegate?
    var stellarAccount: StellarAccount
    var availableAssets: [Assets.AssetType] = []
    var allAssets: [StellarAsset] = []

    var hasSupportedAssets: Bool {
        return availableAssets.count > 0
    }

    init(account: StellarAccount) {
        self.stellarAccount = account

        let allTypes = Set(Assets.all)

        allAssets.append(contentsOf: account.assets)

        let assetTypesOnAccount: [Assets.AssetType] = stellarAccount.assets.compactMap {
            guard let code = $0.assetCode else { return nil }
            return Assets.AssetType(rawValue: code)
        }

        let missingTypes = allTypes.symmetricDifference(Set(assetTypesOnAccount))
        availableAssets.append(contentsOf: missingTypes)
    }

    func isZeroBalance() -> Bool {
        guard let balance = Double(allAssets[0].balance) else {
            return false
        }

        if stellarAccount.assets.count == 1 && balance < 1.0 {
            return true
        }

        return false
    }
}

extension WalletSwitchingDataSource: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.all.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case Section.userAssets.rawValue: return allAssets.count
        default: return availableAssets.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case Section.userAssets.rawValue:
            let item = allAssets[indexPath.row]
            let walletCell: WalletItemCell = tableView.dequeueReusableCell(for: indexPath)
            var viewModel = WalletItemCell.ViewModel(title: Assets.displayTitle(shortCode: item.shortCode),
                                                     amount: "\(item.balance.decimalFormatted) \(item.shortCode)")

            walletCell.indexPath = indexPath
            walletCell.delegate = self

            if let image = Assets.displayImage(shortCode: item.shortCode) {
                viewModel.icon = image
            } else {
                let shortcode = Assets.displayTitle(shortCode: item.shortCode)
                viewModel.tokenText = String(Array(shortcode)[0])
                viewModel.iconBackground = Assets.displayImageBackgroundColor(shortCode: item.shortCode)
            }

            if item.isNative {
                viewModel.mode = stellarAccount.inflationDestination != nil ? .updateInflation : .setInflation
            } else {
                viewModel.mode = item.hasZeroBalance ? .removeAsset : .none
            }

            walletCell.update(with: viewModel)

            return walletCell
        default:
            let shortCode = availableAssets[indexPath.row].shortForm
            let displayString = String(format: "%@ %@", Assets.displayTitle(shortCode: shortCode), shortCode)

            let walletCell: WalletItemActivateCell = tableView.dequeueReusableCell(for: indexPath)
            var viewModel = WalletItemActivateCell.ViewModel(title: displayString)
            walletCell.indexPath = indexPath
            walletCell.delegate = self

            viewModel.iconBackground = Assets.displayImageBackgroundColor(shortCode: shortCode)
            viewModel.icon = Assets.displayImage(shortCode: shortCode)

            walletCell.update(with: viewModel)

            return walletCell
        }
    }
}

extension WalletSwitchingDataSource: WalletItemCellDelegate {
    func requestedChangeInflation() {
        delegate?.updateInflation(self)
    }

    func requestedRemoveAsset(indexPath: IndexPath) {
        let item = allAssets[indexPath.row]
        delegate?.remove(self, asset: item)
    }
}

extension WalletSwitchingDataSource: WalletItemActivateCellDelegate {
    func didAddAsset(indexPath: IndexPath) {
        let asset = availableAssets[indexPath.row]
        let stellarAsset = StellarAsset(assetCode: asset.shortForm, issuer: asset.issuerAccount)
        delegate?.add(self, asset: stellarAsset)
    }
}
