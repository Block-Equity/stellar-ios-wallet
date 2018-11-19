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

    static let cellSpacing = CGFloat(30)
    static let stepCornerRadius = CGFloat(25)

    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

    weak var delegate: DiagnosticViewControllerDelegate?
    var viewModel: DiagnosticDataCell.ViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
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

        stepCollectionView.registerCell(type: DiagnosticDataCell.self)
        stepCollectionView.registerCell(type: DiagnosticCompletedCell.self)

        stepCollectionView.isPagingEnabled = true
        stepCollectionView.backgroundColor = .clear
        stepCollectionView.delegate = self
        stepCollectionView.dataSource = self
        stepCollectionView.showsVerticalScrollIndicator = false
        stepCollectionView.showsHorizontalScrollIndicator = false
        stepCollectionView.isScrollEnabled = false

        let layout = stepCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.scrollDirection = .horizontal
        layout?.minimumLineSpacing = DiagnosticViewController.cellSpacing
        layout?.minimumInteritemSpacing = DiagnosticViewController.cellSpacing
        layout?.estimatedItemSize = CGSize(width: stepCollectionView.frame.width, height: 200)

        titleLabel?.text = DiagnosticCoordinator.DiagnosticStep.summary.title
        descriptionLabel?.text = DiagnosticCoordinator.DiagnosticStep.summary.description
    }

    func scrollTo(step: DiagnosticCoordinator.DiagnosticStep, animated: Bool) {
        titleLabel?.text = step.title
        descriptionLabel?.text = step.description
        nextButton?.isHidden = step == .completion

        let indexPath = IndexPath(row: step.rawValue, section: 0)
        stepCollectionView?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }

    func update(with diagnostic: Diagnostic) {
        self.viewModel = DiagnosticDataCell.ViewModel(with: diagnostic)
        self.stepCollectionView?.reloadData()
    }
}

extension DiagnosticViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        var cell: UICollectionViewCell

        switch indexPath.row {
        case 0:
            let dataCell: DiagnosticDataCell = collectionView.dequeueReusableCell(for: indexPath)
            if let viewModel = self.viewModel {
                dataCell.update(with: viewModel)
            }
            cell = dataCell
        default:
            let completedCell: DiagnosticCompletedCell = collectionView.dequeueReusableCell(for: indexPath)
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

extension DiagnosticViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: DiagnosticViewController.cellSpacing,
                            bottom: 0, right: DiagnosticViewController.cellSpacing)
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
