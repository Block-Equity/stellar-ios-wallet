//
//  TradeSegmentHeaderView.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-05-25.
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

protocol TradeHeaderViewDelegate: AnyObject {
    func switchedSegment(_ type: TradeSegment)
}

class TradeHeaderView: UIView {

    @IBOutlet weak var view: UIView!
    @IBOutlet weak var tradeButton: UIButton!
    @IBOutlet weak var orderBookButton: UIButton!
    @IBOutlet weak var myOffersButton: UIButton!
    @IBOutlet weak var sliderOriginConstraint: NSLayoutConstraint!
    
    var buttons: [UIButton] = []
    var tradeHeaderViewDelegate: TradeHeaderViewDelegate?
    
    fileprivate static let nibName = "TradeHeaderView"
    
    @IBAction func selectedButton(sender: UIButton) {
        setSelected(selectedButton: sender, animated: true)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupView()
    }
    
    private func setupView() {
        view = NibLoader<UIView>(nibName: TradeHeaderView.nibName).loadView(owner: self)
        view.frame = CGRect(origin: .zero, size: frame.size)
        view.autoresizingMask = UIViewAutoresizing.flexibleWidth
        
        addSubview(view)
        
        buttons = [tradeButton, orderBookButton, myOffersButton]
        
        setSelected(selectedButton: tradeButton, animated: false)
    }
    
    func setTitleSelected(index: Int) {
        for button in buttons {
            if button.tag == index {
                button.setTitleColor(Colors.primaryDark, for: .normal)
            } else {
                button.setTitleColor(Colors.darkGrayTransparent, for: .normal)
            }
        }
    }

    func setSelected(selectedButton: UIButton, animated: Bool) {
        setTitleSelected(index: selectedButton.tag)

        tradeHeaderViewDelegate?.switchedSegment(TradeSegment.all[selectedButton.tag])
    }
}
