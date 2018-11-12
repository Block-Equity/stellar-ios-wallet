//
//  DiagnosticCardSummaryView.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-11-12.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

final class DiagnosticDataCell: UICollectionViewCell, ReusableView, NibLoadableView {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var headerBackgroundView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dataStackView: UIStackView!

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

        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .heavy)
        titleLabel.text = "DIAGNOSTIC_DATA_TITLE".localized()
        titleLabel.textColor = Colors.transactionCellDarkGray
    }

    func update(with diagnostic: DiagnosticDataCell.ViewModel) {
        let fields: [String] = [
            diagnostic.device,
            diagnostic.osVersion,
            diagnostic.appVersion,
            diagnostic.locale,
            diagnostic.batteryState,
            diagnostic.walletAddress,
            diagnostic.walletCreation,
            diagnostic.walletPassphrase
            ].compactMap { return $0 }

        let labelFont = UIFont.systemFont(ofSize: 14, weight: .light)

        dataStackView.removeAllArrangedSubviews()

        fields.forEach { field in
            let label = UILabel(frame: .zero)
            label.font = labelFont
            label.textColor = Colors.transactionCellDarkGray
            label.text = field
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
        self.walletAddress = diagnostic.walletAddress ?? ""
        self.walletCreation = diagnostic.walletCreationMethod?.rawValue ?? ""
        self.walletPassphrase = (diagnostic.walletUsesPassphrase ?? false) ? "Uses passphrase" : "No passphrase"
        self.osVersion = diagnostic.osVersion
        self.device = diagnostic.hardwareDevice
        self.locale = diagnostic.locale
        self.batteryState = diagnostic.batteryState
        self.appVersion = diagnostic.appVersion
    }
}
