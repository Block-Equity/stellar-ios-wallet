//
//  NibLoader.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-03-09.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Foundation

struct NibLoader<T> {
    let nibName: String

    func loadView() -> T {
        return loadView(owner: nil)
    }

    func loadView(owner: AnyObject?) -> T {
        let bundle = Bundle.main
        let views = bundle.loadNibNamed(nibName, owner: owner, options: nil)

        guard let view = views?.first! as? T else {
            fatalError("Incorrect view type provided")
        }

        return view
    }
}
