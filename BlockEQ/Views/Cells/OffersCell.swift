//
//  OffersCell.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-05-28.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Reusable

protocol OffersCellDelegate: AnyObject {
    func deleteOffer(indexPath: IndexPath)
}

final class OffersCell: UITableViewCell, NibReusable {
    @IBOutlet weak var offerLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!

    static let rowHeight: CGFloat = 80.0

    weak var delegate: OffersCellDelegate?
    var indexPath: IndexPath!

    @IBAction func deleteOffer() {
        guard let cellIndexPath = indexPath else {
            return
        }
        delegate?.deleteOffer(indexPath: cellIndexPath)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        offerLabel.textColor = Colors.darkGray
        deleteButton.tintColor = Colors.red
        deleteButton.contentMode = .scaleAspectFit
    }
}
