//
//  WalletItemActivateCell.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-04-10.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Reusable

protocol WalletItemActivateCellDelegate: class {
    func didAddAsset(indexPath: IndexPath)
}

class WalletItemActivateCell: UITableViewCell, Reusable {
    struct ViewModel {
        var title: String
        var icon: UIImage?
        var iconBackground: UIColor?

        init(title: String) {
            self.title = title
        }
    }

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var addAssetButton: UIButton!

    weak var delegate: WalletItemActivateCellDelegate?
    var indexPath: IndexPath?
    static let cellIdentifier = "WalletItemActivateCell"

    @IBAction func addAsset() {
        if let currentIndexPath = indexPath {
            delegate?.didAddAsset(indexPath: currentIndexPath)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    func setupView() {
        addAssetButton.backgroundColor = Colors.secondaryDark
        titleLabel.textColor = Colors.white
    }

    func update(with viewModel: ViewModel) {
        self.titleLabel.text = viewModel.title
        self.iconImageView.image = viewModel.icon
        self.iconImageView.backgroundColor = viewModel.iconBackground
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        setRowColor(selected: selected)
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        setRowColor(selected: highlighted)
    }

    func setRowColor(selected: Bool) {
        contentView.backgroundColor =  selected ? Colors.lightBlue : Colors.white
        titleLabel.textColor = selected ? Colors.primaryDark : Colors.darkGray
        addAssetButton.backgroundColor = Colors.secondaryDark
    }
}
