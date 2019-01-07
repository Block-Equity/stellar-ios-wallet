//
//  TransactionSection.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-10-19.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import StellarHub

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
        case .operations: return 0
        case .signatures: return 0
        }
    }

    func headerCell(_ collectionView: UICollectionView,
                    delegate: TransactionDetailsSectionHeaderDelegate?,
                    collapsed: Bool,
                    for index: IndexPath,
                    with data: String) -> UICollectionReusableView {
        var view: UICollectionReusableView

        switch self {
        case .ledger:
            let basicHeader: TransactionDetailsBasicHeader = collectionView.dequeueHeader(for: index)
            basicHeader.leftLabel.text = self.title
            basicHeader.rightLabel.text = data
            view = basicHeader
        default:
            let expandingHeader: TransactionDetailsSectionHeader = collectionView.dequeueHeader(for: index)
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
                  detailsData: TransactionDetailsCell.ViewModel,
                  opData: TransactionOperationCell.ViewModel?) -> UICollectionViewCell {
        var cell: UICollectionViewCell

        switch self {
        case .transaction:
            let detailCell: TransactionDetailsCell = collectionView.dequeueReusableCell(for: index)
            detailCell.update(with: detailsData)
            cell = detailCell
        case .operations:
            let operationCell: TransactionOperationCell = collectionView.dequeueReusableCell(for: index)
            operationCell.update(with: opData)
            cell = operationCell
        case .signatures:
            let signatureCell: TransactionSignatureCell = collectionView.dequeueReusableCell(for: index)
            signatureCell.update(with: detailsData.signers[index.row])
            cell = signatureCell
        default:
            cell = UICollectionViewCell()
        }

        return cell
    }
}
