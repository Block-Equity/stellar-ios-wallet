//
//  StellarContactViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-08-15.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Contacts
import StellarHub

class StellarContactViewController: UIViewController {

    @IBOutlet var addressHolderView: UIView!
    @IBOutlet var nameHolderView: UIView!
    @IBOutlet var addressTitleLabel: UILabel!
    @IBOutlet var addressTextField: UITextField!
    @IBOutlet var nameTitleLabel: UILabel!
    @IBOutlet var fieldsStackView: UIStackView!
    @IBOutlet var nameFields: UIStackView!
    @IBOutlet var addressFields: UIStackView!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var containerView: UIView!

    var identifier: String = ""
    var name: String = ""
    var address: String = ""

    var displayName: Bool = false

    override var preferredStatusBarStyle: UIStatusBarStyle { return .default }

    init(identifier: String, name: String, address: String) {
        super.init(nibName: String(describing: StellarContactViewController.self), bundle: nil)
        self.identifier = identifier
        self.name = name
        self.address = address
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configure()
    }

    func setupView() {
        let rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "close"),
                                                 style: .plain,
                                                 target: self,
                                                 action: #selector(self.dismissView))

        navigationItem.rightBarButtonItem = rightBarButtonItem

        addressTitleLabel.textColor = Colors.darkGrayTransparent
        addressTextField.textColor = Colors.darkGray
        addressHolderView.backgroundColor = Colors.lightBackground
        nameTitleLabel.textColor = Colors.darkGrayTransparent
        nameTextField.textColor = Colors.darkGray
        nameHolderView.backgroundColor = Colors.lightBackground
        fieldsStackView.backgroundColor = .clear
        containerView.backgroundColor = Colors.white

        view.backgroundColor = Colors.lightBackground

        addressTitleLabel.text = "PUBLIC_ADDRESS".localized().uppercased()
        nameTitleLabel.text = "FULL_NAME".localized().uppercased()
    }

    func configure() {
        addressTextField.text = address
        nameTextField.text = ""

        if name.isEmpty {
            title = "ADD_CONTACT".localized()
        } else {
            nameFields.isHidden = true
            title = name
        }
    }

    func createContact(name: String, address: String) {
        let contactsStore = CNContactStore()
        contactsStore.requestAccess(for: .contacts) { (granted, error) in
            if let fetchError = error {
                print("Unable to get contacts", fetchError)
                return
            }

            if granted {
                let federatedAddress = CNLabeledValue(label: "Stellar",
                                                      value: "\(address).publicaddress@blockeq.com" as NSString)
                let mutableContact = CNMutableContact()
                mutableContact.givenName = name
                mutableContact.emailAddresses.append(federatedAddress)

                self.createContact(contact: mutableContact)
            }
        }
    }

    func updateContact(name: String, address: String, remove: Bool = false) {
        let contactsStore = CNContactStore()

        contactsStore.requestAccess(for: .contacts) { (granted, error) in
            if let fetchError = error {
                print("ERROR: Unable to get contacts", fetchError)
                return
            }

            if granted {
                let pred = CNContact.predicateForContacts(withIdentifiers: [self.identifier])
                let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactEmailAddressesKey]

                var contacts = [CNContact]()

                do {
                    contacts = try contactsStore.unifiedContacts(matching: pred, keysToFetch: keys as [CNKeyDescriptor])

                    if contacts.count == 0 {
                        print("ERROR: No contacts were found matching the given name.")
                    } else {
                        print(contacts[0].givenName)
                    }

                    let stellarEmail = CNLabeledValue(label: "STELLAR".localized(),
                                                      value: "\(address).publicaddress@blockeq.com" as NSString)

                    guard let mutableContact = contacts[0].mutableCopy() as? CNMutableContact else {
                        print("ERROR: Couldn't convert contact")
                        return
                    }

                    var previousEmailFound: Bool = false
                    var previousEmailIndex: Int = 0
                    for (index, emailAddress) in mutableContact.emailAddresses.enumerated() {
                        if emailAddress.value.contains(".publicaddress@blockeq.com") {
                            previousEmailFound = true
                            previousEmailIndex = index
                            break
                        }
                    }

                    if previousEmailFound && remove {
                        mutableContact.emailAddresses.remove(at: previousEmailIndex)
                    } else if previousEmailFound && !remove {
                        mutableContact.emailAddresses[previousEmailIndex] = stellarEmail
                        mutableContact.emailAddresses.append(stellarEmail)
                    } else {
                        mutableContact.emailAddresses.append(stellarEmail)
                    }

                    self.saveContact(contact: mutableContact)
                } catch {
                    print("Unable to fetch contacts.")
                }
            }
        }
    }

    func saveContact(contact: CNMutableContact) {
        let req = CNSaveRequest()
        req.update(contact)
        let store = CNContactStore()
        do {
            try store.execute(req)
            DispatchQueue.main.async {
                self.dismissView()
            }
        } catch {
            let err = error as NSError
            print(err)
        }
    }

    func createContact(contact: CNMutableContact) {
        let req = CNSaveRequest()
        req.add(contact, toContainerWithIdentifier: nil)
        let store = CNContactStore()
        do {
            try store.execute(req)
            DispatchQueue.main.async {
                self.dismissView()
            }
        } catch {
            let err = error as NSError
            print(err)
        }
    }
}

// MARK: - IBActions
extension StellarContactViewController {
    @IBAction func addAddress() {

        let stellarAddress = StellarAddress(addressTextField.text)

        if identifier.isEmpty {
            guard let contactName = nameTextField.text else {
                addressTextField.shake()
                return
            }

            guard let address = stellarAddress else {
                addressTextField.shake()
                return
            }

            createContact(name: contactName, address: address.string)
        } else {
            let address = stellarAddress?.string ?? self.address
            updateContact(name: name, address: address, remove: stellarAddress == nil)
        }
    }

    @IBAction func scanQRCode() {
        let scanViewController = ScanViewController()
        scanViewController.delegate = self

        let navigationController = AppNavigationController(rootViewController: scanViewController)
        present(navigationController, animated: true, completion: nil)
    }

    @IBAction func dismissView() {
        view.endEditing(true)

        dismiss(animated: true, completion: nil)
    }
}

extension StellarContactViewController: ScanViewControllerDelegate {
    func setQR(_ viewController: ScanViewController, value: String) {
        addressTextField.text = value
    }
}
