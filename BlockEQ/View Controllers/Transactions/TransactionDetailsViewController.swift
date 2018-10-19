//
//  TransactionDetailsViewController.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-10-17.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import os.log

// MARK: View Controller
// MARK: -

final class TransactionDetailsViewController: UIViewController {
    typealias SectionState = (collapsed: Bool, itemCount: Int)

    @IBOutlet weak var collectionView: UICollectionView!

    var sectionStates: [Int: SectionState] = [
        0: (collapsed: false, itemCount: 0),
        1: (collapsed: false, itemCount: 1),
        2: (collapsed: true, itemCount: 5),
        3: (collapsed: true, itemCount: 3)
    ]

    private var effect: StellarEffect?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupStyle()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    func setupView() {
        collectionView.delegate = self
        collectionView.dataSource = self
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

    func update(with data: StellarEffect) {
        self.effect = data
        collectionView?.reloadData()
    }
}

// MARK: UICollectionViewDataSource
// MARK: -

extension TransactionDetailsViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return TransactionSection.all.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let state = sectionStates[section] else {
            return 0
        }

        return state.collapsed ? 0 : state.itemCount
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = TransactionSection.all[indexPath.section]
        let cell = section.dataCell(collectionView, for: indexPath, with: self.effect)
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
                                      delegate: self,
                                      collapsed: state.collapsed,
                                      for: indexPath,
                                      with: self.effect)
        } else {
            view = UICollectionReusableView(frame: .zero)
        }

        return view
    }
}

// MARK: UICollectionViewDelegate
// MARK: -

extension TransactionDetailsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        os_log("Selected item")
    }

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return false
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
        sectionStates[index.section] = (collapsed: collapsed, TransactionSection.all[index.section].itemCount)
        collectionView.reloadSections([index.section])
    }
}
