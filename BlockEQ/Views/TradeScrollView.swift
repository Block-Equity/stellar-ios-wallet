//
//  TradeScrollView.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-06-05.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import UIKit

class TradeScrollView: UIScrollView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        next?.touchesBegan(touches, with: event)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isDragging {
            next?.touchesMoved(touches, with: event)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        next?.touchesEnded(touches, with: event)
    }
}
