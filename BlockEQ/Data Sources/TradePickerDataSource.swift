//
//  TradePickerDataSource.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-11-05.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import StellarAccountService

protocol TradePickerDataSourceDelegate: AnyObject {
    func selectedAsset(_ pickerView: UIPickerView, asset: StellarAsset?)
}

final class TradePickerDataSource: NSObject {
    var selected: StellarAsset?
    var excludingAsset: StellarAsset?
    var assets: [StellarAsset] = []
    weak var delegate: TradePickerDataSourceDelegate?

    init(assets: [StellarAsset], selected: StellarAsset?, excluding: StellarAsset?) {
        self.assets = assets.filter { $0 != excluding }
        self.selected = selected
        self.excludingAsset = excluding
    }
}

// MARK: - UIPickerViewDataSource
extension TradePickerDataSource: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return assets.count
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let asset = assets[row]
        delegate?.selectedAsset(pickerView, asset: asset)
    }
}

// MARK: - UIPickerViewDelegate
extension TradePickerDataSource: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let asset = assets[row]
        return String(format: "TRADE_PICKER_FORMAT_STRING".localized(),
                      Assets.displayTitle(shortCode: asset.shortCode),
                      asset.shortCode)
    }
}
