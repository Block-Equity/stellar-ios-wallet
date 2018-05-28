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
        let tableViewNib = UINib(nibName: OffersCell.cellIdentifier, bundle: nil)
        tableView.register(tableViewNib, forCellReuseIdentifier: OffersCell.cellIdentifier)
        
        tableView.backgroundColor = Colors.lightBackground
    }
}

extension MyOffersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: OffersCell.cellIdentifier, for: indexPath) as! OffersCell
        
        return cell
    }
}

extension MyOffersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return OffersCell.rowHeight
    }
}
