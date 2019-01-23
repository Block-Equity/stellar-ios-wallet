//
//  AssetListViewController.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-12-27.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import StellarHub
import Reusable

protocol AssetListViewControllerDelegate: AnyObject {
    func requestedAddNewAsset(_ viewController: UIViewController)
    func requestedDismiss(_ viewController: UIViewController)
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

    weak var delegate: AssetListViewControllerDelegate?
    weak var dataSource: AssetListDataSource? {
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reload()
    }

    func setupView() {
        collectionView.registerHeader(AssetListHeader.self)
        collectionView.register(cellType: AssetManageCell.self)
        collectionView.register(cellType: AssetActionCell.self)
        collectionView.register(cellType: AssetAmountCell.self)
        collectionView.register(cellType: AssetIssuerCell.self)
    }

    func setupStyle() {
        view.backgroundColor = Colors.collectionViewBackground

        addAssetView.backgroundColor = .clear
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = true
        collectionView.showsHorizontalScrollIndicator = false

        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.minimumLineSpacing = 15
            flowLayout.scrollDirection = .vertical
            flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
            flowLayout.sectionInset = UIEdgeInsets(top: 5, left: 0, bottom: 20, right: 0)
        }

        collectionView.contentInset = UIEdgeInsets(top: 5, left: 10, bottom: 0, right: 10)

        emptyAssetImageView.image = UIImage(named: "wallet-large")
        emptyAssetImageView.tintColor = Colors.lightGray

        emptyAssetTitleLabel.text = "NO_ASSETS_TITLE".localized()
        emptyAssetTitleLabel.textColor = Colors.darkGray
        emptyAssetTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)

        emptyAssetDescriptionLabel.text = "NO_ASSETS_DESCRIPTION".localized()
        emptyAssetDescriptionLabel.textColor = Colors.transactionCellMediumGray
        emptyAssetDescriptionLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)

        setupNavHeader()
    }

    func setupNavHeader() {
        let rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "close"),
                                                 style: .plain,
                                                 target: self,
                                                 action: #selector(self.dismissView))

        navigationItem.rightBarButtonItem = rightBarButtonItem
        navigationItem.title = "ASSETS".localized()
    }

    func reload(section: Int? = nil) {
        if let section = section {
            let indexSet = IndexSet([section])
            collectionView.reloadSections(indexSet)
        } else {
            collectionView.reloadData()
        }

        guard let dataSource = dataSource else {
            showEmptyAssets()
            return
        }

        let assetItems = dataSource.collectionView(collectionView, numberOfItemsInSection: 0)
        let availableItems = dataSource.collectionView(collectionView, numberOfItemsInSection: 1)

        if assetItems == 0, availableItems == 0 {
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

    func showHud(message: String) {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = message
        hud.mode = .indeterminate
    }

    func hideHud() {
        MBProgressHUD.hide(for: self.view, animated: true)
    }

    func displayAssetActivationError(_ error: FrameworkError) {
        let fallbackTitle = "ACTIVATION_ERROR_TITLE".localized()
        let fallbackMessage = "ASSET_BALANCE_ERROR_MESSAGE".localized()
        self.displayFrameworkError(error, fallbackData: (title: fallbackTitle, message: fallbackMessage))
    }

    func displayAssetDeactivationError(_ error: FrameworkError) {
        let fallbackTitle = "ACTIVATION_ERROR_TITLE".localized()
        let fallbackMessage = "ASSET_REMOVE_ERROR_MESSAGE".localized()
        self.displayFrameworkError(error, fallbackData: (title: fallbackTitle, message: fallbackMessage))
    }

    func displayLowBalanceError(minimum: String) {
        let message = String(format: "LOW_BALANCE_ERROR_MESSAGE".localized(), minimum)
        let alert = UIAlertController(title: "NO_BALANCE_ERROR_TITLE".localized(),
                                      message: message,
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "GENERIC_OK_TEXT".localized(), style: .default, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - FrameworkErrorPresentable
extension AssetListViewController: FrameworkErrorPresentable { }

// MARK: - IBActions
extension AssetListViewController {
    @IBAction func dismissView() {
        delegate?.requestedDismiss(self)
    }

    @IBAction func selectedAddAsset(_ sender: Any) {
        delegate?.requestedAddNewAsset(self)
    }
}
