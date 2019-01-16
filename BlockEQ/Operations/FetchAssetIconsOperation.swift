//
//  FetchAssetIconsOperation.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2019-01-15.
//  Copyright © 2019 BlockEQ. All rights reserved.
//

import Foundation
import StellarHub
import Imaginary

final class FetchAssetIconsOperation: AsyncOperation {
    typealias SuccessCallback = () -> Void

    let urls: [URL]
    let completion: SuccessCallback?
    let imageFetcher: MultipleImageFetcher

    init(assetCodes: [String], completion: SuccessCallback? = nil) {
        self.urls = assetCodes.map { BlockEQURL.assetIcon($0.lowercased()).url }
        self.completion = completion
        self.imageFetcher = MultipleImageFetcher(fetcherMaker: {
            let downloader = ImageDownloader(modifyRequest: { return $0 })
            return ImageFetcher(downloader: downloader, storage: CacheManager.shared.images)
        })
    }

    override func main() {
        super.main()

        imageFetcher.fetch(urls: urls, each: { _ in }, completion: { fetchResult in
            self.finish(result: fetchResult)
        })
    }

    override func cancel() {
        imageFetcher.cancel()
        super.cancel()
    }

    func finish(result: [Imaginary.Result]) {
        state = .finished
        completion?()
    }
}
