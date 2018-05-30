//
//  MyOffersViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-05-23.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import UIKit

class MyOffersViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    func setupView() {
        let offersCellNib = UINib(nibName: OffersCell.cellIdentifier, bundle: nil)
        tableView.register(offersCellNib, forCellReuseIdentifier: OffersCell.cellIdentifier)
        
        let orderBookEmptyNib = UINib(nibName: OrderBookEmptyCell.cellIdentifier, bundle: nil)
        tableView.register(orderBookEmptyNib, forCellReuseIdentifier: OrderBookEmptyCell.cellIdentifier)
        
        tableView.backgroundColor = Colors.lightBackground
    }
}

extension MyOffersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: OrderBookEmptyCell.cellIdentifier, for: indexPath) as! OrderBookEmptyCell
        
        return cell
    }
}

extension MyOffersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return OrderBookEmptyCell.rowHeight
    }
}
