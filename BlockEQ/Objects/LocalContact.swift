//
//  Contact.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-08-15.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import UIKit

class LocalContact: NSObject {
    var identifier = ""
    var name = ""
    var address = ""
    
    init(identifier: String, name: String, address: String) {
        self.identifier = identifier
        self.name = name
        self.address = address
    }
}


