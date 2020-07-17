//
//  WebViewController.swift
//  Papaya Meal Planner
//
//  Created by Norton Gumbo on 1/28/17.
//  Copyright © 2017 Papaya LC. All rights reserved.
//

import UIKit

class WebViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    
    var url: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.delegate = self
        if let url = URL(string: url) {
            let request = URLRequest(url: url)
            webView.loadRequest(request)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.isStatusBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Show status bar again after dismiss
        UIApplication.shared.isStatusBarHidden = false
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func doneButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        if webView.canGoBack {
            webView.goBack()
        }
    }
    
    @IBAction func forwardButton(_ sender: UIButton) {
        if webView.canGoForward {
            webView.goForward()
        }
    }
    
}
