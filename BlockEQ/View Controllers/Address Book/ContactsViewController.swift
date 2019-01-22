//
//  ContactsViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-08-14.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import StellarHub
import stellarsdk
import Contacts

protocol ContactsViewControllerDelegate: AnyObject {
    func selectedAddToAddressBook(identifier: String, name: String, address: String)
    func requestedSendPayment(contact: LocalContact)
}

final class ContactsViewController: UIViewController {
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var tableViewHeaderStellar: UIView!
    @IBOutlet var tableViewHeaderStellarTitleLabel: UILabel!
    @IBOutlet var tableViewHeaderAddressBook: UIView!
    @IBOutlet var tableViewHeaderAddressBookTitleLabel: UILabel!
    @IBOutlet var accessDeniedView: UIView!

    var accountService: AccountManagementService
    weak var delegate: ContactsViewControllerDelegate?
    var dataSource: ContactsDataSource? {
        didSet {
            dataSource?.filterResults(with: nil)
            tableView.dataSource = dataSource
        }
    }

    init(service: AccountManagementService) {
        self.accountService = service
        super.init(nibName: String(describing: ContactsViewController.self), bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()

        guard let account = accountService.account else {
            return
        }

        checkContactAccess { contactStore in
            let dataSource = ContactsDataSource(contactStore: contactStore, account: account, cellDelegate: self)
            self.dataSource = dataSource
            self.tableView.reloadData()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard let account = self.accountService.account else {
            return
        }

        searchBar.text = ""
        checkContactAccess { contactStore in
            let dataSource = ContactsDataSource(contactStore: contactStore, account: account, cellDelegate: self)
            self.dataSource = dataSource
        }

        tableView.reloadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        view.endEditing(true)
    }

    func setupView() {
        navigationItem.title = "TITLE_TAB_CONTACTS".localized()

        searchBar.barTintColor = Colors.lightBackground
        tableViewHeaderStellar.backgroundColor = Colors.lightBackground
        tableViewHeaderStellarTitleLabel.textColor = Colors.darkGray
        tableViewHeaderAddressBook.backgroundColor = Colors.lightBackground
        tableViewHeaderAddressBookTitleLabel.textColor = Colors.darkGray

        tableView.register(cellType: StellarContactCell.self)
        tableView.register(cellType: ContactCell.self)
        tableView.delegate = self

        accessDeniedView.isHidden = true
    }

    func setRightNavigationButtonVisible() {
        let rightBarButtonItem = UIBarButtonItem(title: "ADD_CONTACT".localized(),
                                                 style: .plain,
                                                 target: self,
                                                 action: #selector(self.addContact))
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }

    func setRightNavigationButtonHidden() {
        navigationItem.rightBarButtonItem = nil
    }

    func displayNoAccess() {
        self.setRightNavigationButtonHidden()
        self.accessDeniedView.isHidden = false
    }

    func displayAccess() {
        self.accessDeniedView.isHidden = true
        self.setRightNavigationButtonVisible()
    }

    func showHud() {
        view.endEditing(true)

        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = .indeterminate
    }

    func hideHud() {
        MBProgressHUD.hide(for: self.view, animated: true)
    }

    @IBAction func addContact() {
        self.delegate?.selectedAddToAddressBook(identifier: "", name: "", address: "")
    }
}

extension ContactsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let section = ContactsDataSource.SectionType(rawValue: section),
            let dataSource = dataSource else { return nil }

        switch section {
        case .stellarContacts: return dataSource.hasFilteredStellarContacts ? tableViewHeaderStellar : nil
        default: return dataSource.hasFilteredNormalContacts ? tableViewHeaderAddressBook : nil
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let section = ContactsDataSource.SectionType(rawValue: section),
            let dataSource = dataSource else { return 0 }

        switch section {
        case .stellarContacts:
            return dataSource.hasFilteredStellarContacts ? tableViewHeaderStellar.frame.size.height : 0
        default:
            return dataSource.hasFilteredNormalContacts ? tableViewHeaderAddressBook.frame.size.height : 0
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

        guard let section = ContactsDataSource.SectionType(rawValue: indexPath.section),
            let dataSource = self.dataSource else {
                return
        }

        switch section {
        case .stellarContacts:
            let item = dataSource.stellarContacts[indexPath.row]
            delegate?.selectedAddToAddressBook(identifier: item.identifier, name: item.name, address: item.address)
        default:
            break
        }
    }
}

extension ContactsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.dataSource?.filterResults(with: searchText)
        self.tableView.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
}

extension ContactsViewController {
    func checkContactAccess(grantedCompletion: @escaping (CNContactStore) -> Void) {
        let contactsStore = CNContactStore()

        contactsStore.requestAccess(for: .contacts) { granted, error in
            DispatchQueue.main.async {
                guard error == nil && granted else {
                    self.displayNoAccess()
                    return
                }

                grantedCompletion(contactsStore)
                self.displayAccess()
            }
        }
    }
}

extension ContactsViewController: ContactCellDelegate {
    func didSelectAddToAddressBook(indexPath: IndexPath) {
        guard let item = dataSource?.filteredAddressBookContacts[indexPath.row] else { return }
        delegate?.selectedAddToAddressBook(identifier: item.identifier, name: item.name, address: item.address)
    }
}

extension ContactsViewController: StellarContactCellDelegate {
    func didRequestPayment(indexPath: IndexPath) {
        guard let item = dataSource?.filteredStellarContacts[indexPath.row] else { return }
        delegate?.requestedSendPayment(contact: item)
    }
}
