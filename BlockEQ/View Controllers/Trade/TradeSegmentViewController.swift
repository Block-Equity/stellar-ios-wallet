//
//  TradingViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-05-23.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import UIKit

enum TradeSegment: Int {
    case trade
    case orderBook
    case myOffers
    
    static var all: [TradeSegment] {
        return [.trade, .orderBook, .myOffers]
    }
}

protocol TradeSegmentControllerDelegate: AnyObject {
    func switchedSegment(_ type: TradeSegment)
}

final class TradeSegmentViewController: ContainerViewController {
    
    @IBOutlet var segmentControl: UISegmentedControl!
    @IBOutlet var segmentView: UIView!
    
    var tradeSegmentDelegate: TradeSegmentControllerDelegate?
    
    @IBAction func segmentSelected() {
        tradeSegmentDelegate?.switchedSegment(TradeSegment.all[segmentControl.selectedSegmentIndex])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    func setupView() {
        navigationItem.titleView = segmentView
    }
}
