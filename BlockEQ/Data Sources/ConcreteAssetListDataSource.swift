//
//  ConcreteAssetListDataSource.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2019-01-23.
//  Copyright © 2019 BlockEQ. All rights reserved.
//

import StellarHub

protocol AssetListDataSource: UICollectionViewDataSource, UICollectionViewDelegate {
    var actionDelegate: AssetActionDelegate? { get set }
    var selectionDelegate: AssetSelectionDelegate? { get set }

    func sortedAssetList(with assets: [StellarAsset]) -> [StellarAsset]
    func asset(for: IndexPath) -> StellarAsset?
    func selectedAction(mode: AssetManageCell.Mode, cellPath: IndexPath?)

    func manageCell(collectionView: UICollectionView,
                    for path: IndexPath,
                    asset: StellarAsset,
                    mode: AssetManageCell.Mode) -> AssetManageCell

    func amountCell(collectionView: UICollectionView,
                    for path: IndexPath,
                    asset: StellarAsset) -> AssetAmountCell
}

extension AssetListDataSource {
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

    func selectedAction(mode: AssetManageCell.Mode, cellPath: IndexPath?) {
        guard let indexPath = cellPath, let asset = self.asset(for: indexPath) else { return }

        switch mode {
        case .add:
            actionDelegate?.requestedAdd(asset: asset)
        case .remove:
            actionDelegate?.requestedRemove(asset: asset)
        }
    }
}

class ExtendableAssetListDataSource: NSObject, AssetListDataSource {
    weak var actionDelegate: AssetActionDelegate?
    weak var selectionDelegate: AssetSelectionDelegate?

    func asset(for: IndexPath) -> StellarAsset? {
        fatalError("Must be overridden")
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        fatalError("Must be overridden")
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        fatalError("Must be overridden")
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        fatalError("Must be overridden")
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let asset = self.asset(for: indexPath) else {
            return
        }

        if let cell = collectionView.cellForItem(at: indexPath) as? StylableAssetCell {
            cell.select()
        }

        selectionDelegate?.selected(asset)
    }

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 0 ? true : false
    }

    @objc func collectionView(_ collectionView: UICollectionView,
                              viewForSupplementaryElementOfKind kind: String,
                              at indexPath: IndexPath) -> UICollectionReusableView {
        let header: AssetListHeader = collectionView.dequeueHeader(for: indexPath)
        header.headerTitleLabel.text = "BLOCKEQ_ASSET_TITLE".localized()
        return header
    }

    @objc func collectionView(_ collectionView: UICollectionView,
                              layout collectionViewLayout: UICollectionViewLayout,
                              referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard self.collectionView(collectionView, numberOfItemsInSection: section) > 0 else { return .zero }

        switch section {
        case 1: return CGSize(width: collectionView.bounds.width, height: 30)
        default: return .zero
        }
    }
}
