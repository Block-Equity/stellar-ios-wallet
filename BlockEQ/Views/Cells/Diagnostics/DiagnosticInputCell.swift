//
//  DiagnosticInputCell.swift
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
    @IBOutlet weak var summaryTitleLabel: UILabel!
    @IBOutlet weak var emailTitleLabel: UILabel!
    @IBOutlet weak var summaryTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var cellWidthConstraint: NSLayoutConstraint!

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
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.backgroundColor = Colors.transparent
        backgroundView?.backgroundColor = Colors.transparent
        containerView.backgroundColor = Colors.white
        headerBackgroundView.backgroundColor = Colors.lightGray

        iconImageView.image = UIImage(named: "icon-clipboard")
        iconImageView.tintColor = Colors.white
        iconImageView.contentMode = .scaleAspectFit

        summaryTitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .heavy)
        summaryTitleLabel.text = "ISSUE_SUMMARY".localized()
        summaryTitleLabel.textColor = Colors.transactionCellDarkGray

        emailTitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .heavy)
        emailTitleLabel.text = "EMAIL_ADDRESS".localized()
        emailTitleLabel.textColor = Colors.transactionCellDarkGray
    }
}
