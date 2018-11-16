//
//  StellarOperation+Extensions.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-11-09.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import StellarAccountService

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
        case .accountCreated: return "OPERATION_CREATED_DESCRIPTION".localized()
        case .accountMerge: return "OPERATION_MERGED_DESCRIPTION".localized()
        case .allowTrust: return "OPERATION_ATRUST_DESCRIPTION".localized()
        case .bumpSequence: return "OPERATION_BUMP_DESCRIPTION".localized()
        case .changeTrust: return "OPERATION_CTRUST_DESCRIPTION".localized()
        case .createPassiveOffer: return "OPERATION_POFFER_DESCRIPTION".localized()
        case .inflation: return"OPERATION_INFLATION_DESCRIPTION".localized()
        case .manageData: return "OPERATION_MANAGEDATA_DESCRIPTION".localized()
        case .manageOffer: return "OPERATION_MOFFER_DESCRIPTION".localized()
        case .pathPayment: return "OPERATION_PATHPAYMENT_DESCRIPTION".localized()
        case .payment: return"OPERATION_PAYMENT_DESCRIPTION".localized()
        case .setOptions:
            switch "0" { // fix when support for different operation types are available
            case "0": return "OPERATION_OPTIONS_SET_INFLATION_DESCRIPTION".localized()
            case "1": return "OPERATION_OPTIONS_SET_HOMEDOMAIN_DESCRIPTION".localized()
            case "2": return "OPERATION_OPTIONS_SET_SIGNER_DESCRIPTION".localized()
            default: return "OPERATION_OPTIONS_DESCRIPTION".localized()
            }
        }
    }
}
