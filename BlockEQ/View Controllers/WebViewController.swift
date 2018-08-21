//
//  WebViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-06-12.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import WebKit
import UIKit

class WebViewController: UIViewController {

    @IBOutlet var webView: UIWebView!
    var url: URL?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init(url: URL) {
        super.init(nibName: String(describing: WebViewController.self), bundle: nil)

        self.url = url
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let loadableUrl = url  else {
            return
        }

        webView.loadRequest(URLRequest(url: loadableUrl))
    }
}
