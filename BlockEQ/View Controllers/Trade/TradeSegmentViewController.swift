//
//  TradingViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-05-23.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import UIKit

protocol TradeSegmentControllerDelegate: AnyObject {
    func switchedSegment(_ type: TradeSegment)
}

final class TradeSegmentViewController: ContainerViewController {
    
    var tradeSegmentDelegate: TradeSegmentControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    func setupView() {
        let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: 44))
        view.backgroundColor = UIColor.green
        
        print(parent.debugDescription)
        
        parent?.navigationController?.navigationBar.addSubview(view)
    }
}
