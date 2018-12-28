//
//  MyOffersHeaderView.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-06-05.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Reusable

class MyOffersHeaderView: UIView, NibOwnerLoadable {

    @IBOutlet weak var option1Label: UILabel!
    @IBOutlet weak var option2Label: UILabel!
    @IBOutlet weak var option3Label: UILabel!
    @IBOutlet weak var view: UIView!

    static let height: CGFloat = 36.0

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
        option1Label.text = "Selling"
        option2Label.text = "Price"
        option3Label.text = "Receiving"

        option1Label.textColor = Colors.darkGray
        option2Label.textColor = Colors.darkGray
        option3Label.textColor = Colors.darkGray
    }

}
