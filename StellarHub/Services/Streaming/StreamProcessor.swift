//
//  StreamProcessor.swift
//  StellarHub
//
//  Created by Nick DiZazzo on 2018-12-17.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk

/// This protocol indicates to the compiler which Stellar objects we consider streamable
protocol StreamableStellarObject { }
extension StellarTransaction: StreamableStellarObject { }
extension StellarOperation: StreamableStellarObject { }
extension StellarEffect: StreamableStellarObject { }

/// This protocol indicates to the compiler which Horizon responses we consider processable
protocol ProcessableStellarResponse: Decodable { }
extension TransactionResponse: ProcessableStellarResponse { }
extension OperationResponse: ProcessableStellarResponse { }
extension EffectResponse: ProcessableStellarResponse { }

protocol StreamProcessorProtocol {
    associatedtype ResponseType: ProcessableStellarResponse
    associatedtype ProcessedDataType: StreamableStellarObject

    func process(eventId: String, data: ResponseType) -> ProcessedDataType
}

final class AnyStreamProcessor<ResponseType: ProcessableStellarResponse, ProcessedDataType: StreamableStellarObject>
: StreamProcessorProtocol {
    private let _process: (_ eventId: String, _ data: ResponseType) -> ProcessedDataType

    init<Processor: StreamProcessorProtocol>(_ streamProcessor: Processor)
        where Processor.ProcessedDataType == ProcessedDataType, Processor.ResponseType == ResponseType {
        _process = streamProcessor.process
    }

    func process(eventId: String, data: ResponseType) -> ProcessedDataType {
        return _process(eventId, data)
    }
}

final class TransactionStreamProcessor: StreamProcessorProtocol {
    typealias ResponseType = TransactionResponse
    typealias ProcessedDataType = StellarTransaction

    func process(eventId: String, data: TransactionResponse) -> StellarTransaction {
        return StellarTransaction(data)
    }
}

final class OperationStreamProcessor: StreamProcessorProtocol {
    typealias ResponseType = OperationResponse
    typealias ProcessedDataType = StellarOperation

    func process(eventId: String, data: OperationResponse) -> StellarOperation {
        return StellarOperation(data)
    }
}

final class EffectStreamProcessor: StreamProcessorProtocol {
    typealias ResponseType = EffectResponse
    typealias ProcessedDataType = StellarEffect

    func process(eventId: String, data: EffectResponse) -> StellarEffect {
        return StellarEffect(data)
    }
}
