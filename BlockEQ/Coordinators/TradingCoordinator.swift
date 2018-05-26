//
//  TradingCoordinator.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-05-23.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import Foundation

final class TradingCoordinator {
    let segmentController = TradeSegmentViewController()
    
    lazy var tradeViewController: TradeViewController = {
        let vc = TradeViewController()
        return vc
    }()
    
    lazy var orderBookViewController: OrderBookViewController = {
        let vc = OrderBookViewController()
        return vc
    }()
    
    lazy var myOffersViewController: MyOffersViewController = {
        let vc = MyOffersViewController()
        return vc
    }()
    
    init() {
        //segmentController.tradeSegmentDelegate = self
        segmentController.setViewController(tradeViewController, animated: false, completion: nil)
    }
    
    func switchedSegment(_ type: TradeSegment) {
        var vc: UIViewController
        
        switch type {
        case .trade: vc = tradeViewController
        case .orderBook: vc = orderBookViewController
        case .myOffers: vc = myOffersViewController
        }
        
        segmentController.setViewController(vc, animated: false, completion: nil)
    }
}

