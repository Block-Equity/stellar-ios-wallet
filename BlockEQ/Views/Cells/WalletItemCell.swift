//
//  WalletItem.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-04-05.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Reusable

protocol WalletItemCellDelegate: class {
    func requestedRemoveAsset(indexPath: IndexPath)
    func requestedChangeInflation()
}

class WalletItemCell: UITableViewCell, NibReusable {
    enum ButtonMode {
        case none
        case removeAsset
        case updateInflation
        case setInflation
    }

    struct ViewModel {
        var title: String
        var amount: String
        var tokenText: String?
        var icon: UIImage?
        var iconBackground: UIColor?
        var mode: ButtonMode = .none

        init(title: String, amount: String) {
            self.title = title
            self.amount = amount
        }
    }

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var amountLabel: UILabel!
    @IBOutlet var tokenInitialLabel: UILabel!
    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var setInflationButton: UIButton!
    @IBOutlet var updateInflationButton: UIButton!
    @IBOutlet var removeAssetButton: UIButton!

    weak var delegate: WalletItemCellDelegate?
    var indexPath: IndexPath?
    static let cellIdentifier = "WalletItemCell"

    @IBAction func removeAsset() {
        if let currentIndexPath = indexPath {
            delegate?.requestedRemoveAsset(indexPath: currentIndexPath)
        }
    }

    @IBAction func changeInflation() {
        delegate?.requestedChangeInflation()
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        setupView()
    }

    func setupView() {
        removeAssetButton.backgroundColor = Colors.red
        setInflationButton.backgroundColor = Colors.green
        updateInflationButton.backgroundColor = Colors.secondaryDark

        removeAssetButton.setTitle("REMOVE_ASSET".localized(), for: .normal)
        setInflationButton.setTitle("SET_INFLATION".localized(), for: .normal)
        updateInflationButton.setTitle("UPDATE_INFLATION".localized(), for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        setRowColor(selected: selected)
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        setRowColor(selected: highlighted)
    }

    func update(with viewModel: ViewModel) {
        self.titleLabel.text = viewModel.title
        self.amountLabel.text = viewModel.amount
        self.iconImageView.image = viewModel.icon ?? nil
        self.iconImageView.backgroundColor = viewModel.iconBackground ?? UIColor.clear
        self.tokenInitialLabel.text = viewModel.tokenText ?? ""

        self.removeAssetButton.isHidden = true
        self.setInflationButton.isHidden = true
        self.updateInflationButton.isHidden = true

        switch viewModel.mode {
        case .none: break
        case .removeAsset: self.removeAssetButton.isHidden = false
        case .setInflation: self.setInflationButton.isHidden = false
        case .updateInflation: self.updateInflationButton.isHidden = false
        }
    }

    func setRowColor(selected: Bool) {
        contentView.backgroundColor =  selected ? Colors.lightBlue : Colors.white
        titleLabel.textColor = selected ? Colors.primaryDark : Colors.darkGray
        amountLabel.textColor = selected ? Colors.primaryDark : Colors.darkGray
    }
}
