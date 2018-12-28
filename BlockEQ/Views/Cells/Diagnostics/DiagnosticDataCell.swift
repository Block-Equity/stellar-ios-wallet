//
//  DiagnosticCardSummaryView.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-11-12.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Reusable

final class DiagnosticDataCell: UICollectionViewCell, NibReusable {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var headerBackgroundView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dataStackView: UIStackView!
    @IBOutlet weak var titleHeightConstraint: NSLayoutConstraint!

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

        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .heavy)
        titleLabel.text = "DIAGNOSTIC_DATA_TITLE".localized()
        titleLabel.textColor = Colors.transactionCellDarkGray

        // We dont have enough vertical space on short devices
        if UIDevice.current.shortScreen {
            titleHeightConstraint.constant = 0
        }
    }

    func update(with diagnostic: DiagnosticDataCell.ViewModel) {
        let fields: [String] = [
            diagnostic.walletAddress,
            diagnostic.walletCreation,
            diagnostic.walletPassphrase,
            diagnostic.device,
            diagnostic.osVersion,
            diagnostic.appVersion,
            diagnostic.batteryState
            ].compactMap { return $0 }

        let labelFont = UIFont.systemFont(ofSize: 14, weight: .light)

        dataStackView.removeAllArrangedSubviews()

        fields.forEach { field in
            let label = UILabel(frame: .zero)
            label.font = labelFont
            label.textColor = Colors.transactionCellDarkGray
            label.text = field
            label.lineBreakMode = .byTruncatingMiddle
            dataStackView.addArrangedSubview(label)
        }
    }
}

extension DiagnosticDataCell {
    struct ViewModel {
        var device: String
        var osVersion: String
        var walletAddress: String
        var walletCreation: String
        var appVersion: String
        var walletPassphrase: String
        var locale: String
        var batteryState: String
    }
}

extension DiagnosticDataCell.ViewModel {
    init(with diagnostic: Diagnostic) {
        let walletDiagnostic = diagnostic.walletDiagnostic
        let appDiagnostic = diagnostic.appDiagnostic

        self.walletAddress = walletDiagnostic?.walletAddress ?? ""
        self.walletCreation = walletDiagnostic?.walletCreationMethod?.rawValue ?? ""
        self.walletPassphrase = (walletDiagnostic?.walletUsesPassphrase ?? false) ? "Uses passphrase" : "No passphrase"
        self.osVersion = appDiagnostic?.osVersion ?? ""
        self.device = appDiagnostic?.hardwareDevice ?? ""
        self.locale = appDiagnostic?.locale ?? ""
        self.batteryState = appDiagnostic?.batteryState ?? ""
        self.appVersion = appDiagnostic?.appVersion ?? ""
    }
}
