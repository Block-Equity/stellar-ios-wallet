//
//  NavigationMenuViewController.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-04-26.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import Foundation

protocol NavigationMenuViewControllerDelegate: AnyObject {
    func selected(_ option: MenuItem)
}

final class NavigationMenuViewController: UIViewController {

    struct Constants {
        static let menuItems = [MenuItem.wallet, MenuItem.trading, MenuItem.settings]
        static let edgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
    }

    /// The table view to present menu items in
    @IBOutlet weak var tableView: UITableView!

    /// The background view
    @IBOutlet var backgroundView: UIView!

    /// Image view used for the background image
    @IBOutlet weak var imageView: UIImageView!

    /// The image view dedicated to displaying the logo
    @IBOutlet weak var logoImageView: UIImageView!

    weak var delegate: NavigationMenuViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupStyle()
    }

    func setupView() {
        tableView.registerCell(type: NavigationCell.self)

        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self

        navigationController?.isNavigationBarHidden = true
    }

    func setupStyle() {
        imageView.image = UIImage(named: "background")
        imageView.contentMode = .scaleAspectFill
        logoImageView.image = UIImage(named: "logo")
        backgroundView.backgroundColor = UIColor(red:0.008, green:0.283, blue:0.657, alpha:1.000) // TODO: fix me
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false

        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }

        tableView.contentInset = Constants.edgeInsets
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.contentInset = Constants.edgeInsets
    }
}

extension NavigationMenuViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Constants.menuItems.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return NavigationCell.Constants.cellHeight
    }
}

extension NavigationMenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: NavigationCell = tableView.dequeueReusableCell(for: indexPath)

        let menuItem = Constants.menuItems[indexPath.row]

        cell.setupStyle()
        cell.textLabel?.text = menuItem.title
        cell.imageView?.image = menuItem.icon

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let option = Constants.menuItems[indexPath.row]
        delegate?.selected(option)
    }
}
