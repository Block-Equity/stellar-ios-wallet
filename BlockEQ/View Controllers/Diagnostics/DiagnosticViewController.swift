//
//  DiagnosticViewController.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-11-12.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Foundation

protocol DiagnosticViewControllerDelegate: AnyObject {
    func selectedNextStep(_ viewController: DiagnosticViewController)
    func selectedClose(_ viewController: DiagnosticViewController)
}

final class DiagnosticViewController: UIViewController {
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var stepCollectionView: UICollectionView!

    static let compressedHeight = CGFloat(290)
    static let cellSpacing = CGFloat(30)
    static let cellCornerRadius = CGFloat(25)

    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

    weak var delegate: DiagnosticViewControllerDelegate?
    var dataViewModel: DiagnosticDataCell.ViewModel?
    var completedViewModel: DiagnosticCompletedCell.ViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        completedViewModel = nil
        dataViewModel = nil
    }

    func setupView() {
        view.backgroundColor = Colors.backgroundDark
        let nextImage = UIImage(named: "disclosure_indicator")?.withRenderingMode(.alwaysTemplate)
        let closeImage = UIImage(named: "close")?.withRenderingMode(.alwaysTemplate)

        closeButton.setImage(closeImage, for: .normal)
        nextButton.setImage(nextImage, for: .normal)
        nextButton.tintColor = .white
        closeButton.tintColor = .white

        titleLabel.textColor = Colors.lightGray
        descriptionLabel.textColor = Colors.lightGray
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        descriptionLabel.font = UIFont.systemFont(ofSize: 18, weight: .light)

        stepCollectionView.register(cellType: DiagnosticDataCell.self)
        stepCollectionView.register(cellType: DiagnosticCompletedCell.self)

        stepCollectionView.delegate = self
        stepCollectionView.dataSource = self
        stepCollectionView.isScrollEnabled = false
        stepCollectionView.backgroundColor = .clear
        stepCollectionView.showsVerticalScrollIndicator = false
        stepCollectionView.showsHorizontalScrollIndicator = false
        stepCollectionView.decelerationRate = UIScrollView.DecelerationRate.fast

        if let layout = stepCollectionView.collectionViewLayout as? CenteredCollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = DiagnosticViewController.cellSpacing
            layout.minimumInteritemSpacing = stepCollectionView.bounds.height
            layout.itemSize = cellSize(for: stepCollectionView)
        }

        titleLabel?.text = DiagnosticCoordinator.DiagnosticStep.summary.title
        descriptionLabel?.text = DiagnosticCoordinator.DiagnosticStep.summary.description
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let layout = stepCollectionView.collectionViewLayout as? CenteredCollectionViewFlowLayout {
            layout.itemSize = cellSize(for: stepCollectionView)
        }
    }

    func scrollTo(step: DiagnosticCoordinator.DiagnosticStep, animated: Bool) {
        titleLabel?.text = step.title
        descriptionLabel?.text = step.description
        nextButton?.isHidden = step != DiagnosticCoordinator.DiagnosticStep.summary

        let indexPath = IndexPath(row: step.index, section: 0)
        stepCollectionView?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }

    func update(with diagnostic: Diagnostic) {
        self.dataViewModel = DiagnosticDataCell.ViewModel(with: diagnostic)
        self.stepCollectionView?.reloadData()
    }

    func update(with result: DiagnosticCoordinator.DiagnosticStep, identifier: Int?) {
        hideHud()

        completedViewModel = DiagnosticCompletedCell.ViewModel(
            image: result.image,
            text: result.status,
            color: result.color
        )

        self.scrollTo(step: result, animated: true)
    }

    func showHud() {
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.label.text = "SENDING_DIAGNOSTIC".localized()
        hud.mode = .indeterminate
    }

    func hideHud() {
        MBProgressHUD.hide(for: view, animated: true)
    }

    func cellSize(for collectionView: UICollectionView) -> CGSize {
        let minHeight = min(DiagnosticViewController.compressedHeight, stepCollectionView.bounds.height)
        let height = UIDevice.current.shortScreen ? stepCollectionView.frame.height : minHeight
        let width = collectionView.frame.width - DiagnosticViewController.cellSpacing * 2
        return CGSize(width: width, height: height)
    }
}

extension DiagnosticViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return DiagnosticCoordinator.DiagnosticStep.all.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        var cell: UICollectionViewCell
        switch indexPath.row {
        case 0:
            let dataCell: DiagnosticDataCell = collectionView.dequeueReusableCell(for: indexPath)
            if let viewModel = self.dataViewModel {
                dataCell.update(with: viewModel)
            }
            cell = dataCell
        default:
            let completedCell: DiagnosticCompletedCell = collectionView.dequeueReusableCell(for: indexPath)
            if let viewModel = self.completedViewModel {
                completedCell.update(with: viewModel)
            }
            cell = completedCell
        }

        return cell
    }
}

extension DiagnosticViewController: UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("selected \(indexPath.row)")
    }
}

extension DiagnosticViewController {
    @IBAction func selectedClose(_ sender: Any) {
        delegate?.selectedClose(self)
    }

    @IBAction func selectedNext(_ sender: Any) {
        delegate?.selectedNextStep(self)
    }
}
