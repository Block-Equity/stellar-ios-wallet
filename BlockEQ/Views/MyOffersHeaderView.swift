//
//  MyOffersHeaderView.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-06-05.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import UIKit

class MyOffersHeaderView: UIView {

    @IBOutlet weak var option1Label: UILabel!
    @IBOutlet weak var option2Label: UILabel!
    @IBOutlet weak var option3Label: UILabel!
    @IBOutlet weak var view: UIView!
    
    static let height: CGFloat = 36.0
    fileprivate static let nibName = "MyOffersHeaderView"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupView()
    }
    
    private func setupView() {
        view = NibLoader<UIView>(nibName: MyOffersHeaderView.nibName).loadView(owner: self)
        view.frame = CGRect(origin: .zero, size: frame.size)
        view.autoresizingMask = UIViewAutoresizing.flexibleWidth
        
        addSubview(view)

        option1Label.text = "Selling"
        option2Label.text = "Price"
        option3Label.text = "Receiving"
        
        option1Label.textColor = Colors.darkGray
        option2Label.textColor = Colors.darkGray
        option3Label.textColor = Colors.darkGray
    }

}
