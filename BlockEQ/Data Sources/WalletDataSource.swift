//
//  WalletViewControllerDataSource.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-10-22.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import StellarHub
import stellarsdk

final class WalletDataSource: NSObject {
    enum Section: Int, RawRepresentable {
        case assetHeader
        case effectList
        case empty

        static let all: [Section] = [ .assetHeader, .effectList, .empty ]
    }

    static let supportedEffects: [EffectType] = [
        .accountCreated,
        .accountCredited,
        .accountDebited,
        .tradeEffect,
        .accountInflationDestinationUpdated
    ]

    static let supportedDetails: [EffectType] = [
        .accountCredited,
        .accountDebited,
        .accountInflationDestinationUpdated
    ]

    private var index: Int
    var effects: [StellarEffect] = []
    var account: StellarAccount
    var asset: StellarAsset? {
        if index >= account.assets.count {
            self.index = 0
        }

        return account.assets[index]
    }

    init(account: StellarAccount, asset: StellarAsset) {
        self.index = account.assets.firstIndex(of: asset) ?? 0
        self.account = account
        self.effects = account.effects
            .filter { currentEffect in
                let isSupportedType = WalletDataSource.supportedEffects.contains(currentEffect.type)
                let isBaseAsset = currentEffect.asset == asset
                let isPairAsset = currentEffect.assetPair.buying == asset || currentEffect.assetPair.selling == asset
                let isIncludedTrade = currentEffect.type == .tradeEffect && isPairAsset
                return isSupportedType && (isBaseAsset || isIncludedTrade)
            }
            .sorted(by: { (first, second) -> Bool in first.createdAt > second.createdAt })
    }
}

extension WalletDataSource: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.all.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else { return 0 }

        switch section {
        case .effectList: return effects.count
        default: return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let effect = effects[indexPath.row]
        let cell: TransactionHistoryCell = tableView.dequeueReusableCell(for: indexPath)

        if let asset = self.asset {
            cell.update(with: asset, effect: effect)
        }

        cell.selectionStyle = WalletDataSource.supportedDetails.contains(effect.type) ? .default : .none

        return cell
    }
}
