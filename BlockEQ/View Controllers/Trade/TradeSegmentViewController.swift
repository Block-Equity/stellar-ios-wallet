//
//  TradingViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-05-23.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import StellarHub

protocol TradeSegmentControllerDelegate: AnyObject {
    func setScroll(offset: CGFloat, page: Int)
    func displayAssetList()
}

final class TradeSegmentViewController: UIViewController {
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var noAssetView: UIView!

    var leftViewController: UIViewController!
    var rightViewController: UIViewController!
    var middleViewController: UIViewController!
    var totalPages: CGFloat!
    var displayNoAssetOverlay: Bool = true

    weak var tradeSegmentDelegate: TradeSegmentControllerDelegate?

    override var preferredStatusBarStyle: UIStatusBarStyle { return .default }

    @IBAction func addAsset() {
        tradeSegmentDelegate?.displayAssetList()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init(leftViewController: UIViewController,
         middleViewController: UIViewController,
         rightViewController: UIViewController,
         totalPages: CGFloat) {
        super.init(nibName: String(describing: TradeSegmentViewController.self), bundle: nil)
        self.leftViewController = leftViewController
        self.middleViewController = middleViewController
        self.rightViewController = rightViewController
        self.totalPages = totalPages
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.refreshView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    func refreshView() {
        guard self.isViewLoaded else { return }

        if displayNoAssetOverlay {
            displayNoAssetOverlayView()
        } else {
            hideNoAssetOverlayView()
        }
    }

    func setupView() {
        scrollView.backgroundColor = Colors.lightBackground
        noAssetView.isHidden = true
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        let leftView = UIView(frame: CGRect(origin: .zero, size: scrollView.frame.size))
        scrollView.addSubview(leftView)

        let middleRect = CGRect(origin: CGPoint(x: scrollView.frame.size.width, y: 0.0), size: scrollView.frame.size)
        let middleView = UIView(frame: middleRect)
        scrollView.addSubview(middleView)

        let rightRect = CGRect(origin: CGPoint(x: scrollView.frame.size.width * 2, y: 0.0), size: scrollView.frame.size)
        let rightView = UIView(frame: rightRect)
        scrollView.addSubview(rightView)

        self.addContentViewController(leftViewController, to: leftView)
        self.addContentViewController(middleViewController, to: middleView)
        self.addContentViewController(rightViewController, to: rightView)

        scrollView.contentSize = CGSize(width: view.frame.size.width * totalPages, height: scrollView.frame.size.height)
        scrollView.isPagingEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
    }

    func switchSegment(_ type: TradeSegment) -> Bool {
        guard displayNoAssetOverlay != true else { return false }

        let offset = CGPoint(x: scrollView.frame.size.width * CGFloat(type.rawValue), y: 0.0)
        scrollView.setContentOffset(offset, animated: true)
        return true
    }

    func displayNoAssetOverlayView() {
        if noAssetView.isHidden {
            noAssetView.alpha = 0.0
            noAssetView.isHidden = false
            UIView.animate(withDuration: 0.3, animations: {
                self.noAssetView.alpha = 1.0
            })
        }
    }

    func hideNoAssetOverlayView() {
        noAssetView.isHidden = true
    }
}

extension TradeSegmentViewController: AccountUpdatable {
    func updated(account: StellarAccount) {
        displayNoAssetOverlay = account.assets.count <= 1 ? true : false

        self.refreshView()
    }
}

extension TradeSegmentViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)

        let totalOffset = view.frame.size.width * totalPages
        let scrollOffset = (scrollView.contentOffset.x / totalOffset) * scrollView.frame.size.width
        let page = Int(scrollView.contentOffset.x / scrollView.frame.size.width)

        tradeSegmentDelegate?.setScroll(offset: scrollOffset, page: page)
    }
}
