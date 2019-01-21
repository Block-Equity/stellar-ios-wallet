//
//  MulticastDelegate.swift
//  StellarHub
//
//  Created by Nick DiZazzo on 2018-11-08.
//  Copyright © 2018 BlockEQ. All rights reserved.
//
// Original obtained from: https://stackoverflow.com/a/44697868
// Modified to avoid force casts + use Swift 4.2 features

import Foundation

internal final class MulticastDelegate <T> {
    private let delegates: NSHashTable<AnyObject> = NSHashTable.weakObjects()

    func add(delegate: T) {
        delegates.add(delegate as AnyObject)
    }

    func remove(delegate: T) {
        for oneDelegate in delegates.allObjects.reversed() where oneDelegate === delegate as AnyObject {
            delegates.remove(oneDelegate)
        }
    }

    func clear() {
        delegates.removeAllObjects()
    }

    func invoke(invocation: (T) -> Void) {
        for delegate in delegates.allObjects.reversed() {
            guard let delegate = delegate as? T else { continue }
            invocation(delegate)
        }
    }

    var subscriberCount: Int {
        return delegates.count
    }
}

func += <T: AnyObject> (left: MulticastDelegate<T>, right: T) {
    left.add(delegate: right)
}

func -= <T: AnyObject> (left: MulticastDelegate<T>, right: T) {
    left.remove(delegate: right)
}
