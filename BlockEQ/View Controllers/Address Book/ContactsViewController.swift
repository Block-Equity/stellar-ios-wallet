//
//  ContactsViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-08-14.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import Contacts
import UIKit

protocol ContactsViewControllerDelegate: AnyObject {
    func selectedAddToAddressBook(identifier: String, name: String)
}

class ContactsViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var tableViewHeaderStellar: UIView!
    @IBOutlet var tableViewHeaderStellarTitleLabel: UILabel!
    @IBOutlet var tableViewHeaderAddressBook: UIView!
    @IBOutlet var tableViewHeaderAddressBookTitleLabel: UILabel!
    
    var stellarContacts: [LocalContact] = []
    var addressBookContacts: [LocalContact] = []
    
    weak var delegate: ContactsViewControllerDelegate?
    
    enum SectionType: Int {
        case stellarContacts
        case addressBookContacts
        
        static var all: [SectionType] {
            return [.stellarContacts, .addressBookContacts]
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        fetchContacts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchContacts()
    }
    
    func setupView() {
        navigationItem.title = "Contacts"
        
        tableViewHeaderStellar.backgroundColor = Colors.lightBackground
        tableViewHeaderStellarTitleLabel.textColor = Colors.darkGray
        
        tableViewHeaderAddressBook.backgroundColor = Colors.lightBackground
        tableViewHeaderAddressBookTitleLabel.textColor = Colors.darkGray
        
        let tableViewNibStellarContacts = UINib(nibName: ContactStellarCell.cellIdentifier, bundle: nil)
        tableView.register(tableViewNibStellarContacts, forCellReuseIdentifier: ContactStellarCell.cellIdentifier)
        
        let tableViewNibContacts = UINib(nibName: ContactCell.cellIdentifier, bundle: nil)
        tableView.register(tableViewNibContacts, forCellReuseIdentifier: ContactCell.cellIdentifier)
    }
    
    func fetchContacts() {
        let contactsStore = CNContactStore()
        contactsStore.requestAccess(for: .contacts) { (granted, error) in
            if let fetchError = error {
                print("Unable to get contacts", fetchError)
                return
            }
            
            if granted {
                print("Access Granted")
                let keys = [CNContactGivenNameKey, CNContactIdentifierKey, CNContactFamilyNameKey, CNContactEmailAddressesKey]
                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                var contacts: [CNContact] = []
                do {
                    try contactsStore.enumerateContacts(with: request, usingBlock: { (contact, stopPointer) in
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
                        
                        self.addressBookContacts = allAddressBookContacts.sorted{ $0.name < $1.name }
                        self.stellarContacts = allStellarContacts.sorted{ $0.name < $1.name }
                        self.tableView.reloadData()
                    }
                } catch let error {
                    print("Error enumerating", error.localizedDescription)
                }
                
            } else {
                print("Access Denied")
            }
        }
    }
}

extension ContactsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return SectionType.all.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case SectionType.stellarContacts.rawValue:
            if stellarContacts.count > 0 {
                return tableViewHeaderStellar
            }
            return nil
        default:
            if addressBookContacts.count > 0 {
                return tableViewHeaderAddressBook
            }
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case SectionType.stellarContacts.rawValue:
            if stellarContacts.count > 0 {
                return tableViewHeaderStellar.frame.size.height
            }
            return 0
        default:
            if addressBookContacts.count > 0 {
                return tableViewHeaderAddressBook.frame.size.height
            }
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case SectionType.stellarContacts.rawValue:
            return stellarContacts.count
        default:
            return addressBookContacts.count
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
            cell.nameLabel.text = stellarContacts[indexPath.row].name
            return cell
            
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: ContactCell.cellIdentifier, for: indexPath) as! ContactCell
            
            cell.indexPath = indexPath
            cell.delegate = self
            cell.nameLabel.text = addressBookContacts[indexPath.row].name
            return cell
        }
    }
}

extension ContactsViewController: ContactCellDelegate {
    func didSelectAddToAddressBook(indexPath: IndexPath) {
        let identifier = addressBookContacts[indexPath.row].identifier
        
        self.delegate?.selectedAddToAddressBook(identifier: identifier, name: addressBookContacts[indexPath.row].name)
    }
}

extension ContactsViewController: ContactCellStellarDelegate {
    func didSendPayment(indexPath: IndexPath) {
        print("Send Payment", indexPath)
    }
}
