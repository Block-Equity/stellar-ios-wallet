//
//  BalanceHeaderCell.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2019-01-10.
//  Copyright © 2019 BlockEQ. All rights reserved.
//

import Reusable

final class BalanceHeader: UICollectionReusableView, Reusable, NibOwnerLoadable {
    @IBOutlet var view: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var totalTitleLabel: UILabel!
    @IBOutlet weak var totalDescriptionLabel: UILabel!
    @IBOutlet weak var availableTitleLabel: UILabel!
    @IBOutlet weak var availableDescriptionLabel: UILabel!
    @IBOutlet weak var containerView: UIView!

    var preferredWidth: CGFloat?
    var preferredHeight: CGFloat?
    var cornerMask: CACornerMask?

    var cardView: UIView! {
        return containerView
    }

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
        update(with: BalanceHeader.ViewModel.empty)
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
        totalDescriptionLabel.textColor = Colors.priceDarkGray
        availableDescriptionLabel.textColor = Colors.priceDarkGray

        cardStyle(view: cardView)
        cardView.layer.shadowColor = UIColor.clear.cgColor
    }

    func update(with viewModel: ViewModel) {
        totalTitleLabel.text = viewModel.totalTitle
        availableTitleLabel.text = viewModel.availableTitle
        totalDescriptionLabel.text = viewModel.totalDescription
        availableDescriptionLabel.text = viewModel.availableDescription

        if let titleFont = viewModel.titleFont {
            totalTitleLabel.font = titleFont
            availableTitleLabel.font = titleFont
        } else {
            totalTitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
            availableTitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        }

        if let descriptionFont = viewModel.descriptionFont {
            totalDescriptionLabel.font = descriptionFont
            availableDescriptionLabel.font = viewModel.descriptionFont
        } else {
            totalDescriptionLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
            availableDescriptionLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        }
    }
}

extension BalanceHeader: StylableBalanceCell { }

extension BalanceHeader {
    struct ViewModel {
        static let empty = ViewModel(totalTitle: nil,
                                     totalDescription: nil,
                                     availableTitle: nil,
                                     availableDescription: nil)
        let totalTitle: String?
        let totalDescription: String?
        let availableTitle: String?
        let availableDescription: String?

        let titleFont: UIFont?
        let descriptionFont: UIFont?

        init(totalTitle: String?,
             totalDescription: String?,
             availableTitle: String?,
             availableDescription: String?,
             titleFont: UIFont? = nil,
             descriptionFont: UIFont? = nil) {
            self.totalTitle = totalTitle
            self.totalDescription = totalDescription
            self.availableTitle = availableTitle
            self.availableDescription = availableDescription
            self.titleFont = titleFont
            self.descriptionFont = descriptionFont
        }
    }
}
