//
//  BalanceItemCell.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2019-01-10.
//  Copyright © 2019 BlockEQ. All rights reserved.
//

import Reusable

final class BalanceItemCell: UICollectionViewCell, Reusable, NibOwnerLoadable {
    @IBOutlet var view: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!

    var cardView: UIView! { return self.containerView }
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

    override func prepareForReuse() {
        super.prepareForReuse()

        cornerMask = nil

        update(with: BalanceItemCell.ViewModel.empty)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let defaultMask: CACornerMask = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner,
                                         .layerMinXMaxYCorner, .layerMinXMinYCorner]

        containerView.layer.maskedCorners = cornerMask ?? defaultMask
    }

    func setupStyle() {
        view.backgroundColor = .clear
        containerView.backgroundColor = Colors.white

        cardStyle(view: cardView)
    }

    func update(with viewModel: ViewModel) {
        titleLabel.text = viewModel.title
        amountLabel.text = viewModel.amount
        valueLabel.text = viewModel.value

        var font: UIFont
        if let weight = viewModel.weight {
            font = UIFont.systemFont(ofSize: 12, weight: weight)
        } else {
            font = UIFont.systemFont(ofSize: 12, weight: .regular)
        }

        titleLabel.font = font
        amountLabel.font = font
        valueLabel.font = font
    }

    override func preferredLayoutAttributesFitting(
        _ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        return self.cellLayoutAttributes(attributes: layoutAttributes)
    }
}

extension BalanceItemCell: StylableBalanceCell { }

extension BalanceItemCell {
    struct ViewModel {
        static let empty = ViewModel(title: nil, amount: nil, value: nil, weight: nil)
        let title: String?
        let amount: String?
        let value: String?
        let weight: UIFont.Weight?
    }
}
