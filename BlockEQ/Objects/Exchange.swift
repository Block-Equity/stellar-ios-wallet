//
//  Exchange.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-10-01.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Foundation

struct Exchange: Codable {
    var name: String
    var address: String
    var memo: String
    var websiteURL: String
    var logoURL: String

    enum CodingKeys: String, CodingKey {
        case name
        case address
        case memo
        case websiteURL = "website"
        case logoURL = "logo"
    }

    var website: URL? {
        return URL(string: self.websiteURL)
    }
}
