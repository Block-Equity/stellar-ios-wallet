//
//  NavigationCell.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-04-27.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Reusable

final class NavigationCell: UITableViewCell, Reusable {

    struct Constants {
        static let cellHeight: CGFloat = 65
        static let fontSize: CGFloat = 19
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView?.image = nil
        textLabel?.text = nil

        setupStyle()
    }

    func setupStyle() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        textLabel?.font = UIFont.systemFont(ofSize: Constants.fontSize, weight: .ultraLight)
        textLabel?.textColor = .white
    }
}
