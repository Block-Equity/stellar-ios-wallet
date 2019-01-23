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
        return assets == availableAssets ? 1 : 2
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? assets.count : availableAssets.count
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = UICollectionViewCell()
        guard let asset = self.asset(for: indexPath) else { return cell }

        if availableAssets.contains(asset) {
            let manageCell = self.manageCell(collectionView: collectionView, for: indexPath, asset: asset, mode: .add)
            manageCell.delegate = self
            cell = manageCell
        } else {
            cell = self.amountCell(collectionView: collectionView, for: indexPath, asset: asset)
        }

        if var styleCell = cell as? StylableAssetCell {
            let inset = collectionView.contentInset.left + collectionView.contentInset.right
            styleCell.preferredWidth = collectionView.bounds.width - inset
        }

        return cell
    }
}
