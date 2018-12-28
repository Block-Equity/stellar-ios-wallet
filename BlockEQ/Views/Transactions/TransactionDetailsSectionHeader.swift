//
//  TransactionDetailsSectionHeader.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-10-17.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Reusable

// See: https://stackoverflow.com/a/46737582
class ZOrderBugLayer: CALayer {
    override var zPosition: CGFloat {
        get { return 0 }
        set {}
    }
}

protocol TransactionDetailsSectionHeaderDelegate: AnyObject {
    func toggle(_ view: TransactionDetailsSectionHeader, index: IndexPath, collapsed: Bool)
}

final class TransactionDetailsSectionHeader: UICollectionReusableView, NibReusable {
    @IBOutlet weak var headerTitle: UILabel!
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var containerView: UIView!

    var collapsed: Bool = false {
        didSet {
            headerImageView.transform = self.arrowTransform
        }
    }

    var index: IndexPath = IndexPath(row: 0, section: 0)

    var tapGestureRecognizer: UIGestureRecognizer?
    weak var delegate: TransactionDetailsSectionHeaderDelegate?

    var arrowTransform: CGAffineTransform {
        let angle = self.collapsed ? 0 : Double.pi * 0.9999
        return CGAffineTransform(rotationAngle: CGFloat(-angle))
    }

    override static var layerClass: AnyClass {
        return ZOrderBugLayer.self
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectedHeader(_:)))
        self.addGestureRecognizer(tapRecognizer)
        self.tapGestureRecognizer = tapRecognizer

        headerImageView.image = UIImage(named: "arrowDown")

        setupStyle()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        setupStyle()
    }

    func setupStyle() {
        backgroundColor = Colors.transparent
        containerView.backgroundColor = Colors.white

        headerTitle.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        headerTitle.textColor = Colors.transactionCellDarkGray
        headerImageView.tintColor = Colors.primaryDark
        headerImageView.contentMode = .center

        containerView.topBorder(with: Colors.transactionCellBorderGray, width: 1)

        headerTitle.text = nil
    }

    @IBAction func selectedHeader(_ sender: Any) {
        guard let enabled = self.tapGestureRecognizer?.isEnabled, enabled == true else {
            return
        }

        self.tapGestureRecognizer?.isEnabled = false
        self.collapsed.toggle()
        self.delegate?.toggle(self, index: self.index, collapsed: self.collapsed)
        self.tapGestureRecognizer?.isEnabled = true
    }
}
