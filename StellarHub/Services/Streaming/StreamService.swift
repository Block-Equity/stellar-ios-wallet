//
//  StreamService.swift
//  StellarHub
//
//  Created by Nick DiZazzo on 2018-12-17.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk
import Repeat

extension StreamService {
    public enum StreamType {
        case effects
        case ledgers
        case offers
        case operations
        case orderbook
        case payments
        case transactions
        case trades

        static let supportedStreams: [StreamType] = [.effects, .operations, .transactions]
    }

    /// Errors relating to problems that can occur when performing operations on a stream.
    ///
    /// - listening: The stream is actively listening, processing, and notifying listeners of events.
    /// - stopped: The stream is still open, but not processing and notifying listeners of events.
    /// - closed: The stream is closed.
    public enum StreamStatus {
        case listening
        case stopped
        case closed
    }
}

/// This class manages listeners and data processing for event streams on Horizon.
public final class StreamService: StreamServiceProtocol {
    let core: CoreServiceProtocol

    internal var account: StellarAccount?
    internal var effectsStream: AnyStreamListener?
    internal var operationsStream: AnyStreamListener?
    internal var transactionsStream: AnyStreamListener?

    public weak var delegate: StreamServiceDelegate?

    /**
     Initializer for StreamService

     - Parameter core: An instance of the Core SDK to use for this service when making requests.
     */
    init(with core: CoreServiceProtocol) {
        self.core = core
    }

    /**
     Creates a new stream listener for the provided Horizon stream type.

     - Parameter stream: The stream to begin listening to.
     - Throws: An `unsupportedStreamType` error when the current stream is unimplemented.
     */
    public func subscribe(to stream: StreamType, account: StellarAccount) throws {

        var streamObject: AnyStreamListener

        switch stream {
        case .effects:
            guard effectsStream == nil else { return }
            let eStream = EffectStreamListener(core: core, account: account)
            eStream.delegate = self
            streamObject = eStream
            self.effectsStream = streamObject
        case .operations:
            guard operationsStream == nil else { return }
            let oStream = OperationStreamListener(core: core, account: account)
            oStream.delegate = self
            streamObject = oStream
            operationsStream = streamObject
        case .transactions:
            guard transactionsStream == nil else { return }
            let tStream = TransactionStreamListener(core: core, account: account)
            tStream.delegate = self
            streamObject = tStream
            transactionsStream = streamObject
        default:
            throw FrameworkError.StreamServiceError.unsupportedStreamType
        }

        try streamObject.enable()
    }

    /**
     Removes the stream listener for the provided stream type.

     - Parameter stream: The stream to begin listening to.
     - Throws: An `unsupportedStreamType` error when the current stream is unimplemented.
     */
    public func unsubscribe(from stream: StreamType) throws {
        switch stream {
        case .effects:
            effectsStream?.close()
            effectsStream = nil
        case .operations:
            operationsStream?.close()
            operationsStream = nil
        case .transactions:
            transactionsStream?.close()
            transactionsStream = nil
        default:
            throw FrameworkError.StreamServiceError.unsupportedStreamType
        }
    }

    /**
     Switches the stream data processing on and off for the provided stream.

     - Parameter stream: The stream to toggle state for.
     - Throws: An `unsupportedStreamType` error when the current stream is unimplemented.
     */
    public func toggle(stream: StreamType) throws {
        switch stream {
        case .effects:
            try effectsStream?.toggle()
        case .operations:
            try operationsStream?.toggle()
        case .transactions:
            try transactionsStream?.toggle()
        default:
            throw FrameworkError.StreamServiceError.unsupportedStreamType
        }
    }

    /// Creates listeners for all supported streams.
    public func subscribeAll(account: StellarAccount) {
        StreamType.supportedStreams.forEach {
            try? subscribe(to: $0, account: account)
        }
    }

    /// Removes listeners for all supported streams.
    public func unsubscribeAll() {
        StreamType.supportedStreams.forEach {
            try? unsubscribe(from: $0)
        }
    }

    deinit {
        unsubscribeAll()
    }
}

extension StreamService: AccountManagementServiceDelegate {
    public func accountSwitched(_ service: AccountManagementService, account: StellarAccount) {
        self.unsubscribeAll()
        self.subscribeAll(account: account)
    }
}

extension StreamService: StreamDelegate {
    func streamError<ProcessedDataType>(dataType: ProcessedDataType, error: Error) {
        let frameworkError = FrameworkError(error: error)
        switch dataType {
        case is StellarOperation.Type:
            self.delegate?.streamError(service: self, stream: .operations, error: frameworkError)
        case is StellarTransaction.Type:
            self.delegate?.streamError(service: self, stream: .transactions, error: frameworkError)
        case is StellarEffect.Type:
            self.delegate?.streamError(service: self, stream: .effects, error: frameworkError)
        default:
            break
        }
    }

    func updated<ProcessedDataType>(data: ProcessedDataType) where ProcessedDataType: StreamableStellarObject {
        switch data {
        case is StellarOperation:
            self.delegate?.receivedObjects(stream: .operations)
        case is StellarEffect:
            self.delegate?.receivedObjects(stream: .effects)
        case is StellarTransaction:
            self.delegate?.receivedObjects(stream: .transactions)
        default:
            break
        }
    }
}

// MARK: - Subservice
extension StreamService {
    func reset() {
        unsubscribeAll()
        account = nil
    }
}
