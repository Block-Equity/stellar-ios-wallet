//
//  AssetListViewController.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-12-27.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import StellarHub
import Reusable

protocol AssetListDelegate: AnyObject {
    func requestedAddNewAsset()
}

protocol AssetActionDelegate: AnyObject {
    func requestedAdd(asset: StellarAsset)
    func requestedRemove(asset: StellarAsset)
    func requestedAction(_ actionIndex: Int, for asset: StellarAsset)
}

protocol AssetSelectionDelegate: AnyObject {
    func selected(_ asset: StellarAsset)
}

final class AssetListViewController: UIViewController {

    static let AddAssetViewHeight = CGFloat(60)
    private var templateHeader: AssetListHeader!

    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet weak var addAssetButton: AppButton!
    @IBOutlet weak var addAssetView: UIView!
    @IBOutlet weak var addAssetHeight: NSLayoutConstraint!

    @IBOutlet var emptyAssetView: UIView!
    @IBOutlet weak var emptyAssetImageView: UIImageView!
    @IBOutlet weak var emptyAssetTitleLabel: UILabel!
    @IBOutlet weak var emptyAssetDescriptionLabel: UILabel!

    weak var delegate: AssetListDelegate?

    weak var dataSource: AccountAssetListDataSource? {
        didSet {
            collectionView.dataSource = dataSource
            collectionView.delegate = dataSource
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupStyle()
    }

    func setupView() {
        collectionView.registerHeader(AssetListHeader.self)
        collectionView.register(cellType: AssetManageCell.self)
        collectionView.register(cellType: AssetActionCell.self)
        collectionView.register(cellType: AssetAmountCell.self)
        collectionView.register(cellType: AssetIssuerCell.self)
    }

    func setupStyle() {
        view.backgroundColor = UIColor(red: 0.936, green: 0.941, blue: 0.941, alpha: 1.000)

        addAssetView.backgroundColor = .clear
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = true
        collectionView.showsHorizontalScrollIndicator = false

        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.minimumLineSpacing = 20
            flowLayout.scrollDirection = .vertical
            flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
            flowLayout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 20, right: 10)
        }

        emptyAssetImageView.image = UIImage(named: "wallet-large")
        emptyAssetImageView.tintColor = Colors.lightGray

        emptyAssetTitleLabel.text = "NO_ASSETS_TITLE".localized()
        emptyAssetTitleLabel.textColor = Colors.darkGray
        emptyAssetTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)

        emptyAssetDescriptionLabel.text = "NO_ASSETS_DESCRIPTION".localized()
        emptyAssetDescriptionLabel.textColor = Colors.transactionCellMediumGray
        emptyAssetDescriptionLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
    }

    func reload(section: Int? = nil) {
        if let section = section {
            let indexSet = IndexSet([section])
            collectionView.reloadSections(indexSet)
        } else {
            collectionView.reloadData()
        }

        if dataSource?.collectionView(collectionView, numberOfItemsInSection: 0) == 0 {
            showEmptyAssets()
        } else {
            hideEmptyAssets()
        }
    }

    func showAddAsset(height: CGFloat = AssetListViewController.AddAssetViewHeight) {
        addAssetHeight.constant = height
        addAssetView.isHidden = false
    }

    func hideAddAsset() {
        addAssetHeight.constant = 0
        addAssetView.isHidden = true
    }

    func showEmptyAssets() {
        emptyAssetView.isHidden = false
    }

    func hideEmptyAssets() {
        emptyAssetView.isHidden = true
    }

    @IBAction func selectedAddAsset(_ sender: Any) {
        guard let asset = dataSource?.asset(for: IndexPath(row: 0, section: 0)), asset.isNative else {
//                        displayNoBalanceError()
            print("error! fixme!")
            return
        }

        delegate?.requestedAddNewAsset()
    }
}
