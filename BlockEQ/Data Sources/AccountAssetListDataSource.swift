//
//  AssetListDataSource.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-12-27.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import StellarHub

extension AccountAssetListDataSource {
    enum Section: Int, RawRepresentable, CaseIterable {
        case account
        case available

        var name: String {
            switch self {
            case .account: return "account"
            case .available: return "available"
            }
        }
    }
}

final class AccountAssetListDataSource: ExtendableAssetListDataSource, AssetManageCellDelegate {
    private var assets: [String: [StellarAsset]] = [:]
    private var inflationSet: Bool = false

    init(accountAssets: [StellarAsset], availableAssets: [StellarAsset], inflationSet: Bool = false) {
        super.init()

        assets[Section.account.name] = sortedAssetList(with: accountAssets)
        assets[Section.available.name] = availableAssets

        self.inflationSet = inflationSet
    }

    override func asset(for indexPath: IndexPath) -> StellarAsset? {
        guard let section = Section(rawValue: indexPath.section),
            let sectionAssets = assets[section.name],
            indexPath.row < sectionAssets.count else {
                return nil
        }

        return sectionAssets[indexPath.row]
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section), let sectionAssets = assets[section.name] else {
            return 0
        }

        return sectionAssets.count
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard assets.count > 0 else {
            return 0
        }

        if let section = assets[Section.available.name], section.count > 0 {
            return AccountAssetListDataSource.Section.allCases.count
        } else {
            return 1
        }
    }

    /*
     If the section is account, the cell can be: AssetManageCell (remove), AssetActionCell, AssetAmountCell.
     If the section is available, the cell can be: AssetManageCell (add)
     */
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let section = Section(rawValue: indexPath.section), let asset = self.asset(for: indexPath) else {
            return UICollectionViewCell(frame: .zero)
        }

        var cell: UICollectionViewCell

        switch section {
        case .account:
            if asset.isNative {
                let aCell = actionCell(collectionView: collectionView, for: indexPath, asset: asset)
                aCell.delegate = self
                cell = aCell
            } else if asset.hasZeroBalance {
                let mCell = manageCell(collectionView: collectionView, for: indexPath, asset: asset, mode: .remove)
                mCell.delegate = self
                cell = mCell
            } else {
                cell = amountCell(collectionView: collectionView, for: indexPath, asset: asset)
            }
        case .available:
            let mCell = manageCell(collectionView: collectionView, for: indexPath, asset: asset, mode: .add)
            mCell.delegate = self
            cell = mCell
        }

        if var styleCell = cell as? StylableAssetCell {
            let inset = collectionView.contentInset.left + collectionView.contentInset.right
            styleCell.preferredWidth = collectionView.bounds.width - inset
        }

        return cell
    }

    func actionCell(collectionView: UICollectionView, for path: IndexPath, asset: StellarAsset) -> AssetActionCell {
        let cell: AssetActionCell = collectionView.dequeueReusableCell(for: path)

        let text = inflationSet ? "UPDATE_INFLATION".localized(): "SET_INFLATION".localized()
        let buttonData = AssetButtonView.ViewModel(buttonData: [(title: text,
                                                                 backgroundColor: Colors.primaryDark,
                                                                 textColor: Colors.white,
                                                                 enabled: true)])

        let model = AssetActionCell.ViewModel(headerData: asset.headerViewModel,
                                              priceData: asset.priceViewModel,
                                              buttonData: buttonData)

        cell.update(with: model, indexPath: path)

        return cell
    }
}

// MARK: - AssetActionCellDelegate
extension AccountAssetListDataSource: AssetActionCellDelegate {
    func selectedOption(optionIndex: Int, cellPath: IndexPath?) {
        guard let path = cellPath, let asset = self.asset(for: path) else {
            return
        }

        actionDelegate?.requestedAction(optionIndex, for: asset)
    }
}
