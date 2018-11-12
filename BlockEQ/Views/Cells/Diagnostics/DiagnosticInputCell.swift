//
//  DiagnosticCardCell.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-11-12.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Foundation

final class DiagnosticInputCell: UICollectionViewCell, ReusableView, NibLoadableView {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var headerBackgroundView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var issueSummaryLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupStyle()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        setupStyle()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.layer.cornerRadius = DiagnosticViewController.stepCornerRadius
        headerBackgroundView.layer.cornerRadius = headerBackgroundView.frame.width / 2.0
    }

    func setupStyle() {
        contentView.backgroundColor = Colors.transparent
        backgroundView?.backgroundColor = Colors.transparent
        containerView.backgroundColor = Colors.white
        headerBackgroundView.backgroundColor = Colors.lightGray

        iconImageView.image = UIImage(named: "icon-clipboard")
        iconImageView.tintColor = Colors.white
        iconImageView.contentMode = .scaleAspectFit

        issueSummaryLabel.font = UIFont.systemFont(ofSize: 18, weight: .heavy)
        issueSummaryLabel.text = "ISSUE_SUMMARY".localized()
        issueSummaryLabel.textColor = Colors.transactionCellDarkGray

        emailLabel.font = UIFont.systemFont(ofSize: 18, weight: .heavy)
        emailLabel.text = "EMAIL_ADDRESS".localized()
        emailLabel.textColor = Colors.transactionCellDarkGray
    }
}
