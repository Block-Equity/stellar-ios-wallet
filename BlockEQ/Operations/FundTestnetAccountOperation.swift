//
//  FundTestnetAccountOperation.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2019-01-29.
//  Copyright © 2019 BlockEQ. All rights reserved.
//

import StellarHub
import Alamofire

final class FundTestnetAccountOperation: AsyncOperation {
    static let FriendBotAddress = "https://friendbot.stellar.org"

    typealias FriendbotCompletion = (Bool) -> Void

    let completion: FriendbotCompletion?
    let address: String

    init(address: String, completion: FriendbotCompletion? = nil) {
        self.address = address
        self.completion = completion
    }

    override func main() {
        super.main()

        let friendbotURL = String(format: "%@/?addr=%@", FundTestnetAccountOperation.FriendBotAddress, address)

        Alamofire.request(friendbotURL).responseJSON { response in
            switch response.result {
            case .success:
                self.finish(success: true)
            case .failure:
                self.finish(success: false)
            }
        }
    }

    func finish(success: Bool) {
        state = .finished
        completion?(success)
    }
}
