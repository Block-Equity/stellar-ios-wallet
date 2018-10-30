//
//  AccountUpdatable.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-10-30.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import StellarAccountService

protocol AccountUpdatable: AnyObject {
    func update(account: StellarAccount)
}
