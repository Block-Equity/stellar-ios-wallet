//
//  StreamListener.swift
//  StellarHub
//
//  Created by Nick DiZazzo on 2018-12-17.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk

// MARK: - Generic Stream Listeners
protocol AnyStreamListener: AnyObject {
    var status: StreamService.StreamStatus { get }

    func toggle() throws
    func enable() throws
    func disable() throws
    func close()
}

protocol StreamListener: AnyStreamListener {
    associatedtype StreamType
    associatedtype ResponseType: Decodable

    var handler: StreamResponseEnum<ResponseType>.ResponseClosure { get }
}

/// Objects that conform as a stream delegate expect notifications for certain types of processed objects. Implementers
/// of the protocol will know what object type they expect.
protocol StreamDelegate: AnyObject {
    func updated<ProcessedDataType: StreamableStellarObject>(data: ProcessedDataType)
    func streamError<ProcessedDataType>(dataType: ProcessedDataType, error: Error)
}

/**
 A generic class used to wrap a standardardized way to processing events on a stream. Specific implementations of this
 class will provide a custom processor and delegate to receive notifications back on.

 The generic parameters for this class require the provided types to conform to protocols that explicitly allow them to
 be used with this class.
*/
class StreamDataListener<StreamType, ResponseType, ProcessedDataType>: StreamListener
where
  ProcessedDataType: StreamableStellarObject,
  StreamType: HorizonStream,
  StreamType.ResponseType == ResponseType {
    let stream: StreamType
    let processor: AnyStreamProcessor<ResponseType, ProcessedDataType>

    var status: StreamService.StreamStatus = .stopped
    weak var delegate: StreamDelegate?

    var isListening: Bool {
        return status == .listening
    }

    init(stream: StreamType, processor: AnyStreamProcessor<ResponseType, ProcessedDataType>) {
        self.stream = stream
        self.processor = processor

        stream.onReceive(response: self.handler)
    }

    /// Enables events to be processed. Calling `disable()` will pause event processing for the stream.
    func enable() throws {
        if status == .closed { throw FrameworkError.StreamServiceError.invalidStreamState }
        status = .listening
    }

    /// Disables events from being processed. Calling `enable()` will re-start event processing for the stream.
    func disable() throws {
        if status == .closed { throw FrameworkError.StreamServiceError.invalidStreamState }
        status = .stopped
    }

    /**
     Enables or disables processing of the current stream. This does not close the

     - Throws: An error if the stream is already closed, or the type is unsupported
     */
    func toggle() throws {
        try isListening ? disable() : enable()
    }

    /// Perminantly stops the stream. Once it is closed, it cannot be reopened. Restarting the stream requires
    /// recreating a new listener.
    func close() {
        stream.closeStream()
        status = .closed
    }

    /// Generic stream processor and notification callback
    var handler: (StreamResponseEnum<ResponseType>) -> Void {
        return { [weak self] response in
            guard let self = self, self.status == .listening else { return }

            switch response {
            case .open:
                break
            case .response(let eventId, let responseData):
                let processedData = self.processor.process(eventId: eventId, data: responseData)
                self.delegate?.updated(data: processedData)
            case .error(let error):
                guard let error = error as? HorizonRequestError else { return }
                let errorTag = String(describing: self)
                StellarSDKLog.printHorizonRequestErrorMessage(tag: errorTag, horizonRequestError: error)
                self.delegate?.streamError(dataType: ProcessedDataType.self, error: error)
            }
        }
    }
}

// MARK: - Specialized Object Stream Listeners
final class TransactionStreamListener: StreamDataListener
    <TransactionsStreamItem, TransactionResponse, StellarTransaction> {
    init(core: CoreServiceProtocol, account: StellarAccount, cursor: String? = nil) {
        let transactionsChange = TransactionsChange.transactionsForAccount(account: account.accountId, cursor: cursor)
        let stream = core.sdk.transactions.stream(for: transactionsChange)
        let processor = TransactionStreamProcessor()
        super.init(stream: stream, processor: AnyStreamProcessor(processor))
    }
}

final class OperationStreamListener: StreamDataListener<OperationsStreamItem, OperationResponse, StellarOperation> {
    init(core: CoreServiceProtocol, account: StellarAccount, cursor: String? = nil) {
        let paymentsChange = PaymentsChange.paymentsForAccount(account: account.accountId, cursor: cursor)
        let stream = core.sdk.payments.stream(for: paymentsChange)
        let processor = OperationStreamProcessor()
        super.init(stream: stream, processor: AnyStreamProcessor(processor))
    }
}

final class EffectStreamListener: StreamDataListener<EffectsStreamItem, EffectResponse, StellarEffect> {
    init(core: CoreServiceProtocol, account: StellarAccount, cursor: String? = nil) {
        let effectsChange = EffectsChange.effectsForAccount(account: account.accountId, cursor: cursor)
        let stream = core.sdk.effects.stream(for: effectsChange)
        let processor = EffectStreamProcessor()
        super.init(stream: stream, processor: AnyStreamProcessor(processor))
    }
}

// MARK: - Horizon Stream Extensions

/// Since all Horizon streams implemented thusfar have a closeStream method, but are not protocol-oriented, we can
/// augment them ourselves manually.
protocol HorizonStream {
    associatedtype ResponseType: ProcessableStellarResponse
    func onReceive(response: @escaping StreamResponseEnum<ResponseType>.ResponseClosure)
    func closeStream()
}

extension TransactionsStreamItem: HorizonStream { }
extension OperationsStreamItem: HorizonStream { }
extension EffectsStreamItem: HorizonStream { }
