//
//  ContactsDataSource.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-10-25.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import StellarHub
import stellarsdk
import Contacts

protocol ContactsDataSourceDelegate: AnyObject {
    func sendPayment(_ dataSource: ContactsDataSource, contact: LocalContact, receiver: StellarAddress)
}

final class ContactsDataSource: NSObject {
    enum SectionType: Int {
        case stellarContacts
        case addressBookContacts

        static var all: [SectionType] {
            return [.stellarContacts, .addressBookContacts]
        }
    }

    weak var delegate: ContactsDataSourceDelegate?
    weak var cellDelegate: ContactsViewController?
    var stellarContacts: [LocalContact] = []
    var addressBookContacts: [LocalContact] = []
    var filteredStellarContacts: [LocalContact] = []
    var filteredAddressBookContacts: [LocalContact] = []
    var account: StellarAccount

    var hasFilteredStellarContacts: Bool {
        return filteredStellarContacts.count > 0
    }

    var hasFilteredNormalContacts: Bool {
        return filteredAddressBookContacts.count > 0
    }

    let requiredContactKeys = [
        CNContactGivenNameKey,
        CNContactIdentifierKey,
        CNContactFamilyNameKey,
        CNContactEmailAddressesKey
    ]

    init(contactStore: CNContactStore, account: StellarAccount, cellDelegate: ContactsViewController) {
        self.cellDelegate = cellDelegate
        self.account = account

        let request = CNContactFetchRequest(keysToFetch: requiredContactKeys as [CNKeyDescriptor])
        var cnContacts: [CNContact] = []
        do {
            try contactStore.enumerateContacts(with: request, usingBlock: { (contact, _) in
                if !contact.givenName.isEmpty {
                    cnContacts.append(contact)
                }
            })

            var allStellarContacts: [LocalContact] = []
            var allAddressBookContacts: [LocalContact] = []
            let suffix = StellarAddress.Suffix.contactAddress.rawValue

            let nonDuplicateContacts = Array(Set(cnContacts))
            for contact in nonDuplicateContacts {
                let name = "\(contact.givenName) \(contact.familyName)"
                var stellarEmail = ""
                for emailAddress in contact.emailAddresses where emailAddress.value.contains(suffix) {
                    stellarEmail = emailAddress.value.replacingOccurrences(of: suffix, with: "") as String
                }

                let localContact = LocalContact(identifier: contact.identifier, name: name, address: stellarEmail)

                stellarEmail.isEmpty ?
                    allAddressBookContacts.append(localContact) : allStellarContacts.append(localContact)
            }

            self.addressBookContacts = allAddressBookContacts.sorted { $0.name < $1.name }
            self.stellarContacts = allStellarContacts.sorted { $0.name < $1.name }
            self.filteredStellarContacts = stellarContacts
            self.filteredAddressBookContacts = addressBookContacts
        } catch let error {
            print("Error enumerating contacts: ", error.localizedDescription)
        }
    }
}

extension ContactsDataSource: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return SectionType.all.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = SectionType(rawValue: section) else { return 0 }

        switch section {
        case .stellarContacts: return filteredStellarContacts.count
        default: return filteredAddressBookContacts.count
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ContactCell.rowHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = SectionType(rawValue: indexPath.section) else {
            return UITableViewCell(style: .default, reuseIdentifier: nil)
        }

        switch section {
        case .stellarContacts:
            let cell: StellarContactCell = tableView.dequeueReusableCell(for: indexPath)
            cell.indexPath = indexPath
            cell.delegate = cellDelegate
            cell.nameLabel.text = filteredStellarContacts[indexPath.row].name
            return cell
        default:
            let cell: ContactCell = tableView.dequeueReusableCell(for: indexPath)
            cell.indexPath = indexPath
            cell.delegate = cellDelegate
            cell.nameLabel.text = filteredAddressBookContacts[indexPath.row].name
            return cell
        }
    }

    func filterResults(with text: String?) {
        if let searchText = text, !searchText.isEmpty {
            filteredStellarContacts = stellarContacts.filter {
                $0.name.lowercased().contains(searchText.lowercased())
            }

            filteredAddressBookContacts = addressBookContacts.filter {
                $0.name.lowercased().contains(searchText.lowercased())
            }
        } else {
            filteredStellarContacts = stellarContacts
            filteredAddressBookContacts = addressBookContacts
        }
    }
}
