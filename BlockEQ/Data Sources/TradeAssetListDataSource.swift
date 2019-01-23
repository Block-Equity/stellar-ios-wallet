//
//  TradeAssetDataSource.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-11-05.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import StellarHub

final class TradeAssetListDataSource: ExtendableAssetListDataSource, AssetManageCellDelegate {
    var selected: StellarAsset?
    var excludingAsset: StellarAsset?
    var assets: [StellarAsset] = []
    var availableAssets: [StellarAsset] = []

    init(assets: [StellarAsset], availableAssets: [StellarAsset], selected: StellarAsset?, excluding: StellarAsset?) {
        super.init()

        self.assets = sortedAssetList(with: assets).filter { $0 != excluding }
        self.availableAssets = availableAssets.filter { $0 != excluding }
        self.selected = selected
        self.excludingAsset = excluding
    }

    override func asset(for indexPath: IndexPath) -> StellarAsset? {
        return indexPath.section == 0 ? assets[indexPath.row] : availableAssets[indexPath.row]
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? assets.count : availableAssets.count
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: UICollectionViewCell
        guard let asset = self.asset(for: indexPath) else { return UICollectionViewCell() }

        if !asset.hasZeroBalance {
            cell = self.amountCell(collectionView: collectionView, for: indexPath, asset: asset)
        } else {
            let mode: AssetManageCell.Mode = availableAssets.contains(asset) ? .add : .remove
            let manageCell = self.manageCell(collectionView: collectionView, for: indexPath, asset: asset, mode: mode)
            manageCell.delegate = self
            cell = manageCell
        }

        if var styleCell = cell as? StylableAssetCell {
            let inset = collectionView.contentInset.left + collectionView.contentInset.right
            styleCell.preferredWidth = collectionView.bounds.width - inset
        }

        return cell
    }
}
