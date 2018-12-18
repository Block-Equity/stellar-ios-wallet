//
//  Errors.swift
//  StellarHub
//
//  Created by Nick DiZazzo on 2018-12-03.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk

// MARK: - ErrorCategorizable
public protocol ErrorCategorizable: Error {
    var category: ErrorCategory { get }
}

public enum ErrorCategory {
    /// System-level errors like no network available
    case network

    /// Protocol-level errors that the Stellar network emits, like an invalid signature
    case stellar

    /// Internal state / logic errors for this framework
    case `internal`

    /// Unhandled errors, anything not captured above
    case unknown

    /// A localizable error key for use in client applications
    public var categoryKey: String {
        switch self {
        case .internal: return "CATEGORY_ERROR_INTERNAL"
        case .network: return "CATEGORY_ERROR_NETWORK"
        case .stellar: return "CATEGORY_ERROR_STELLAR"
        case .unknown: return "CATEGORY_ERROR_UNKNOWN"
        }
    }
}

extension HorizonRequestError: ErrorCategorizable {
    public var category: ErrorCategory {
        switch self {
        case HorizonRequestError.requestFailed(_): return .network
        case HorizonRequestError.badRequest(_, _): return .stellar
        case HorizonRequestError.emptyResponse: return .stellar
        case HorizonRequestError.parsingResponseFailed(_): return .stellar
        case HorizonRequestError.unauthorized(_): return .stellar
        case HorizonRequestError.forbidden(_, _): return .stellar
        case HorizonRequestError.notFound(_, _): return .stellar
        case HorizonRequestError.notAcceptable(_, _): return .stellar
        case HorizonRequestError.beforeHistory(_, _): return .stellar
        case HorizonRequestError.rateLimitExceeded(_, _): return .stellar
        case HorizonRequestError.internalServerError(_, _): return .stellar
        case HorizonRequestError.notImplemented(_, _): return .stellar
        case HorizonRequestError.staleHistory(_, _): return .stellar
        case HorizonRequestError.errorOnStreamReceive(_): return .stellar
        }
    }
}

extension HorizonRequestError: ErrorDisplayable {
    public var errorKey: String {
        switch self {
        case HorizonRequestError.requestFailed(_): return "REQUEST_FAILED_ERROR"
        case HorizonRequestError.badRequest(_, _): return "BAD_REQUEST_ERROR"
        case HorizonRequestError.emptyResponse: return "INVALID_RESPONSE_ERROR"
        case HorizonRequestError.parsingResponseFailed(_): return "INVALID_RESPONSE_ERROR"
        case HorizonRequestError.unauthorized(_): return "UNAUTHORIZED_ERROR"
        case HorizonRequestError.forbidden(_, _): return "FORBIDDEN_ERROR"
        case HorizonRequestError.notFound(_, _): return "NOT_FOUND_ERROR"
        case HorizonRequestError.notAcceptable(_, _): return "NOT_ACCEPTABLE_ERROR"
        case HorizonRequestError.beforeHistory(_, _): return "BEFORE_HISTORY_ERROR"
        case HorizonRequestError.rateLimitExceeded(_, _): return "RATE_LIMIT_ERROR"
        case HorizonRequestError.internalServerError(_, _): return "INTERNAL_SERVER_ERROR"
        case HorizonRequestError.notImplemented(_, _): return "NOT_IMPLMENTED_ERROR"
        case HorizonRequestError.staleHistory(_, _): return "STALE_HISTORY_ERROR"
        case HorizonRequestError.errorOnStreamReceive(_): return "STREAM_ERROR"
        }
    }
}

// MARK: - ErrorDisplable
public protocol ErrorDisplayable: Error {
    typealias ErrorDisplayData = (titleKey: String, messageKey: String)
    var errorKey: String { get }
    var displayData: ErrorDisplayData { get }
}

extension ErrorDisplayable {
    public var displayData: ErrorDisplayData {
        return (String(format: "%@_TITLE", errorKey), String(format: "%@_MESSAGE", errorKey))
    }
}

// MARK: - FrameworkError
public struct FrameworkError: Error {
    internal let internalError: Error
    public private(set) var errorCategory: ErrorCategory
    public private(set) var errorKey: String
}

extension FrameworkError: Equatable {
    public static func == (lhs: FrameworkError, rhs: FrameworkError) -> Bool {
        return lhs.internalError.localizedDescription == rhs.internalError.localizedDescription &&
            lhs.errorCategory == rhs.errorCategory &&
            lhs.errorKey == rhs.errorKey
    }
}

extension FrameworkError {
    public init(error: Error) {
        internalError = error

        if let categorizableError = error as? ErrorCategorizable {
            errorCategory = categorizableError.category
        } else {
            errorCategory = .unknown
        }

        if let keyableError = error as? ErrorDisplayable {
            errorKey = keyableError.errorKey
        } else {
            errorKey = "UNKNOWN_ERROR"
        }
    }

    public init(error: ErrorCategorizable & ErrorDisplayable) {
        internalError = error
        errorCategory = error.category
        errorKey = error.errorKey
    }
}

extension FrameworkError: LocalizedError {
    public var errorDescription: String? {
        return internalError.localizedDescription
    }
}

extension FrameworkError: ErrorDisplayable { }

// MARK: - Framework Specific Errors
extension FrameworkError {
    public enum AccountServiceError: ErrorCategorizable, ErrorDisplayable {
        case missingKeypair
        case nonExistentAccount
        case alreadyInitialized
        case keypairCreation
        case migrationFailed

        public var category: ErrorCategory {
            return .internal
        }

        public var errorKey: String {
            switch self {
            case .missingKeypair: return "MISSING_KEYPAIR_ERROR"
            case .nonExistentAccount: return "NO_ACCOUNT_ERROR"
            case .alreadyInitialized: return "ALREADY_INITIALIZED_ERROR"
            case .keypairCreation: return "KEYPAIR_CREATION_ERROR"
            case .migrationFailed: return "MIGRATION_FAILED_ERROR"
            }
        }
    }

    public enum TradeServiceError: ErrorCategorizable, ErrorDisplayable {
        case postTrade
        case cancelTrade

        public var category: ErrorCategory {
            return .internal
        }

        public var errorKey: String {
            switch self {
            case .postTrade: return "POST_TRADE_ERROR"
            case .cancelTrade: return "CANCEL_TRADE_ERROR"
            }
        }
    }

    /// Errors relating to problems that can occur when performing operations on a stream.
    ///
    /// - invalidStreamState: Used when an operation can't be performed on the stream becuase it's in the wrong state.
    /// - unsupportedStreamType: Communication with this Horizon stream is not supported.
    public enum StreamServiceError: ErrorCategorizable {
        case invalidStreamState
        case unsupportedStreamType

        public var category: ErrorCategory {
            return .internal
        }
    }
}
