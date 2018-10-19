//
//  TransactionSection.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-10-19.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Foundation

enum TransactionSection: Int, RawRepresentable {
    case ledger
    case transaction
    case operations
    case signatures

    var title: String {
        switch self {
        case .ledger: return "LEDGER_TITLE".localized()
        case .transaction: return "TRANSACTION_TITLE".localized()
        case .operations: return "OPERATIONS_TITLE".localized()
        case .signatures: return  "SIGNATURES_TITLE".localized()
        }
    }

    static var all: [TransactionSection] {
        return [.ledger, .transaction, .operations, .signatures]
    }

    static var spacing: CGFloat {
        return 25
    }

    var headerHeight: CGFloat {
        switch self {
        case .ledger: return 45.0
        default: return 55.0
        }
    }

    var cellHeight: CGFloat {
        switch self {
        case .ledger: return 0.0
        case .transaction: return TransactionDetailsCell.cellHeight
        case .operations: return TransactionOperationCell.cellHeight
        case .signatures: return TransactionSignatureCell.cellHeight
        }
    }

    var itemCount: Int {
        switch self {
        case .ledger: return 0
        case .transaction: return 1
        case .operations: return 5
        case .signatures: return 3
        }
    }

    func headerCell(_ collectionView: UICollectionView,
                    delegate: TransactionDetailsViewController,
                    collapsed: Bool,
                    for index: IndexPath,
                    with data: StellarEffect?) -> UICollectionReusableView {
        var view: UICollectionReusableView

        switch self {
        case .ledger:
            let basicHeader: TransactionDetailsBasicHeader = collectionView.dequeueReusableHeader(for: index)
            basicHeader.leftLabel.text = self.title
            basicHeader.rightLabel.text = "00000000"//data.ledgerNumber
            view = basicHeader
        default:
            let expandingHeader: TransactionDetailsSectionHeader = collectionView.dequeueReusableHeader(for: index)
            expandingHeader.collapsed = collapsed
            expandingHeader.headerTitle.text = self.title
            expandingHeader.delegate = delegate
            expandingHeader.index = index
            view = expandingHeader
        }

        return view
    }

    func dataCell(_ collectionView: UICollectionView,
                  for index: IndexPath,
                  with data: StellarEffect?) -> UICollectionViewCell {
        var cell: UICollectionViewCell

        switch self {
        case .transaction:
            let detailCell: TransactionDetailsCell = collectionView.dequeueReusableCell(for: index)

            detailCell.update(with: TransactionDetailsCell.ViewModel(
                sourceAccount: "",
                transactionId: "",
                date: Date(),
                sequenceNumber: "",
                fee: "",
                operationCount: "",
                memoType: "",
                memoData: ""
            ))
            cell = detailCell
        case .operations:
            let operationCell: TransactionOperationCell = collectionView.dequeueReusableCell(for: index)
            cell = operationCell
        case .signatures:
            let signatureCell: TransactionSignatureCell = collectionView.dequeueReusableCell(for: index)
            signatureCell.signatureLabel.text = "Signer \(index.row)"
            cell = signatureCell
        default:
            cell = UICollectionViewCell()
        }

        return cell
    }
}
