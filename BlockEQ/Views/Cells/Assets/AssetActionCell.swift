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

    @IBOutlet weak var cardLeftInset: NSLayoutConstraint!
    @IBOutlet weak var cardRightInset: NSLayoutConstraint!
    @IBOutlet weak var cardBottomInset: NSLayoutConstraint!
    @IBOutlet weak var cardTopInset: NSLayoutConstraint!

    weak var delegate: AssetActionCellDelegate?

    var indexPath: IndexPath?
    var preferredWidth: CGFloat?
    var cardInset: UIEdgeInsets = .zero

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

    func setupStyle() {
        view.backgroundColor = .clear

        headerContainer.backgroundColor = .clear
        priceContainer.backgroundColor = .clear
        buttonContainer.backgroundColor = .clear

        applyCardStyle()
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
    func selectedFirstButton(button: AssetButton) {
        delegate?.selectedOption(optionIndex: 0, cellPath: indexPath)
    }

    func selectedSecondButton(button: AssetButton) {
        delegate?.selectedOption(optionIndex: 1, cellPath: indexPath)
    }

    func selectedThirdButton(button: AssetButton) {
        delegate?.selectedOption(optionIndex: 2, cellPath: indexPath)
    }
}

// MARK: - StylableCardCell
extension AssetActionCell: StylableCardCell { }
