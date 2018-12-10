//
//  TransactionDetailsDataSource.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-11-08.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import StellarHub
import stellarsdk

final class TransactionDetailsDataSource: NSObject {
    typealias SectionState = (collapsed: Bool, itemCount: Int)

    var sectionStates: [Int: SectionState] = [
        0: (collapsed: false, itemCount: 0),
        1: (collapsed: false, itemCount: 1),
        2: (collapsed: true, itemCount: 0),
        3: (collapsed: true, itemCount: 0)
    ]

    weak var headerDelegate: TransactionDetailsSectionHeaderDelegate?
    let ledgerHeaderText: String
    let sourceAccount: String
    let txid: String
    let amount: String
    let date: Date
    let sequenceNumber: String
    let fee: Int
    let operationCount: Int
    let memoType: String?
    let memo: Memo?
    let operations: [StellarOperation]
    let signers: [String]

    init(delegate: TransactionDetailsViewController,
         transaction: StellarTransaction,
         ops: [StellarOperation],
         effect: StellarEffect) {
        headerDelegate = delegate
        ledgerHeaderText = String(transaction.ledger)
        signers = transaction.signatures
        sourceAccount = transaction.sourceAccount
        txid = transaction.identifier
        amount = effect.amount.isEmpty ? "---" : effect.amount
        date = transaction.createdAt
        sequenceNumber = transaction.sequenceNumber
        fee = transaction.feePaid
        operationCount = transaction.operationCount
        memoType = transaction.memoType
        memo = transaction.memo
        operations = ops
    }
}

// MARK: UICollectionViewDataSource
// MARK: -
extension TransactionDetailsDataSource: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return TransactionSection.all.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let dataSection = TransactionSection(rawValue: section), let state = sectionStates[section] else {
            return 0
        }

        if state.collapsed { return 0 }

        switch dataSection {
        case .operations: return operations.count
        case .signatures: return signers.count
        default: return dataSection.itemCount
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = TransactionSection.all[indexPath.section]

        let stroopFee = Decimal(fee) * 0.0000001
        var memoTitle = "MEMO_TITLE".localized()
        var memoString = ""

        if let unwrappedMemo = memo?.string, let type = memoType {
            memoTitle = String(format: "MEMO_TITLE_FORMAT_STRING".localized(), type)
            memoString = unwrappedMemo
        }

        let viewModel = TransactionDetailsCell.ViewModel(
            sourceAccount: sourceAccount,
            transactionId: txid,
            amount: amount,
            date: date.longDateString,
            sequenceNumber: sequenceNumber,
            fee: String(format: "XLM_FORMAT_STRING".localized(), stroopFee.tradeFormattedString),
            operationCount: String(operationCount),
            memoType: memoTitle,
            memoData: memoString,
            signers: signers
        )

        var opViewModel: TransactionOperationCell.ViewModel?
        if section == .operations {
            let operation = self.operations[indexPath.row]
            opViewModel = TransactionOperationCell.ViewModel(
                title: operation.title,
                subtitle: operation.descriptionString,
                sequence: operation.identifier
            )
        }

        let cell = section.dataCell(collectionView, for: indexPath, detailsData: viewModel, opData: opViewModel)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        let section = TransactionSection.all[indexPath.section]
        let view: UICollectionReusableView

        if kind == UICollectionView.elementKindSectionHeader {
            let state = sectionStates[indexPath.section]!
            view = section.headerCell(collectionView,
                                      delegate: headerDelegate,
                                      collapsed: state.collapsed,
                                      for: indexPath,
                                      with: ledgerHeaderText)
        } else {
            view = UICollectionReusableView(frame: .zero)
        }

        return view
    }
}
