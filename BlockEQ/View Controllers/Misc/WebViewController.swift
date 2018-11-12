//
//  WebViewController.swift
//  Uphabit
//
//  Created by Nick DiZazzo on 2018-09-28.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Foundation

class WebViewController: UIViewController {

    let url: URL
    let webView = UIWebView()
    let pageTitle: String

    init(url: URL, pageTitle: String) {
        self.url = url
        self.pageTitle = pageTitle
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        self.url = BlockEQURL.site.url
        self.pageTitle = "BLOCKEQ_WEBSITE".localized()
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupWebView()
        setupConstraints()
    }

    private func setupNavBar() {
        navigationItem.title = pageTitle
        navigationItem.backBarButtonItem = nil
    }

    private func setupWebView() {
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.delegate = self
        view.addSubview(webView)

        let request = URLRequest(url: url)
        webView.loadRequest(request)
    }

    private func setupConstraints() {
        view.constrainViewToAllSafeEdges(webView)
    }
}

extension WebViewController: UIWebViewDelegate {
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        UIAlertController.simpleAlert(title: "ERROR_TITLE".localized(),
                                      message: error.localizedDescription,
                                      presentingViewController: self)
    }
}
