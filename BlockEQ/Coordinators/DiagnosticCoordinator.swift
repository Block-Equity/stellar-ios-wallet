//
//  DiagnosticCoordinator.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-11-12.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Foundation

protocol DiagnosticCoordinatorDelegate: AnyObject {
    func completedDiagnostic(_ coordinator: DiagnosticCoordinator)
}

final class DiagnosticCoordinator {
    var diagnosticQueue: OperationQueue {
        let operationQueue = OperationQueue()
        operationQueue.qualityOfService = .background

        return operationQueue
    }

    let diagnosticViewController = DiagnosticViewController()

    weak var delegate: DiagnosticCoordinatorDelegate?

    var currentDiagnostic: Diagnostic?
    var step: DiagnosticStep = .summary

    init() {
        diagnosticViewController.delegate = self
    }

    func reset() {
        currentDiagnostic = nil
        step = .summary

        diagnosticViewController.scrollTo(step: step, animated: false)
    }

    func runWalletDiagnostic() {
        let diagnostic = Diagnostic(walletDiagnostic: KeychainHelper.walletDiagnostic)
        currentDiagnostic = diagnostic
        diagnosticViewController.update(with: diagnostic)
    }

    func runBasicDiagnostic() {
        let diagnostic = Diagnostic()
        currentDiagnostic = diagnostic
        diagnosticViewController.update(with: diagnostic)
    }

    func sendDiagnostic() {
        guard let diagnostic = currentDiagnostic else {
            return
        }

        diagnosticViewController.showHud()

        let diagnosticOperation = SendDiagnosticOperation(
            diagnostic: diagnostic,
            completion: { result in
                self.step = .completion(result)
                self.diagnosticViewController.update(with: self.step, identifier: result)
        })

        diagnosticQueue.addOperation(diagnosticOperation)
    }
}

// MARK: - DiagnosticViewControllerDelegate
extension DiagnosticCoordinator: DiagnosticViewControllerDelegate {
    func selectedNextStep(_ viewController: DiagnosticViewController) {
        if step == .summary {
            sendDiagnostic()
        }
    }

    func selectedClose(_ viewController: DiagnosticViewController) {
        diagnosticViewController.dismiss(animated: true) {
            self.delegate?.completedDiagnostic(self)
        }
    }
}

// MARK: - DiagnosticStep
extension DiagnosticCoordinator {
    enum DiagnosticStep: Equatable {
        case summary
        case completion(Int?)

        var title: String {
            switch self {
            case .summary: return "WALLET_DIAGNOSTICS_TITLE".localized()
            case .completion(let result):
                let incomplete = "DIAGNOSTIC_INCOMPLETE_TITLE".localized()
                let complete = "DIAGNOSTIC_COMPLETE_TITLE".localized()
                return result != nil ? complete : incomplete
            }
        }

        var description: String {
            switch self {
            case .summary:
                let shortDescription = "WALLET_DIAGNOSTICS_DESCRIPTION_SHORT".localized()
                let normalDescription = "WALLET_DIAGNOSTICS_DESCRIPTION".localized()
                return UIDevice.current.shortScreen ? shortDescription : normalDescription
            case .completion(let result):
                let incomplete = "DIAGNOSTIC_INCOMPLETE_DESCRIPTION".localized()
                let complete = "DIAGNOSTIC_COMPLETE_DESCRIPTION".localized()
                return result != nil ? complete : incomplete
            }
        }

        var image: UIImage? {
            switch self {
            case .summary:
                return UIImage(named: "icon-clipboard")
            case .completion(let result):
                return result != nil ? UIImage(named: "icon-check") : UIImage(named: "icon-delete")
            }
        }

        var color: UIColor {
            switch self {
            case .summary: return .black
            case .completion(let result): return result != nil ? Colors.green : Colors.red
            }
        }

        var index: Int {
            switch self {
            case .summary: return 0
            case .completion: return 1
            }
        }

        var status: String {
            switch self {
            case .summary: return ""
            case .completion(let result):
                return result != nil ? String(result!) : "FAILED_DIAGNOSTIC".localized()
            }
        }

        static let all: [DiagnosticStep] = [.summary, .completion(nil)]
    }
}
