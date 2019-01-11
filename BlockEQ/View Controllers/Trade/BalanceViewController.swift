//
//  BalanceViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-07-12.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import StellarHub

protocol BalanceViewControllerDelegate: AnyObject {
    func dismiss(_ viewController: BalanceViewController)
}

final class BalanceViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!

    private var asset: StellarAsset!
    private var dataSource: AssetBalanceDataSource?

    weak var delegate: BalanceViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupStyle()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.dataSource = self.dataSource
        collectionView.reloadData()
    }

    func setupStyle() {
        view.backgroundColor = Colors.collectionViewBackground

        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        collectionView.showsHorizontalScrollIndicator = false

        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
            layout.scrollDirection = .vertical
            layout.minimumLineSpacing = 0
        }

        collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }

    func setupView() {
        setupNavHeader()

        collectionView.register(cellType: AssetIssuerCell.self)

        collectionView.registerHeader(BalanceHeader.self)
        collectionView.register(cellType: BalanceItemCell.self)

        collectionView.delegate = self
    }

    func setupNavHeader() {
        navigationItem.title = "ASSET_BALANCE".localized()

        let rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "close"),
                                                 style: .plain,
                                                 target: self,
                                                 action: #selector(self.dismissView))

        navigationItem.rightBarButtonItem = rightBarButtonItem
    }

    func update(with asset: StellarAsset, account: StellarAccount) {
        self.asset = asset

        let dataSource = AssetBalanceDataSource(asset: asset, account: account)
        self.dataSource = dataSource

        guard isViewLoaded else { return }
        collectionView.dataSource = dataSource
        collectionView.reloadData()
    }

    @objc func dismissView() {
        delegate?.dismiss(self)
    }
}

extension BalanceViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return section == 1 ? CGSize(width: collectionView.bounds.width, height: 75) : .zero
    }
}

extension BalanceViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return false
    }
}

extension BalanceViewController: AccountUpdatable {
    func updated(account: StellarAccount) {
        self.update(with: self.asset, account: account)
    }
}
