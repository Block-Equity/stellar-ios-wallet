//
//  CacheManager.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2019-01-15.
//  Copyright © 2019 BlockEQ. All rights reserved.
//

import Cache
import Imaginary

final class CacheManager {
    static let shared = CacheManager()

    let images = Configuration.imageStorage

    private init() {}
}
