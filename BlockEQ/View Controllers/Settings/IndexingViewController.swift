//
//  IndexingViewController.swift
//  BlockEQ
//
//  Created by Nick DiZazzo on 2018-11-16.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Foundation

protocol IndexingViewControllerDelegate: AnyObject {
    func requestedCancelIndexing(_ viewController: IndexingViewController)
    func requestedRestartIndexing(_ viewController: IndexingViewController)
}

final class IndexingViewController: UIViewController {
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var restartButton: UIButton!

    weak var delegate: IndexingViewControllerDelegate?
    var progress: Double?
    var error: Error?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupStyle()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateView()
    }

    func setupStyle() {
        progressView.tintColor = Colors.backgroundDark
        closeButton.tintColor = Colors.black
        closeButton.setImage(UIImage(named: "close")?.withRenderingMode(.alwaysTemplate), for: .normal)
        progressLabel.font = UIFont.systemFont(ofSize: 10, weight: .light)
    }

    func updateView() {
        guard isViewLoaded else { return }

        if let indexingProgress = progress {
            let percentage = (indexingProgress * 100).displayFormattedString
            progressLabel.text = String(format: "%@%@", percentage, "% completed")
            progressView.setProgress(Float(indexingProgress), animated: true)
        } else {
            progressLabel.text = "Stopped"
            progressView.setProgress(0, animated: false)
        }

        if let error = error {
            progressLabel.text = error.localizedDescription
            progressLabel.textColor = Colors.red
        } else {
            progressLabel.textColor = Colors.black
        }
    }

    func update(with progress: Double?, error: Error?) {
        self.progress = progress
        self.error = error
        self.updateView()
    }
}

// MARK: - IBActions
extension IndexingViewController {
    @IBAction func closeSelected(_ sender: Any) {
        progressView.observedProgress = nil
        progress = nil
        dismiss(animated: true, completion: nil)
    }

    @IBAction func selectedRestart(_ sender: Any) {
        progressView.progress = 0
        delegate?.requestedRestartIndexing(self)
    }

    @IBAction func selectedCancel(_ sender: Any) {
        delegate?.requestedCancelIndexing(self)
    }
}
