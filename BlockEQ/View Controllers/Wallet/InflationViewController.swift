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

    func setupView() {
        navigationItem.title = "SET_INFLATION".localized()
        tableView.backgroundColor = Colors.lightBackground
        titleLabel.textColor = Colors.darkGrayTransparent
        subtitleLabel.textColor = Colors.darkGray
        destinationAddressTextField.textColor = Colors.darkGray
        addressHolderView.backgroundColor = Colors.lightBackground
        holdingView.backgroundColor = Colors.lightBackground
        view.backgroundColor = Colors.lightBackground
    }
}

// MARK: - Prompts
extension InflationViewController {
    func displayInflationSuccess() {
        self.view.endEditing(true)

        let message = Message(title: "INFLATION_SUCCESSFULLY_UPDATED".localized(), backgroundColor: Colors.green)
        Whisper.show(whisper: message, to: navigationController!, action: .show)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            Whisper.hide(whisperFrom: self.navigationController!)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.dismissView()
            }
        }
    }

    func showHud() {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = "SETTING_INFLATION_DESTINATION".localized()
        hud.mode = .indeterminate
    }

    func hideHud() {
        MBProgressHUD.hide(for: self.view, animated: true)
    }

    func dismissView() {
        view.endEditing(true)
        delegate?.dismiss(self)
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
        guard let inflationDestination = StellarAddress(destinationAddressTextField.text) else {
            destinationAddressTextField.shake()
            return
        }

        let inflationString = inflationDestination.string
        guard inflationString != account.accountId, inflationString != account.inflationDestination else {
            UIAlertController.simpleAlert(title: "INVALID_DESTINATION_TITLE".localized(),
                                          message: "INFLATION_DESTINATION_INVALID".localized(),
                                          presentingViewController: self)
            return
        }

        showHud()
        delegate?.updateAccountInflation(self, destination: inflationDestination)
    }
}

// MARK: - ManageAssetDisplayable
extension InflationViewController: ManageAssetDisplayable {
    func displayLoading(for asset: StellarAsset? = nil) {
        showHud()
    }

    func hideLoading() {
        hideHud()
    }

    func displayError(error: FrameworkError) {
        hideHud()
        displayFrameworkError(error, fallbackData: (title: "INFLATION_ERROR_TITLE", message: "INFLATION_ERROR_MESSAGE"))
    }
}

extension InflationViewController: FrameworkErrorPresentable { }

// MARK: - ScanViewControllerDelegate
extension InflationViewController: ScanViewControllerDelegate {
    func setQR(_ viewController: ScanViewController, value: String) {
        destinationAddressTextField.text = value
    }
}
