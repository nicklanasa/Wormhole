//
//  WebViewController.swift
//  MyReddit
//
//  Created by Nick Lanasa on 4/28/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation
import UIKit

class WebViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var linkLabel: UILabel!
    
    var url: NSURL!

    override func viewDidLoad() {
        var request = NSURLRequest(URL: self.url)
        self.webView.loadRequest(request)
        self.webView.delegate = self
        
        self.navigationItem.title = self.url.absoluteString
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        LocalyticsSession.shared().tagScreen("WebView")
    }

    @IBAction func closeButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func shareButtonTapped(sender: AnyObject) {
        let objectsToShare = [self.url]
        
        let activityVC = UIActivityViewController(activityItems: objectsToShare,
            applicationActivities: nil)
        
        self.presentViewController(activityVC, animated: true, completion: nil)
        
        LocalyticsSession.shared().tagEvent("Share button tapped WebView")
    }
}