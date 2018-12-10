//
//  AsynchronousOperation.swift
//  StellarHub
//
//  Created by Nick DiZazzo on 2018-10-23.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Foundation

/**
 * Subclass of `Operation` that adds easy support for asynchronous operations.
 *
 * Usage:
 * 1. Overriding any method like main or start should always call the respective 'super' method.
 * 2. Set self.state = .finished when operation's work is completed.
 *
 * Original: https://gist.github.com/Sorix/57bc3295dc001434fe08acbb053ed2bc
 */
open class AsyncOperation: Operation {
    open override var isAsynchronous: Bool { return true }
    open override var isExecuting: Bool { return state == .executing }
    open override var isFinished: Bool { return state == .finished }

    open var state = State.ready {
        willSet {
            willChangeValue(forKey: state.keyPath)
            willChangeValue(forKey: newValue.keyPath)
        }
        didSet {
            didChangeValue(forKey: state.keyPath)
            didChangeValue(forKey: oldValue.keyPath)
        }
    }

    public enum State: String {
        case ready = "Ready"
        case executing = "Executing"
        case finished = "Finished"
        fileprivate var keyPath: String { return "is" + self.rawValue }
    }

    open override func start() {
        if self.isCancelled {
            state = .finished
        } else {
            state = .ready
            main()
        }
    }

    open override func main() {
        if self.isCancelled {
            state = .finished
        } else {
            state = .executing
        }
    }
}
