//
//  AssetIssuerCell.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-12-24.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Reusable

final class AssetIssuerCell: UICollectionViewCell, Reusable, NibOwnerLoadable, IndexableCell {
    @IBOutlet var view: UIView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var headerContainer: AssetHeaderView!
    @IBOutlet weak var priceContainer: AssetPriceView!
    @IBOutlet weak var issuerContainer: AssetIssuerView!

    @IBOutlet weak var cardBottomInset: NSLayoutConstraint!
    @IBOutlet weak var cardLeftInset: NSLayoutConstraint!
    @IBOutlet weak var cardRightInset: NSLayoutConstraint!
    @IBOutlet weak var cardTopInset: NSLayoutConstraint!

    var cardInset: UIEdgeInsets = .zero
    var preferredWidth: CGFloat?
    var preferredHeight: CGFloat?
    var indexPath: IndexPath?
    var cornerMask: CACornerMask?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.loadNibContent()
        setupStyle()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.loadNibContent()
        setupStyle()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        headerContainer.update(with: AssetHeaderView.ViewModel.empty)
        issuerContainer.update(with: AssetIssuerView.ViewModel.empty)
        priceContainer.update(with: AssetPriceView.ViewModel.empty)
        preferredWidth = nil
        preferredHeight = nil
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
        issuerContainer.backgroundColor = .clear

        applyCardStyle()
    }

    func update(with viewModel: ViewModel, indexPath path: IndexPath) {
        headerContainer.update(with: viewModel.headerData)
        priceContainer.update(with: viewModel.priceData)
        issuerContainer.update(with: viewModel.issuerData)
        indexPath = path
    }

    override func preferredLayoutAttributesFitting(
        _ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        return self.cellLayoutAttributes(attributes: layoutAttributes)
    }
}

extension AssetIssuerCell {
    struct ViewModel {
        var headerData: AssetHeaderView.ViewModel
        var priceData: AssetPriceView.ViewModel
        var issuerData: AssetIssuerView.ViewModel
    }
}

extension AssetIssuerCell: StylableCardCell { }
