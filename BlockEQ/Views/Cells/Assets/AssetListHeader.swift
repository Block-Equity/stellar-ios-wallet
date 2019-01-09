//
//  AssetListHeader.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-12-31.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Foundation
import Reusable

final class AssetListHeader: UICollectionReusableView, Reusable, NibLoadable {
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var headerTitleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor = .clear
        container.backgroundColor = .clear
        container.layer.cornerRadius = 5

        headerTitleLabel.text = "BLOCKEQ_ASSET_TITLE".localized()
        headerTitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        headerTitleLabel.textColor = Colors.darkGray
    }
}
