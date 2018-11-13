//
//  SendDiagnosticOperation.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-11-12.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Alamofire
import StellarAccountService

final class SendDiagnosticOperation: AsyncOperation {
    typealias SuccessCallback = (Int?) -> Void
    typealias FailureCallback = (Error) -> Void

    let completion: SuccessCallback
    let failure: FailureCallback?
    let diagnostic: Diagnostic

    var result: Result<Int?> = Result.failure(AsyncOperationError.responseUnset)

    init(diagnostic: Diagnostic, completion: @escaping SuccessCallback, failure: FailureCallback?) {
        self.diagnostic = diagnostic
        self.completion = completion
        self.failure = failure
    }

    override func main() {
        super.main()

        let decoder = JSONDecoder()
        let diagnostic = ["": self.diagnostic]
        let dataRequest: DataRequest = Alamofire.request(BlockEQURL.diagnosticReport.url,
                                                         method: .post,
                                                         parameters: diagnostic,
                                                         encoding: JsonEncodableParameters.default,
                                                         headers: nil)

        dataRequest.responseJSON { response in
            self.result = Result.failure(Diagnostic.DiagnosticError.encodingFailure)

            switch response.result {
            case .success:
                if let data = response.data, let report = try? decoder.decode(Diagnostic.self, from: data) {
                    self.result = Result.success(report.reportId)
                }
            case .failure: break
            }

            self.finish()
        }
    }

    func finish() {
        state = .finished

        DispatchQueue.main.async {
            switch self.result {
            case .success(let response):
                self.completion(response)
            case .failure(let error):
                self.failure?(error)
            }
        }
    }
}
