//
//  OrderBookViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-05-23.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import UIKit

class OrderBookViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    func setupView() {
        let tableViewNib = UINib(nibName: OrderBookCell.cellIdentifier, bundle: nil)
        tableView.register(tableViewNib, forCellReuseIdentifier: OrderBookCell.cellIdentifier)

        tableView.backgroundColor = Colors.lightBackground
    }
}

extension OrderBookViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 8
        default:
            return 8
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let frame = CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.size.width, height: OrderBookHeaderView.height))
        
        switch section {
        case 0:
            return OrderBookHeaderView(frame: frame, type: .buy, buyAsset: "MOBI", sellAsset: "XLM")
        default:
            return OrderBookHeaderView(frame: frame, type: .sell, buyAsset: "MOBI", sellAsset: "XLM")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return OrderBookHeaderView.height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: OrderBookCell.cellIdentifier, for: indexPath) as! OrderBookCell

        return cell
    }
}

extension OrderBookViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return OrderBookCell.rowHeight
    }
}
