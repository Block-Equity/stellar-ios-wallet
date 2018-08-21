//
//  ContactsViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-08-14.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import stellarsdk
import Contacts
import UIKit

protocol ContactsViewControllerDelegate: AnyObject {
    func selectedAddToAddressBook(identifier: String, name: String, address: String)
}

class ContactsViewController: UIViewController {

    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var tableViewHeaderStellar: UIView!
    @IBOutlet var tableViewHeaderStellarTitleLabel: UILabel!
    @IBOutlet var tableViewHeaderAddressBook: UIView!
    @IBOutlet var tableViewHeaderAddressBookTitleLabel: UILabel!
    @IBOutlet var accessDeniedView: UIView!

    var stellarContacts: [LocalContact] = []
    var addressBookContacts: [LocalContact] = []
    var filteredStellarContacts: [LocalContact] = []
    var filteredAddressBookContacts: [LocalContact] = []
    var accounts: [StellarAccount] = []

    weak var delegate: ContactsViewControllerDelegate?

    enum SectionType: Int {
        case stellarContacts
        case addressBookContacts

        static var all: [SectionType] {
            return [.stellarContacts, .addressBookContacts]
        }
    }

    @IBAction func addContact() {
         self.delegate?.selectedAddToAddressBook(identifier: "", name: "", address: "")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        fetchContacts()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        searchBar.text = ""
        fetchContacts()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        view.endEditing(true)
    }

    func setupView() {
        navigationItem.title = "Contacts"

        searchBar.barTintColor = Colors.lightBackground
        tableViewHeaderStellar.backgroundColor = Colors.lightBackground
        tableViewHeaderStellarTitleLabel.textColor = Colors.darkGray
        tableViewHeaderAddressBook.backgroundColor = Colors.lightBackground
        tableViewHeaderAddressBookTitleLabel.textColor = Colors.darkGray

        let tableViewNibStellarContacts = UINib(nibName: ContactStellarCell.cellIdentifier, bundle: nil)
        tableView.register(tableViewNibStellarContacts, forCellReuseIdentifier: ContactStellarCell.cellIdentifier)

        let tableViewNibContacts = UINib(nibName: ContactCell.cellIdentifier, bundle: nil)
        tableView.register(tableViewNibContacts, forCellReuseIdentifier: ContactCell.cellIdentifier)

        accessDeniedView.isHidden = true
    }

    func setRightNavigationButtonVisible() {
        let rightBarButtonItem = UIBarButtonItem(title: "Add Contact", style: .plain, target: self, action: #selector(self.addContact))
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }

    func setRightNavigationButtonHidden() {
        navigationItem.rightBarButtonItem = nil
    }

    func fetchContacts() {
        let contactsStore = CNContactStore()
        contactsStore.requestAccess(for: .contacts) { (granted, error) in
            if let _ = error {
                DispatchQueue.main.async {
                    self.setRightNavigationButtonHidden()
                    self.accessDeniedView.isHidden = false
                }

                return
            }

            if granted {
                let keys = [CNContactGivenNameKey, CNContactIdentifierKey, CNContactFamilyNameKey, CNContactEmailAddressesKey]
                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                var contacts: [CNContact] = []
                do {
                    try contactsStore.enumerateContacts(with: request, usingBlock: { (contact, _) in
                        if !contact.givenName.isEmpty {
                            contacts.append(contact)
                        }
                    })

                    DispatchQueue.main.async {
                        var allStellarContacts: [LocalContact] = []
                        var allAddressBookContacts: [LocalContact] = []

                        let nonDuplicateContacts = Array(Set(contacts))
                        for contact in nonDuplicateContacts {
                            let name = "\(contact.givenName) \(contact.familyName)"
                            var stellarEmail = ""
                            for emailAddress in contact.emailAddresses {
                                if emailAddress.value.contains(".publicaddress@blockeq.com") {
                                    stellarEmail = emailAddress.value as String
                                    break
                                }
                            }
                            let localContact = LocalContact(identifier: contact.identifier, name: name, address: stellarEmail)

                            if stellarEmail.isEmpty {
                                allAddressBookContacts.append(localContact)
                            } else {
                                allStellarContacts.append(localContact)
                            }
                        }

                        self.addressBookContacts = allAddressBookContacts.sorted { $0.name < $1.name }
                        self.stellarContacts = allStellarContacts.sorted { $0.name < $1.name }

                        self.accessDeniedView.isHidden = true
                        self.setRightNavigationButtonVisible()

                        self.filterSearch(text: nil)
                    }
                } catch let error {
                    print("Error enumerating", error.localizedDescription)
                }

            } else {
                DispatchQueue.main.async {
                    self.setRightNavigationButtonHidden()
                    self.accessDeniedView.isHidden = false
                }
            }
        }
    }

    func showHud() {
        view.endEditing(true)

        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = .indeterminate
    }

    func hideHud() {
        MBProgressHUD.hide(for: self.view, animated: true)
    }
}

extension ContactsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return SectionType.all.count
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case SectionType.stellarContacts.rawValue:
            if filteredStellarContacts.count > 0 {
                return tableViewHeaderStellar
            }
            return nil
        default:
            if filteredAddressBookContacts.count > 0 {
                return tableViewHeaderAddressBook
            }
            return nil
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case SectionType.stellarContacts.rawValue:
            if filteredStellarContacts.count > 0 {
                return tableViewHeaderStellar.frame.size.height
            }
            return 0
        default:
            if filteredAddressBookContacts.count > 0 {
                return tableViewHeaderAddressBook.frame.size.height
            }
            return 0
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case SectionType.stellarContacts.rawValue:
            return filteredStellarContacts.count
        default:
            return filteredAddressBookContacts.count
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ContactCell.rowHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case SectionType.stellarContacts.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: ContactStellarCell.cellIdentifier, for: indexPath) as! ContactStellarCell

            cell.indexPath = indexPath
            cell.delegate = self
            cell.nameLabel.text = filteredStellarContacts[indexPath.row].name
            return cell

        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: ContactCell.cellIdentifier, for: indexPath) as! ContactCell

            cell.indexPath = indexPath
            cell.delegate = self
            cell.nameLabel.text = filteredAddressBookContacts[indexPath.row].name
            return cell
        }
    }

    func filterSearch(text: String?) {
        if let searchText = text, !searchText.isEmpty {
            filteredStellarContacts = stellarContacts.filter { $0.name.lowercased().contains(searchText.lowercased()) }
            filteredAddressBookContacts = addressBookContacts.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        } else {
            filteredStellarContacts = stellarContacts
            filteredAddressBookContacts = addressBookContacts
        }

        self.tableView.reloadData()
    }
}

extension ContactsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

        switch indexPath.section {
        case SectionType.stellarContacts.rawValue:
            let identifier = stellarContacts[indexPath.row].identifier

            self.delegate?.selectedAddToAddressBook(identifier: identifier, name: filteredStellarContacts[indexPath.row].name, address: filteredStellarContacts[indexPath.row].address)
        default:
            break
        }
    }
}

extension ContactsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterSearch(text: searchText)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
}

extension ContactsViewController: ContactCellDelegate {
    func didSelectAddToAddressBook(indexPath: IndexPath) {
        let identifier = filteredAddressBookContacts[indexPath.row].identifier

        self.delegate?.selectedAddToAddressBook(identifier: identifier, name: filteredAddressBookContacts[indexPath.row].name, address: filteredAddressBookContacts[indexPath.row].address)
    }
}

extension ContactsViewController: ContactCellStellarDelegate {
    func didSendPayment(indexPath: IndexPath) {
        let address = filteredStellarContacts[indexPath.row].address.replacingOccurrences(of: ".publicaddress@blockeq.com", with: "")

        getAccountDetails(address: address)
    }
}

/*
 * Operations
 */
extension ContactsViewController {
    func getAccountDetails(address: String) {
        guard let accountId = KeychainHelper.getAccountId() else {
            return
        }

        showHud()

        AccountOperation.getAccountDetails(accountId: accountId) { responseAccounts in
            self.accounts = responseAccounts

            if responseAccounts.isEmpty {
                self.accounts.removeAll()

                let stellarAccount = StellarAccount()
                stellarAccount.accountId = accountId

                let stellarAsset = StellarAsset(assetType: AssetTypeAsString.NATIVE, assetCode: nil, assetIssuer: nil, balance: "0.0000")

                stellarAccount.assets.removeAll()
                stellarAccount.assets.append(stellarAsset)

                self.accounts.append(stellarAccount)
            }

            self.checkForExchange(receiver: address, stellarAccount: self.accounts[0])
        }
    }

    func checkForExchange(receiver: String, stellarAccount: StellarAccount) {
        PaymentTransactionOperation.checkForExchange(address: receiver) { address in
            self.hideHud()

            let selectAssetViewController = SelectAssetViewController(stellarAccount: stellarAccount, receiver: receiver, exchangeName: address)
            let navigationController = AppNavigationController(rootViewController: selectAssetViewController)
            navigationController.navigationBar.prefersLargeTitles = true

            self.present(navigationController, animated: true, completion: nil)
        }
    }
}
