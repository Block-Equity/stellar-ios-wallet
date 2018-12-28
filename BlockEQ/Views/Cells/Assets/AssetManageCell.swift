//
//  AssetAddCell.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-12-24.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Reusable

protocol IndexableCell {
    var indexPath: IndexPath? { get }
}

protocol AssetManageCellDelegate: AnyObject {
    func selectedAction(mode: AssetManageCell.Mode, cellPath: IndexPath?)
}

final class AssetManageCell: UICollectionViewCell, Reusable, NibOwnerLoadable, IndexableCell {
    @IBOutlet var view: UIView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var headerContainer: AssetHeaderView!
    @IBOutlet weak var actionButton: UIButton!

    @IBOutlet weak var cardLeftInset: NSLayoutConstraint!
    @IBOutlet weak var cardBottomInset: NSLayoutConstraint!
    @IBOutlet weak var cardTopInset: NSLayoutConstraint!
    @IBOutlet weak var cardRightInset: NSLayoutConstraint!

    weak var delegate: AssetManageCellDelegate?

    var mode: Mode = .add
    var indexPath: IndexPath?
    var preferredWidth: CGFloat?
    var cardInset: UIEdgeInsets = .zero

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.loadNibContent()
        setupStyle()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.loadNibContent()
        setupStyle()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        actionButton.layer.cornerRadius = actionButton.frame.width / 2
    }

    func setupStyle() {
        view.backgroundColor = .clear

        actionButton.layer.cornerRadius = actionButton.frame.width / 2
        actionButton.contentVerticalAlignment = .center
        actionButton.titleLabel?.baselineAdjustment = .alignCenters
        actionButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        actionButton.tintColor = .white

        applyCardStyle()
    }

    func update(with viewModel: ViewModel, indexPath path: IndexPath) {
        headerContainer.update(with: viewModel.headerData)
        mode = viewModel.mode

        switch viewModel.mode {
        case .add:
            actionButton.setTitle("+", for: .normal)
            actionButton.backgroundColor = Colors.green

        case .remove:
            actionButton.setTitle("-", for: .normal)
            actionButton.backgroundColor = Colors.red
        }

        indexPath = path
    }

    override func preferredLayoutAttributesFitting(
        _ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        return self.cellLayoutAttributes(attributes: layoutAttributes)
    }
}

// MARK: - IBActions
extension AssetManageCell {
    @IBAction func selectedAction(_ sender: Any) {
        delegate?.selectedAction(mode: mode, cellPath: indexPath)
    }
}

// MARK: - StylableCardCell
extension AssetManageCell: StylableCardCell { }

extension AssetManageCell {
    enum Mode {
        case add
        case remove
    }

    struct ViewModel {
        var headerData: AssetHeaderView.ViewModel
        var mode: AssetManageCell.Mode
    }
}
