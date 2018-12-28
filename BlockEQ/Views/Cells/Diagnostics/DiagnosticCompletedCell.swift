//
//  DiagnosticCardCompletedView.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-11-12.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Reusable

final class DiagnosticCompletedCell: UICollectionViewCell, NibReusable {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var diagnosticIdLabel: UILabel!

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
        containerView.layer.cornerRadius = DiagnosticViewController.cellCornerRadius
    }

    func setupStyle() {
        contentView.backgroundColor = Colors.transparent
        backgroundView?.backgroundColor = Colors.transparent
        containerView.backgroundColor = Colors.white

        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
        titleLabel.text = "DIAGNOSTIC_ID_TITLE".localized()

        imageView.image = UIImage(named: "icon-check")
        imageView.tintColor = Colors.green

        diagnosticIdLabel.textColor = Colors.darkGray
        diagnosticIdLabel.font = UIFont.systemFont(ofSize: 30, weight: .heavy)
        diagnosticIdLabel.text = "31"
    }

    func update(with viewModel: ViewModel) {
        diagnosticIdLabel.text = viewModel.text
        imageView.image = viewModel.image
        imageView.tintColor = viewModel.color
    }
}

extension DiagnosticCompletedCell {
    struct ViewModel {
        let image: UIImage?
        let text: String
        let color: UIColor
    }
}
