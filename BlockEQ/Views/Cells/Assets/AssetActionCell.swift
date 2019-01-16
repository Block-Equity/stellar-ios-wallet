//
//  AssetActionCell.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-12-24.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Reusable

protocol AssetActionCellDelegate: AnyObject {
    func selectedOption(optionIndex: Int, cellPath: IndexPath?)
}

final class AssetActionCell: UICollectionViewCell, Reusable, NibOwnerLoadable, IndexableCell {
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var headerContainer: AssetHeaderView!
    @IBOutlet weak var priceContainer: AssetPriceView!
    @IBOutlet weak var buttonContainer: AssetButtonView!

    weak var delegate: AssetActionCellDelegate?

    var indexPath: IndexPath?
    var preferredWidth: CGFloat?
    var preferredHeight: CGFloat?
    var cornerMask: CACornerMask?

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNibContent()
        setupStyle()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNibContent()
        setupStyle()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let defaultMask: CACornerMask = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner,
                                         .layerMinXMaxYCorner, .layerMinXMinYCorner]

        cardView.layer.maskedCorners = cornerMask ?? defaultMask
    }

    func setupStyle() {
        view.backgroundColor = .clear

        headerContainer.backgroundColor = .clear
        priceContainer.backgroundColor = .clear
        buttonContainer.backgroundColor = .clear

        buttonContainer.delegate = self

        cardStyle(view: cardView)
    }

    func update(with viewModel: ViewModel, indexPath path: IndexPath) {
        headerContainer.update(with: viewModel.headerData)
        priceContainer.update(with: viewModel.priceData)
        buttonContainer.update(with: viewModel.buttonData)
        indexPath = path
    }

    override func preferredLayoutAttributesFitting(
        _ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        return self.cellLayoutAttributes(attributes: layoutAttributes)
    }
}

extension AssetActionCell {
    struct ViewModel {
        var headerData: AssetHeaderView.ViewModel
        var priceData: AssetPriceView.ViewModel
        var buttonData: AssetButtonView.ViewModel
    }
}

extension AssetActionCell: AssetButtonsDelegate {
    func selectedButton(button: AssetButton, at index: Int) {
        delegate?.selectedOption(optionIndex: index, cellPath: indexPath)
    }
}

// MARK: - StylableAssetCell
extension AssetActionCell: StylableAssetCell { }
