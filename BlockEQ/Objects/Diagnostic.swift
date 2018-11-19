//
//  Diagnostic.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-11-11.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

// MARK: - Diagnostic Issues
enum DiagnosticSupportSummary: String, RawRepresentable {
    case paymentsFailing = "My payments are failing"
    case exchangeMissingFunds = "The exchange hasn’t received my funds"
    case incorrectMemo = "I sent an incorrect memo"
    case crashing = "The app is crashing"
    case cantAddAssets = "I can’t add more assets"
    case cantTrade = "My trades are failing"
    case receivingSmallTransactions = "I’m receiving small transactions"
}

// MARK: - Diagnostic
struct Diagnostic {
    var reportId: Int?
    var emailAddress: String?
    var issueSummary: String?
    var walletDiagnostic: WalletDiagnostic?
    var appDiagnostic: AppDiagnostic?

    init() {
        self.appDiagnostic = AppDiagnostic()
    }

    init(email: String, issue: String) {
        issueSummary = issue
        emailAddress = email
        self.appDiagnostic = AppDiagnostic()
    }

    init(walletDiagnostic: WalletDiagnostic?) {
        self.walletDiagnostic = walletDiagnostic
        self.appDiagnostic = AppDiagnostic()
    }

    init(email: String, issue: String, walletDiagnostic: WalletDiagnostic) {
        emailAddress = email
        issueSummary = issue
        self.walletDiagnostic = walletDiagnostic
        self.appDiagnostic = AppDiagnostic()
    }
}

extension Diagnostic: Codable {
    enum FieldsCodingKeys: String, CodingKey {
        case fields
    }

    enum CodingKeys: String, CodingKey {
        case reportId = "Report Id"
        case emailAddress = "Email"
        case issueSummary = "Summary"
        case wallet = "wallet"
        case app = "app"

        // Can't encode keys from WalletDiagnostic, have to copy/paste here
        case walletAddress = "Public Wallet Address"
        case walletCreationMethod = "Wallet Creation Method"
        case walletUsesPassphrase = "Used Passphrase"

        // Can't encode keys from AppDiagnostic, have to copy/paste here
        case hardwareDevice = "Device Hardware"
        case batteryState = "Battery State"
        case locale = "Locale"
        case osVersion = "Platform"
        case appVersion = "App Version"
    }

    init(from decoder: Decoder) throws {
        let fieldsContainer = try decoder.container(keyedBy: FieldsCodingKeys.self)
        let container = try fieldsContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .fields)
        self.reportId = try container.decodeIfPresent(Int.self, forKey: .reportId)
        self.emailAddress = try container.decode(String.self, forKey: .emailAddress)
        self.issueSummary = try container.decode(String.self, forKey: .issueSummary)
    }

    func encode(to encoder: Encoder) throws {
        var fieldsContainer = encoder.container(keyedBy: FieldsCodingKeys.self)
        var container = fieldsContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .fields)

        try container.encodeIfPresent(reportId, forKey: .reportId)
        try container.encode(emailAddress, forKey: .emailAddress)
        try container.encode(issueSummary, forKey: .issueSummary)

        try container.encodeIfPresent(walletDiagnostic?.walletAddress, forKey: .walletAddress)
        try container.encodeIfPresent(walletDiagnostic?.walletUsesPassphrase, forKey: .walletUsesPassphrase)
        try container.encodeIfPresent(walletDiagnostic?.walletCreationMethod?.rawValue, forKey: .walletCreationMethod)

        try container.encodeIfPresent(appDiagnostic?.appVersion, forKey: .appVersion)
        try container.encodeIfPresent(appDiagnostic?.batteryState, forKey: .batteryState)
        try container.encodeIfPresent(appDiagnostic?.hardwareDevice, forKey: .hardwareDevice)
        try container.encodeIfPresent(appDiagnostic?.locale, forKey: .locale)
        try container.encodeIfPresent(appDiagnostic?.osVersion, forKey: .osVersion)
    }
}

extension Diagnostic {
    enum DiagnosticError: LocalizedError {
        case encodingFailure
    }
}

// MARK: - App Diagnostic
struct AppDiagnostic {
    var appVersion: String {
        return DeviceString.version.value
    }

    var rawHardwareDevice: String {
        return UIDevice.current.modelName
    }

    var locale: String {
        return "\(NSLocale.current.languageCode ?? "??")-\(NSLocale.current.regionCode ?? "??")"
    }

    var osVersion: String {
        return "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"
    }

    var batteryState: String? {
        switch UIDevice.current.batteryState {
        case .unknown: return nil
        default: return "\(UIDevice.current.batteryState.stateString) - \(UIDevice.current.batteryLevel * 100.0)%"
        }
    }

    var hardwareDevice: String {
        return DeviceData.deviceNamesByCode[self.rawHardwareDevice] ?? "Unknown"
    }
}

extension AppDiagnostic: Encodable {
    enum CodingKeys: String, CodingKey {
        case hardwareDevice = "Device Hardware"
        case batteryState = "Battery State"
        case locale = "Locale"
        case osVersion = "Platform"
        case appVersion = "App Version"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.appVersion, forKey: .appVersion)
        try container.encode(self.batteryState, forKey: .batteryState)
        try container.encode(self.hardwareDevice, forKey: .hardwareDevice)
        try container.encode(self.locale, forKey: .locale)
        try container.encode(self.osVersion, forKey: .osVersion)
    }
}

// MARK: - Wallet Diagnostic
struct WalletDiagnostic {
    enum CreationMethod: String, RawRepresentable {
        case createdMnemonic12 = "Created with 12-word Mnemonic"
        case createdMnemonic24 = "Created with 24-word Mnemonic"
        case recoveredMnemonic12 = "Recovered with 12-word Mnemonic"
        case recoveredMnemonic24 = "Recovered with 24-word Mnemonic"
        case recoveredSeed = "Recovered from Secret Seed"
        case unknown = "Unknown"
    }

    var walletAddress: String?
    var walletCreationMethod: CreationMethod?
    var walletUsesPassphrase: Bool?
    var migrated: Bool
}

extension WalletDiagnostic: Codable {
    init(address: String, creationMethod: CreationMethod, usesPassphrase: Bool, walletMigrated: Bool = false) {
        walletAddress = address
        walletCreationMethod = creationMethod
        walletUsesPassphrase = usesPassphrase
        migrated = walletMigrated
    }

    enum CodingKeys: String, CodingKey {
        case walletAddress = "Public Wallet Address"
        case walletCreationMethod = "Wallet Creation Method"
        case walletUsesPassphrase = "Used Passphrase"
        case walletMigrated = "Migrated"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.walletAddress, forKey: .walletAddress)
        try container.encodeIfPresent(self.walletUsesPassphrase, forKey: .walletUsesPassphrase)
        try container.encodeIfPresent(self.walletCreationMethod?.rawValue, forKey: .walletCreationMethod)
        try container.encode(self.migrated, forKey: .walletMigrated)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.migrated = try container.decode(Bool.self, forKey: .walletMigrated)
        self.walletAddress = try container.decodeIfPresent(String.self, forKey: .walletAddress)
        self.walletUsesPassphrase = try container.decodeIfPresent(Bool.self, forKey: .walletUsesPassphrase)

        let creationMethod = try container.decodeIfPresent(String.self, forKey: .walletCreationMethod) ?? ""
        self.walletCreationMethod = CreationMethod(rawValue: creationMethod) ?? .unknown
    }
}
