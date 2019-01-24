//
//  TradeSegmentHeaderView.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-05-25.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Reusable

enum TradeSegment: Int {
    case trade
    case orderBook
    case myOffers

    static var all: [TradeSegment] {
        return [.trade, .orderBook, .myOffers]
    }
}

protocol TradeHeaderViewDelegate: AnyObject {
    func switchedSegment(_ type: TradeSegment) -> Bool
}

class TradeHeaderView: UIView, NibOwnerLoadable {

    @IBOutlet weak var view: UIView!
    @IBOutlet weak var tradeButton: UIButton!
    @IBOutlet weak var orderBookButton: UIButton!
    @IBOutlet weak var myOffersButton: UIButton!
    @IBOutlet weak var sliderOriginConstraint: NSLayoutConstraint!

    var buttons: [UIButton] = []
    weak var tradeHeaderViewDelegate: TradeHeaderViewDelegate?

    fileprivate static let nibName = "TradeHeaderView"

    @IBAction func selectedButton(sender: UIButton) {
        setSelected(selectedButton: sender, animated: true)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.loadNibContent()
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.loadNibContent()
        setupView()
    }

    private func setupView() {
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
        let segment = TradeSegment.all[selectedButton.tag]
        if tradeHeaderViewDelegate?.switchedSegment(segment) == true {
            setTitleSelected(index: selectedButton.tag)
        }
    }
}
