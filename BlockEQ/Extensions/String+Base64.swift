//
//  String+Base64.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-08-10.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

extension String {
    func base64Encoded() -> String? {
        return data(using: .utf8)?.base64EncodedString()
    }

    func base64Decoded() -> String? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
