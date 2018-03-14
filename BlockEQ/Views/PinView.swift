//
//  PinView.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-03-09.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import UIKit

class PinView: UIView {
    @IBOutlet weak var dotView: UIView!
    @IBOutlet weak var underlineView: UIView!
    @IBOutlet weak var view: UIView!
    
    fileprivate static let nibName = "PinView"
    
    init(frame: CGRect, title: String) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupView()
    }
    
    private func setupView() {
        view = NibLoader<UIView>(nibName: PinView.nibName).loadView(owner: self)
        view.frame = CGRect(origin: .zero, size: frame.size)
        view.autoresizingMask = UIViewAutoresizing.flexibleWidth
        view.backgroundColor = Colors.primaryDark
        
        addSubview(view)
    }
    
    public func setEmpty() {
        dotView.isHidden = true
        
        underlineView.backgroundColor = Colors.whiteTransparent
    }
    
    public func setFilled() {
        dotView.backgroundColor = Colors.white
        dotView.isHidden = false
        
        underlineView.backgroundColor = Colors.white
    }
}
