//
//  AssetBalanceDataSource.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2019-01-07.
//  Copyright © 2019 BlockEQ. All rights reserved.
//

import StellarHub

final class AssetBalanceDataSource: NSObject {
    let asset: StellarAsset
    let account: StellarAccount

    init(asset: StellarAsset, account: StellarAccount) {
        self.asset = asset
        self.account = account
    }
}

extension AssetBalanceDataSource: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return BalanceSection.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let section = BalanceSection(rawValue: section) else {
            return 0
        }

        var count: Int
        switch section {
        case .assetData:
            count = 1
        case .reductions:
            let nativeCount = BalanceReduction.nativeReductions.count
            let nonNativeCount = BalanceReduction.nonNativeReductions.count
            count = asset.isNative ? nativeCount : nonNativeCount
        }

        return count

    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let section = BalanceSection(rawValue: indexPath.section) else {
            return UICollectionViewCell(frame: .zero)
        }

        if section == .assetData {
            return section.cell(collectionView, indexPath: indexPath, account: account, asset: asset)
        } else if asset.isNative {
            let reduction = BalanceReduction.nativeReductions[indexPath.row]
            return reduction.cell(collectionView, indexPath: indexPath, account: account, asset: asset)
        } else if !asset.isNative {
            let reduction = BalanceReduction.nonNativeReductions[indexPath.row]
            return reduction.cell(collectionView, indexPath: indexPath, account: account, asset: asset)
        } else {
            return UICollectionViewCell(frame: .zero)
        }
    }
}

extension AssetBalanceDataSource {
    enum BalanceSection: Int, CaseIterable {
        case assetData
        case reductions

        func cell(_ collectionView: UICollectionView,
                  indexPath: IndexPath,
                  account: StellarAccount,
                  asset: StellarAsset) -> UICollectionViewCell {
            let cell: AssetIssuerCell = collectionView.dequeueReusableCell(for: indexPath)

            let totalBalance = asset.balance.tradeFormatted
            let header = asset.headerViewModel
            let issuer = asset.issuerViewModel
            let priceData = AssetPriceView.ViewModel(amount: totalBalance, price: "", hidePrice: true)

            let viewModel = AssetIssuerCell.ViewModel(headerData: header, priceData: priceData, issuerData: issuer)
            cell.update(with: viewModel, indexPath: indexPath)

            let inset = collectionView.contentInset.left + collectionView.contentInset.right
            cell.preferredWidth = collectionView.bounds.width - inset

            return cell
        }
    }

    //swiftlint:disable nesting
    enum BalanceReduction: Int, CaseIterable {
        typealias CellText = (title: String, subtitle: String, balance: String)

        case totalAmount
        case baseReserve
        case signerEntries
        case trustlineEntries
        case offerEntries
        case openLiabilites
        case availableBalance

        static var nativeReductions: [BalanceReduction] {
            return allCases
        }

        static var nonNativeReductions: [BalanceReduction] {
            return [BalanceReduction.totalAmount, BalanceReduction.openLiabilites, BalanceReduction.availableBalance]
        }

        func cell(_ collectionView: UICollectionView,
                  indexPath: IndexPath,
                  account: StellarAccount,
                  asset: StellarAsset) -> UICollectionViewCell {
            let cell: AssetAmountCell = collectionView.dequeueReusableCell(for: indexPath)

            let data = cellText(for: account, asset: asset)
            var priceData = AssetPriceView.ViewModel(amount: data.balance, price: "", hidePrice: true)

            let inset = collectionView.contentInset.left + collectionView.contentInset.right
            cell.preferredWidth = collectionView.bounds.width - inset
            cell.preferredHeight = 65

            if indexPath.row == 0 {
                cell.cornerMask = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                priceData.amountColor = Colors.black
            } else if indexPath.row == collectionView.numberOfItems(inSection: indexPath.section) - 1 {
                cell.cornerMask = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                priceData.amountColor = Colors.black
            } else {
                cell.cornerMask = []
                priceData.amountColor = Colors.red
            }

            let headerData = AssetHeaderView.ViewModel(image: nil, assetTitle: data.title, assetSubtitle: data.subtitle)
            let viewModel = AssetAmountCell.ViewModel(headerData: headerData, priceData: priceData)

            cell.update(with: viewModel, indexPath: indexPath)

            return cell
        }

        func cellText(for account: StellarAccount, asset: StellarAsset) -> CellText {
            var title, subtitle, balance: String

            switch self {
            case .totalAmount:
                title = "TOTAL_BALANCE_TITLE".localized()
                balance = asset.balance.tradeFormatted
                subtitle = ""
            case .baseReserve:
                title = "BASE_AMOUNT_TITLE".localized()
                subtitle = String(format: "BASE_AMOUNT_SUBTITLE".localized(),
                                  String(describing: account.totalBaseAmount))
                balance = account.baseAmount.displayFormattedString
            case .signerEntries:
                title = "SIGNERS_TITLE".localized()
                subtitle = String(format: "SIGNERS_SUBTITLE".localized(), String(describing: account.totalSigners))
                balance = account.formattedSigners
            case .offerEntries:
                title = "OFFERS_TITLE".localized()
                subtitle = String(format: "OFFERS_SUBTITLE".localized(), String(describing: account.totalOffers))
                balance = account.formattedOffers
            case .trustlineEntries:
                title = "TRUSTLINES_TITLE".localized()
                subtitle = String(format: "TRUSTLINES_SUBTITLE".localized(),
                                  String(describing: account.totalTrustlines))
                balance = account.formattedTrustlines
            case .openLiabilites:
                let assetTrades = account.tradeOffers.filter { $0.sellingAsset == asset }
                let tradeValue = assetTrades.reduce(0) { result, offer in
                    return result + offer.amount
                }

                title = "OPEN_TRADES_TITLE".localized()
                subtitle = "OPEN_TRADES_SUBTITLE".localized()
                balance = tradeValue.tradeFormattedString
            case .availableBalance:
                title = "AVAILABLE_BALANCE_TITLE".localized()
                balance = account.availableBalance(for: asset).tradeFormattedString
                subtitle = ""
            }

            return (title: title, subtitle: subtitle, balance: balance)
        }
    }
    //swiftlint:enable nesting
}
