//
//  TransactionDetailsViewController.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-10-17.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import os.log
import StellarAccountService

// MARK: View Controller
// MARK: -

final class TransactionDetailsViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!

    private var dataSource: TransactionDetailsDataSource?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupStyle()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView?.dataSource = self.dataSource
        collectionView?.reloadData()
    }

    func setupView() {
        collectionView.delegate = self
        collectionView.dataSource = dataSource
        collectionView.allowsSelection = true
        collectionView.registerHeader(type: TransactionDetailsBasicHeader.self)
        collectionView.registerHeader(type: TransactionDetailsSectionHeader.self)
        collectionView.registerCell(type: TransactionDetailsCell.self)
        collectionView.registerCell(type: TransactionOperationCell.self)
        collectionView.registerCell(type: TransactionSignatureCell.self)
    }

    func setupStyle() {
        let backgroundColor = UIColor(red: 0.941, green: 0.941, blue: 0.941, alpha: 1.000)
        navigationItem.title = "TRANSACTION_TITLE".localized()
        view.backgroundColor = backgroundColor
        collectionView.backgroundColor = backgroundColor
    }

    func update(with data: StellarTransaction, _ operations: [StellarOperation]) {
        let transactionDataSource = TransactionDetailsDataSource(delegate: self, transaction: data, ops: operations)
        dataSource = transactionDataSource
    }
}

// MARK: UICollectionViewDelegate
// MARK: -

extension TransactionDetailsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = TransactionSection(rawValue: indexPath.section) else { return }

        var copyString: String?
        var titleString: String = ""

        switch section {
        case .transaction:
            copyString = dataSource?.txid
            titleString = "TXID_COPIED".localized()
        case .signatures:
            copyString = dataSource?.signers[indexPath.row]
            titleString = "SIGNER_COPIED".localized()
        case .operations:
            copyString = dataSource?.operations[indexPath.row].identifier
            titleString = "OPERATION_ID_COPIED".localized()
        default: break
        }

        if copyString != nil {
            UIPasteboard.general.string = copyString
            UIAlertController.simpleAlert(title: titleString, message: nil, presentingViewController: self)
        }
    }

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
}

// MARK: UICollectionViewDelegateFlowLayout
// MARK: -

extension TransactionDetailsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = TransactionSection.all[indexPath.section].cellHeight
        return CGSize(width: collectionView.frame.size.width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        let height = TransactionSection.all[section].headerHeight
        return CGSize(width: collectionView.frame.width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        if section > 0 {
            return UIEdgeInsets(top: 1, left: 0, bottom: TransactionSection.spacing, right: 0)
        } else {
            return .zero
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension TransactionDetailsViewController: TransactionDetailsSectionHeaderDelegate {
    func toggle(_ view: TransactionDetailsSectionHeader, index: IndexPath, collapsed: Bool) {
        let section = index.section
        dataSource?.sectionStates[section] = (collapsed: collapsed, TransactionSection.all[section].itemCount)
        collectionView.reloadSections([section])
    }
}
