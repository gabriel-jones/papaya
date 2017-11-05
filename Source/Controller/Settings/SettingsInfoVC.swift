//
//  SettingsInfoVC.swift
//  PrePacked
//
//  Created by Gabriel Jones on 7/8/17.
//  Copyright © 2017 Fireminds Ltd. All rights reserved.
//

import UIKit

class SettingsInfoVC: UIViewController, UIWebViewDelegate {
    
    var activityIndicator: ActivityIndicator!
    @IBOutlet weak var webView: UIWebView!
    
    enum InfoPage {
        case help, privacy, terms, acknowledgements
    }
    
    var infoType: InfoPage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator = ActivityIndicator(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        activityIndicator.colorType = .White
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        
        webView.delegate = self
        
        let r = URLRequest(url: URL(string: "https://www.google.com")!)
        webView.loadRequest(r)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        activityIndicator.draw()
        activityIndicator.startAnimating()
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }

}
