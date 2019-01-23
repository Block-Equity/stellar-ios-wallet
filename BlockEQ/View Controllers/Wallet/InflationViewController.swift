//
//  InflationViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-04-19.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Whisper
import StellarHub

protocol InflationViewControllerDelegate: AnyObject {
    func updateAccountInflation(_ viewController: InflationViewController, destination: StellarAddress)
    func clearAccountInflation(_ viewController: InflationViewController)
    func dismiss(_ viewController: InflationViewController)
}

final class InflationViewController: UIViewController {
    @IBOutlet var addressHolderView: UIView!
    @IBOutlet var holdingView: UIView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var subtitleLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet var destinationAddressTextField: UITextField!

    weak var delegate: InflationViewControllerDelegate?
    var account: StellarAccount
    let lumenautInflationDestination = "GCCD6AJOYZCUAQLX32ZJF2MKFFAUJ53PVCFQI3RHWKL3V47QYE2BNAUT"

    init(account: StellarAccount) {
        self.account = account
        super.init(nibName: String(describing: InflationViewController.self), bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let currentInflationDestination = account.inflationDestination {
            destinationAddressTextField.text = currentInflationDestination
            subtitleLabel.text = ""
            subtitleLabelTopConstraint.constant = 0.0
        } else {
            destinationAddressTextField.text = lumenautInflationDestination
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }

    func setupView() {
        navigationItem.title = "SET_INFLATION".localized()
        tableView.backgroundColor = Colors.lightBackground
        titleLabel.textColor = Colors.darkGrayTransparent
        subtitleLabel.textColor = Colors.darkGray
        destinationAddressTextField.textColor = Colors.darkGray
        addressHolderView.backgroundColor = Colors.lightBackground
        holdingView.backgroundColor = Colors.lightBackground
        destinationAddressTextField.clearButtonMode = .whileEditing
        view.backgroundColor = Colors.lightBackground
    }
}

// MARK: - IBActions
extension InflationViewController {
    @IBAction func scanQRCode() {
        let scanViewController = ScanViewController()
        scanViewController.delegate = self

        let navigationController = AppNavigationController(rootViewController: scanViewController)
        present(navigationController, animated: true, completion: nil)
    }

    @IBAction func addInflationDestination() {
        guard let addressText = destinationAddressTextField.text, !addressText.isEmpty else {
            delegate?.clearAccountInflation(self)
            return
        }

        guard let inflationDestination = StellarAddress(addressText) else {
            destinationAddressTextField.shake()
            return
        }

        delegate?.updateAccountInflation(self, destination: inflationDestination)
    }
}

extension InflationViewController: FrameworkErrorPresentable { }

// MARK: - ScanViewControllerDelegate
extension InflationViewController: ScanViewControllerDelegate {
    func setQR(_ viewController: ScanViewController, value: String) {
        destinationAddressTextField.text = value
    }
}
