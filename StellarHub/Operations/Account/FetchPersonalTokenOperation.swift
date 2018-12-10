//
//  FetchPersonalTokenOperation.swift
//  StellarHub
//
//  Created by Nick DiZazzo on 2018-10-19.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Alamofire
import stellarsdk

private struct TokenData: Decodable {
    let value: String
}

final class FetchPersonalTokenOperation: AsyncOperation {
    typealias SuccessCompletion = (String) -> Void

    let api: StellarConfig.HorizonAPI
    let address: StellarAddress
    let completion: SuccessCompletion
    let failure: ErrorCompletion?
    var result: Result<String> = Result.failure(AsyncOperationError.responseUnset)

    init(api: StellarConfig.HorizonAPI,
         address: StellarAddress,
         completion: @escaping SuccessCompletion,
         failure: ErrorCompletion?) {
        self.api = api
        self.address = address
        self.completion = completion
        self.failure = failure
    }

    override func main() {
        super.main()

        let decoder = JSONDecoder()

        Alamofire.request(StellarConfig.HorizonURL.publicAddress(api, address).string).responseJSON { response in
            if let error = response.error, !response.result.isSuccess {
                self.result = Result.failure(error)
                self.finish()
                return
            }

            guard let data = response.data, let token = try? decoder.decode(TokenData.self, from: data) else {
                self.finish()
                return
            }

            guard let decodedValue = token.value.base64Decoded() else {
                self.finish()
                return
            }

            self.result = Result.success(decodedValue)
            self.finish()
        }
    }

    func finish() {
        state = .finished

        switch result {
        case .success(let response):
            completion(response)
        case .failure(let error):
            failure?(error)
        }
    }
}
