//
//  SnapshotTest.swift
//  BlockEQTests
//
//  Created by Nick DiZazzo on 2018-12-27.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Foundation
import XCTest
import SnapshotTesting

protocol SnapshotTest: AnyObject {
    var recordMode: Bool { get }
}
