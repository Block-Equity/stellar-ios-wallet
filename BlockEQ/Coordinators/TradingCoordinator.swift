//
//  TradingCoordinator.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-05-23.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import Foundation

protocol TradingCoordinatorDelegate: AnyObject {
    func setScroll(offset: CGFloat, page: Int)
}

final class TradingCoordinator {
    let segmentController: TradeSegmentViewController!
    
    var delegate: TradingCoordinatorDelegate?
    
    var tradeViewController: TradeViewController = {
        let vc = TradeViewController()
        return vc
    }()
    
    var orderBookViewController: OrderBookViewController = {
        let vc = OrderBookViewController()
        return vc
    }()
    
    var myOffersViewController: MyOffersViewController = {
        let vc = MyOffersViewController()
        return vc
    }()
    
    init() {
        segmentController = TradeSegmentViewController(leftViewController: tradeViewController, middleViewController: orderBookViewController, rightViewController: myOffersViewController, totalPages: CGFloat(TradeSegment.all.count))
        segmentController.tradeSegmentDelegate = self
    }
    
    func switchedSegment(_ type: TradeSegment) {
        segmentController.switchSegment(type)
    }
}

extension TradingCoordinator: TradeSegmentControllerDelegate {
    func setScroll(offset: CGFloat, page: Int) {
        delegate?.setScroll(offset: offset, page: page)
    }
}

