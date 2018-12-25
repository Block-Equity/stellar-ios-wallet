//
//  AssetAddCell.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-12-24.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Foundation

protocol AssetManageCellDelegate: AnyObject {
    func selectedAction(mode: AssetManageCell.Mode)
}

final class AssetManageCell: UICollectionViewCell, ReusableView, NibLoadableView {
    @IBOutlet var view: UIView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var headerContainer: UIView!
    @IBOutlet weak var actionButton: UIButton!

    let headerView = AssetHeaderView(frame: .zero)

    weak var delegate: AssetManageCellDelegate?
    var mode: Mode = .add

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupStyle()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
        setupStyle()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        actionButton.layer.cornerRadius = actionButton.frame.width / 2
    }

    func setupView() {
        let nibView: UIView = NibLoader<UIView>(nibName: AssetManageCell.nibName).loadView(owner: self)
        contentView.addSubview(nibView)
        contentView.constrainViewToAllEdges(nibView)

        headerContainer.addSubview(headerView)
        headerContainer.constrainViewToAllEdges(headerView)
    }

    func setupStyle() {
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 5
        cardView.clipsToBounds = false
        cardView.layer.masksToBounds = false

        actionButton.contentVerticalAlignment = .center
        actionButton.titleLabel?.baselineAdjustment = .alignCenters
        actionButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        actionButton.tintColor = .white
    }

    func update(with viewModel: ViewModel) {
        headerView.update(with: viewModel.headerData)
        mode = viewModel.mode

        switch viewModel.mode {
        case .add:
            actionButton.setTitle("+", for: .normal)
            actionButton.backgroundColor = Colors.green

        case .remove:
            actionButton.setTitle("-", for: .normal)
            actionButton.backgroundColor = Colors.red
        }
    }

    @IBAction func selectedAction(_ sender: Any) {
        delegate?.selectedAction(mode: mode)
    }
}

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
