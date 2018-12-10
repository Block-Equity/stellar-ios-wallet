//
//  FetchExchangesOperation.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-10-23.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Alamofire
import StellarHub

final class FetchExchangesOperation: AsyncOperation {
    typealias SuccessCallback = ([Exchange]) -> Void
    typealias FailureCallback = (Error) -> Void

    let completion: SuccessCallback
    let failure: FailureCallback?

    var result: Result<[Exchange]> = Result.failure(AsyncOperationError.responseUnset)

    init(completion: @escaping SuccessCallback, failure: FailureCallback?) {
        self.completion = completion
        self.failure = failure
    }

    override func main() {
        super.main()

        let decoder = JSONDecoder()
        Alamofire.request(BlockEQURL.exchangeDirectory.string).responseJSON { response in
            guard response.result.isSuccess, let data = response.data else {
                if let error = response.error {
                    self.result = Result.failure(error)
                }

                self.finish()
                return
            }

            do {
                let exchangeList = try decoder.decode([Exchange].self, from: data)
                self.result = Result.success(exchangeList)
            } catch let error {
                self.result = Result.failure(error)
            }

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
