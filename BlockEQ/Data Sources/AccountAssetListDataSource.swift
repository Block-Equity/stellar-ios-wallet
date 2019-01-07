//
//  AssetListDataSource.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-12-27.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import StellarHub

final class AccountAssetListDataSource: NSObject, AssetListDataSource {
    private var assets: [String: [StellarAsset]] = [:]
    private var inflationSet: Bool = false

    weak var actionDelegate: AssetActionDelegate?
    weak var selectionDelegate: AssetSelectionDelegate?

    private var templateHeader: AssetListHeader!

    init(accountAssets: [StellarAsset], availableAssets: [StellarAsset], inflationSet: Bool = false) {
        super.init()

        assets[Section.account.name] = sortedAssetList(with: accountAssets)
        assets[Section.available.name] = availableAssets

        self.inflationSet = inflationSet

        templateHeader = AssetListHeader.loadFromNib()
        templateHeader.headerTitleLabel.text = "BLOCKEQ_ASSET_TITLE".localized()
        templateHeader.sizeToFit()
    }

    func sortedAssetList(with assets: [StellarAsset]) -> [StellarAsset] {
        var assetsToSort = assets
        var result: [StellarAsset] = []

        // Always insert Lumens first
        if assetsToSort.count > 0 {
            result.append(assetsToSort.removeFirst())
        }

        // Sort remaining assets by balance
        result.append(contentsOf:
            assetsToSort.sorted(by: { (first, second) -> Bool in
                guard let firstBalance = Decimal(string: first.balance) else { return false }
                guard let secondBalance = Decimal(string: second.balance)  else { return false }
                return firstBalance > secondBalance
            })
        )

        return result
    }

    func asset(for indexPath: IndexPath) -> StellarAsset? {
        guard let section = Section(rawValue: indexPath.section),
            let sectionAssets = assets[section.name],
            indexPath.row < sectionAssets.count else {
                return nil
        }

        return sectionAssets[indexPath.row]
    }

    func manageCell(collectionView: UICollectionView,
                    for path: IndexPath,
                    asset: StellarAsset,
                    mode: AssetManageCell.Mode) -> AssetManageCell {
        let cell: AssetManageCell = collectionView.dequeueReusableCell(for: path)

        let model = AssetManageCell.ViewModel(headerData: asset.headerViewModel, mode: mode)
        cell.update(with: model, indexPath: path)
        return cell
    }

    func amountCell(collectionView: UICollectionView, for path: IndexPath, asset: StellarAsset) -> AssetAmountCell {
        let cell: AssetAmountCell = collectionView.dequeueReusableCell(for: path)

        let model = AssetAmountCell.ViewModel(headerData: asset.headerViewModel, priceData: asset.priceViewModel)
        cell.update(with: model, indexPath: path)
        return cell
    }

    func actionCell(collectionView: UICollectionView, for path: IndexPath, asset: StellarAsset) -> AssetActionCell {
        let cell: AssetActionCell = collectionView.dequeueReusableCell(for: path)

        let metadata = AssetMetadata(shortCode: asset.shortCode)
        var buttonData = AssetButtonView.ViewModel(buttonData: [(title: "SET_INFLATION".localized(),
                                                                 backgroundColor: metadata.primaryColor,
                                                                 textColor: Colors.white,
                                                                 enabled: true)])

        if inflationSet {
            buttonData = AssetButtonView.ViewModel(buttonData: [(title: "UPDATE_INFLATION".localized(),
                                                                 backgroundColor: metadata.primaryColor,
                                                                 textColor: Colors.white,
                                                                 enabled: true)])
        }

        let model = AssetActionCell.ViewModel(headerData: asset.headerViewModel,
                                              priceData: asset.priceViewModel,
                                              buttonData: buttonData)

        cell.update(with: model, indexPath: path)

        return cell
    }
}

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

// Has two sections:
// * first section is assets which are on the account
// * second section is assets which are available to be added to the account

extension AccountAssetListDataSource: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section), let sectionAssets = assets[section.name] else {
            return 0
        }

        return sectionAssets.count
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
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
    func collectionView(_ collectionView: UICollectionView,
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

        if var styleCell = cell as? StylableCardCell {
            let inset = collectionView.contentInset.left + collectionView.contentInset.right
            styleCell.preferredWidth = collectionView.bounds.width - inset
        }

        return cell
    }
}

// MARK: - AssetManageCellDelegate
extension AccountAssetListDataSource: AssetManageCellDelegate {
    func selectedAction(mode: AssetManageCell.Mode, cellPath: IndexPath?) {
        guard let path = cellPath, let asset = self.asset(for: path) else {
            return
        }

        switch mode {
        case .add:
            actionDelegate?.requestedAdd(asset: asset)
        case .remove:
            actionDelegate?.requestedRemove(asset: asset)
        }
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

// MARK: - UICollectionViewDelegate
extension AccountAssetListDataSource: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let asset = self.asset(for: indexPath) else {
            return
        }

        if let cell = collectionView.cellForItem(at: indexPath) as? StylableCardCell {
            cell.select()
        }

        selectionDelegate?.selected(asset)
    }

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let section = Section(rawValue: indexPath.section), section == .account else {
            return false
        }

        return true
    }

    @objc func collectionView(_ collectionView: UICollectionView,
                              layout collectionViewLayout: UICollectionViewLayout,
                              referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard let assetSection = Section(rawValue: section) else {
            return .zero
        }

        switch assetSection {
        case .available:
            return CGSize(width: collectionView.bounds.width, height: templateHeader.frame.height)
        default:
            return .zero
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        let header: AssetListHeader = collectionView.dequeueHeader(for: indexPath)
        header.headerTitleLabel.text = "BLOCKEQ_ASSET_TITLE".localized()
        return header
    }
}
