//
//  TradeAssetDataSource.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-11-05.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import StellarHub

final class TradeAssetListDataSource: NSObject, AssetListDataSource {
    var selected: StellarAsset?
    var excludingAsset: StellarAsset?
    var assets: [StellarAsset] = []

    weak var actionDelegate: AssetActionDelegate?
    weak var selectionDelegate: AssetSelectionDelegate?

    init(assets: [StellarAsset], selected: StellarAsset?, excluding: StellarAsset?) {
        self.assets = assets.filter { $0 != excluding }
        self.selected = selected
        self.excludingAsset = excluding
    }
}

extension TradeAssetListDataSource: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: AssetAmountCell = collectionView.dequeueReusableCell(for: indexPath)

        let asset = assets[indexPath.row]

        let amount = asset.hasZeroBalance ? "0" : asset.balance
        let priceDataModel = AssetPriceView.ViewModel(amount: amount.tradeFormatted, price: "")
        let model = AssetAmountCell.ViewModel(headerData: asset.headerViewModel, priceData: priceDataModel)

        cell.update(with: model, indexPath: indexPath)

        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let inset = flowLayout.sectionInset.left + flowLayout.sectionInset.right
            cell.preferredWidth = collectionView.bounds.width - inset
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count
    }
}

extension TradeAssetListDataSource: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = assets[indexPath.row]

        if let cell = collectionView.cellForItem(at: indexPath) as? StylableAssetCell {
            cell.select()
        }

        selectionDelegate?.selected(asset)
    }
}
