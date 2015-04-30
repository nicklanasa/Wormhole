//
//  LinkViewController.swift
//  MyReddit
//
//  Created by Nickolas Lanasa on 3/25/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation
import UIKit

class LinkViewController: UIViewController {
    
    var link: RKLink!
    
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        let request = NSURLRequest(URL: link.URL)
        self.webView.loadRequest(request)
        self.webView.backgroundColor = UIColor.whiteColor()
        self.webView.hidden = false
        self.navigationItem.title =  self.link.title
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "CommentsSegue" {
            if let controller = segue.destinationViewController as? CommentsViewController {
                controller.link = link
            }
        }
    }
    
    @IBAction func shareButtonTapped(sender: AnyObject) {
        let objectsToShare = [self.link.title, self.link.URL]
 
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        
        self.presentViewController(activityVC, animated: true, completion: nil)
    }
}