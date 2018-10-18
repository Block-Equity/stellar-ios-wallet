//
//  TransactionDetailsViewController.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-10-17.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import os.log

final class TransactionDetailsViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!

    private let effect: StellarEffect?

    init(_ effect: StellarEffect) {
        self.effect = effect
        super.init(nibName: String(describing: TransactionDetailsViewController.self), bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        self.effect = nil
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupStyle()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    func setupView() {
//        let currentLayout = collectionView.collectionViewLayout
        collectionView.delegate = self
    }

    func setupStyle() {
        navigationItem.title = "Transaction".localized()
    }
}

extension TransactionDetailsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        os_log("Selected item")
    }
}

extension TransactionDetailsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 100.0)
    }
}
