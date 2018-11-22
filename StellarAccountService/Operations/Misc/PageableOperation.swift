//
//  PageableOperation.swift
//  StellarAccountService
//
//  Created by Nick DiZazzo on 2018-11-21.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk

protocol PageableOperation {
    associatedtype ResponseType: Decodable

    var next: Self? { get }

    func getCursor(for: PageResponse<ResponseType>) -> String?
    func setupNextRequest(response: PageResponse<ResponseType>)
}

extension PageableOperation {
    func getCursor(for response: PageResponse<ResponseType>) -> String? {
        guard response.hasNextPage(), response.records.count > 0,
            let url = response.links.next?.href,
            let nextPageQuery = URL(string: url)?.query else { return nil }

        let queryParts = nextPageQuery.split(separator: "&")

        guard let cursorQuery = queryParts.first(where: { $0.contains("cursor=") }),
            let cursorSubstring = cursorQuery.split(separator: "=").last else { return nil }

        return String(cursorSubstring)
    }
}
