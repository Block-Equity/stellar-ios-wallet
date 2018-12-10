//
//  StellarOperation+Extensions.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-11-09.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import StellarHub

extension StellarOperation {
    var title: String {
        switch operationType {
        case .accountCreated: return "OPERATION_CREATED_TITLE".localized()
        case .accountMerge: return "OPERATION_MERGED_TITLE".localized()
        case .allowTrust: return "OPERATION_ATRUST_TITLE".localized()
        case .bumpSequence: return "OPERATION_BUMP_TITLE".localized()
        case .changeTrust: return "OPERATION_CTRUST_TITLE".localized()
        case .createPassiveOffer: return "OPERATION_POFFER_TITLE".localized()
        case .inflation: return"OPERATION_INFLATION_TITLE".localized()
        case .manageData: return "OPERATION_MANAGEDATA_TITLE".localized()
        case .manageOffer: return "OPERATION_MOFFER_TITLE".localized()
        case .pathPayment: return "OPERATION_PATHPAYMENT_TITLE".localized()
        case .payment: return"OPERATION_PAYMENT_TITLE".localized()
        case .setOptions: return "OPERATION_OPTIONS_TITLE".localized()
        }
    }

    var descriptionString: String {
        switch operationType {
        case .accountCreated:
            guard let createData = self.createData else { return "" }
            return String(format: "OPERATION_CREATED_DESCRIPTION".localized(),
                          createData.account, createData.balance.displayFormattedString)
        case .accountMerge:
            guard let mergeData = self.mergeData else { return "" }
            return String(format: "OPERATION_MERGED_DESCRIPTION".localized(), mergeData.from, mergeData.into)
        case .allowTrust:
            guard let trustData = self.allowTrustData else { return "" }
            let allowDeny = trustData.allow ? "OPERATION_ALLOWTRUST".localized() : "OPERATION_DENYTRUST".localized()
            return String(format: "OPERATION_ATRUST_DESCRIPTION".localized(),
                          allowDeny,
                          trustData.trustor,
                          trustData.asset.shortCode,
                          trustData.trustee)
        case .changeTrust:
            guard let trustData = self.changeTrustData else { return "" }
            return String(format: "OPERATION_CTRUST_DESCRIPTION".localized(),
                          trustData.asset.shortCode,
                          trustData.trustee)
        case .manageOffer:
            guard let manageData = self.manageData else { return "" }
            return String(format: "OPERATION_MOFFER_DESCRIPTION".localized(),
                          manageData.pair.selling.shortCode,
                          manageData.pair.buying.shortCode,
                          manageData.price.displayFormatted,
                          "\(manageData.pair.buying.shortCode)/\(manageData.pair.selling.shortCode)")
        case .payment:
            guard let paymentData = self.paymentData else { return "" }
            return String(format: "OPERATION_PAYMENT_DESCRIPTION".localized(),
                          paymentData.asset.shortCode,
                          paymentData.destination)
        case .setOptions:
            if let inflationDest = self.optionsData?.inflationDest {
                return String(format: "OPERATION_OPTIONS_SET_INFLATION_DESCRIPTION".localized(), inflationDest)
            } else if let domain = self.optionsData?.homeDomain {
                return String(format: "OPERATION_OPTIONS_SET_HOMEDOMAIN_DESCRIPTION".localized(), domain)
            } else if let signer = self.optionsData?.signerKey, let weight = self.optionsData?.signerWeight {
                return String(format: "OPERATION_OPTIONS_SET_SIGNER_DESCRIPTION".localized(), signer, weight)
            } else {
                return "OPERATION_OPTIONS_DESCRIPTION".localized()
            }
        case .pathPayment:
            return "OPERATION_PATHPAYMENT_DESCRIPTION".localized()
        case .bumpSequence:
            return "OPERATION_BUMP_DESCRIPTION".localized()
        case .createPassiveOffer:
            return "OPERATION_POFFER_DESCRIPTION".localized()
        case .inflation:
            return "OPERATION_INFLATION_DESCRIPTION".localized()
        case .manageData:
            return "OPERATION_MANAGEDATA_DESCRIPTION".localized()
        }
    }
}
