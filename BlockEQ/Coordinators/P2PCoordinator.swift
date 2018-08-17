//
//  P2PCoordinator.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-08-01.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import UIKit

final class P2PCoordinator {
    let p2pViewController = P2PViewController()
    
    var addPeerViewController: AddPeerViewController?
    var createTokenViewController: CreateTokenViewController?
    var receiveViewController: ReceiveViewController?
    var trustedPartiesViewController: TrustedPartiesViewController?
    var p2pTransactionViewController: P2PTransactionViewController?
    var scanViewController: ScanViewController?
    var wrappingNavController: AppNavigationController?
    
    init() {
        p2pViewController.delegate = self
    }
}

extension P2PCoordinator: AddPeerViewControllerDelegate {
    func selectedScanAddress() {
        let scanVC = ScanViewController()
        scanVC.delegate = self
        let container = AppNavigationController(rootViewController: scanVC)
        
        scanViewController = scanVC
        wrappingNavController = container
        wrappingNavController?.navigationBar.prefersLargeTitles = false
        
        addPeerViewController?.present(container, animated: true, completion: nil)
    }
}

extension P2PCoordinator: P2PViewControllerDelegate {
    func selectedAddPeer() {
        let addPeerVC = AddPeerViewController()
        addPeerVC.delegate = self
        let container = AppNavigationController(rootViewController: addPeerVC)
        
        addPeerViewController = addPeerVC
        wrappingNavController = container
        wrappingNavController?.navigationBar.prefersLargeTitles = true
        
        p2pViewController.present(container, animated: true, completion: nil)
    }
    
    func selectedAddTransaction() {
        let p2pTransactionVC = P2PTransactionViewController()
        let container = AppNavigationController(rootViewController: p2pTransactionVC)
        
        p2pTransactionViewController = p2pTransactionVC
        wrappingNavController = container
        wrappingNavController?.navigationBar.prefersLargeTitles = true
        
        p2pViewController.present(container, animated: true, completion: nil)
    }
    
    func selectedCreateToken() {
        let createTokenVC = CreateTokenViewController()
        let container = AppNavigationController(rootViewController: createTokenVC)
        
        createTokenViewController = createTokenVC
        wrappingNavController = container
        wrappingNavController?.navigationBar.prefersLargeTitles = true
        
        p2pViewController.present(container, animated: true, completion: nil)
    }
    
    func selectedDisplayAddress(accountId: String) {
        let receiveVC = ReceiveViewController(address: accountId, isPersonalToken: true)
        let container = AppNavigationController(rootViewController: receiveVC)
        
        receiveViewController = receiveVC
        wrappingNavController = container
        wrappingNavController?.navigationBar.prefersLargeTitles = true
        
        p2pViewController.present(container, animated: true, completion: nil)
    }
    
    func selectedTrustedParties() {
        let trustedPartiesVC = TrustedPartiesViewController()
        let container = AppNavigationController(rootViewController: trustedPartiesVC)
        
        trustedPartiesViewController = trustedPartiesVC
        wrappingNavController = container
        wrappingNavController?.navigationBar.prefersLargeTitles = true
        
        p2pViewController.present(container, animated: true, completion: nil)
    }
}

extension P2PCoordinator: ScanViewControllerDelegate {
    func setQR(value: String) {
        addPeerViewController?.setIssuerAddress(address: value)
    }
}
