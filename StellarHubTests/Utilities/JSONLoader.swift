//
//  JSONLoader.swift
//  StellarHubTests
//
//  Created by Nick DiZazzo on 2018-11-01.
//  Copyright © 2018 BlockEQ. All rights reserved.
//
import Foundation

final class JSONLoader {
    static func load(jsonFixture: String) -> Data? {
        let bundle = Bundle.init(for: JSONLoader.self)
        guard let path = bundle.path(forResource: jsonFixture, ofType: "json") else { return nil }
        let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
        return data
    }

    static func decodableJSON<T: Decodable>(name: String) -> T {
        let jsonData = self.load(jsonFixture: name)!
        return try! JSONDecoder().decode(T.self, from: jsonData)
    }
}
