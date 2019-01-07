//
//  AssetMetadataManager.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2019-01-07.
//  Copyright © 2019 BlockEQ. All rights reserved.
//

final class AssetMetadataManager {
    static let shared = AssetMetadataManager()

    var assets = [String: AssetMetadata]()

    private init() {
        let decoder = JSONDecoder()

        guard let path = Bundle.main.path(forResource: "asset_metadata", ofType: "json") else { return }

        if let assetMetadata = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe),
            let decodedMetadata = try? decoder.decode([AssetMetadata].self, from: assetMetadata) {
            assets = decodedMetadata.reduce(into: [:], { list, metadata in
                let code = metadata.shortCode.uppercased()
                list[code] = metadata
            })
        }
    }
}
