//
//  MergeAccountOperation.swift
//  StellarHub
//
//  Created by Nick DiZazzo on 2019-02-04.
//  Copyright © 2019 BlockEQ. All rights reserved.
//

import stellarsdk

extension AccountMergeOperation {
    enum AccountMergeError: String, LocalizedError {
        case mergeMalformed = "op_malformed"
        case noAccount = "op_no_account"
        case immutableSet = "op_immutable_set"
        case hasSubentries = "op_has_sub_entries"
        case sequenceNumTooFar = "op_seqnum_too_far"
        case destinationFull = "op_dest_full"
    }
}

extension AccountMergeOperation.AccountMergeError: ErrorCategorizable, ErrorDisplayable {
    var category: ErrorCategory {
        return ErrorCategory.stellar
    }

    var errorKey: String {
        switch self {
        case .mergeMalformed: return "ACCOUNT_MERGE_MALFORMED"
        case .noAccount: return "ACCOUNT_MERGE_NO_DESTINATION"
        case .immutableSet: return "ACCOUNT_MERGE_IMMUTABLE"
        case .hasSubentries: return "ACCOUNT_MERGE_SUBENTRIES"
        case .sequenceNumTooFar: return "ACCOUNT_MERGE_SEQNUM"
        case .destinationFull: return "ACCOUNT_MERGE_DEST_FULL"
        }
    }
}

extension BadRequestErrorResponse {
    func frameworkErrors() -> [FrameworkError] {
        let ops = self.extras.resultCodes.operations
        return ops.compactMap {
            if let error = AccountMergeOperation.AccountMergeError(rawValue: $0) {
                return FrameworkError(error: error)
            }

            return nil
        }
    }
}

final class AccountMergeOperation: AsyncOperation {
    typealias AccountMergeCompletion = (([FrameworkError]?) -> Void)
    let horizon: StellarSDK
    let api: StellarConfig.HorizonAPI
    let destinationId: String
    let sourceAccount: AccountResponse
    let userKeys: KeyPair

    var completion: AccountMergeCompletion?
    var result: Result<SubmitTransactionResponse> = Result.failure(AsyncOperationError.responseUnset)

    var outData: Bool?
    var inData: AccountResponse?

    init(horizon: StellarSDK,
         api: StellarConfig.HorizonAPI,
         destination: String,
         sourceAccount: AccountResponse,
         userKeys: KeyPair,
         completion: AccountMergeCompletion? = nil) {
        self.horizon = horizon
        self.api = api
        self.destinationId = destination
        self.completion = completion
        self.userKeys = userKeys
        self.sourceAccount = sourceAccount
    }

    override func main() {
        super.main()

        guard let destinationKeypair = try? KeyPair(accountId: destinationId) else {
            result = Result.failure(AccountMergeError.mergeMalformed)
            finish()
            return
        }

        let closeAccountOperation = stellarsdk.AccountMergeOperation(
            destinatioAccountPublicKey: destinationKeypair.publicKey,
            sourceAccount: userKeys
        )

        do {
            let transaction = try Transaction(sourceAccount: sourceAccount,
                                              operations: [closeAccountOperation],
                                              memo: Memo.none,
                                              timeBounds: nil)

            try transaction.sign(keyPair: userKeys, network: api.network)

            try horizon.transactions.submitTransaction(transaction: transaction) { response -> Void in
                switch response {
                case .success(let value):
                    self.result = Result.success(value)
                case .failure(let error):
                    self.result = Result.failure(error)
                }

                self.finish()
            }
        } catch let error {
            result = Result.failure(error)
            finish()
        }
    }

    func finish() {
        switch result {
        case .failure(let error):
            var errors = [FrameworkError(error: error)]

            if let horizonError = error as? HorizonRequestError {
                switch horizonError {
                case .badRequest(_, let errorResponse): errors = errorResponse?.frameworkErrors() ?? []
                default: break
                }
            }

            completion?(errors)
        case .success:
            completion?(nil)
        }

        state = .finished
    }
}
