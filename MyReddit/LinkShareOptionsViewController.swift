//
//  LastFmBuyLinksViewController.swift
//  Muz
//
//  Created by Nick Lanasa on 12/16/14.
//  Copyright (c) 2014 Nytek Productions. All rights reserved.
//

import Foundation
import UIKit

class LinkShareOptionsViewController: UIViewController {
    
    var alertController: UIAlertController!
    
    let link: RKLink!
    
    var barbuttonItem: UIBarButtonItem?
    var sourceView: UIView?
    
    init(link: RKLink) {
        self.link = link
        super.init(nibName: nil, bundle: nil)
        configureActionSheet()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        LocalyticsSession.shared().tagScreen("LinkShareOptions")
    }
    
    /**
    Configures the internal UIAlertController
    */
    private func configureActionSheet() {
        self.alertController = UIAlertController(title: "Select source", message: nil, preferredStyle: .ActionSheet)
    }
    
    /**
    Shows the action view in the given view.
    
    :param: view The view you want the show the action sheet in.
    */
    func showInView(view: UIView) {
        
        if let popoverController = alertController.popoverPresentationController {
            if let item = barbuttonItem {
                popoverController.barButtonItem = item
            } else if let view = self.sourceView {
                popoverController.sourceView = view
                popoverController.sourceRect = view.bounds
            }
        }
        
        self.alertController.addAction(UIAlertAction(title: "open in Safari", style: .Default, handler: { (action) -> Void in
            UIApplication.sharedApplication().openURL(self.link.URL)
            
            LocalyticsSession.shared().tagEvent("Opened link in safari")
        }))
        
        self.alertController.addAction(UIAlertAction(title: "share", style: .Default, handler: { (action) -> Void in
            let objectsToShare = [self.link.title, self.link.URL]
            
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            if let popoverController = activityVC.popoverPresentationController {
                if let view = self.sourceView {
                    popoverController.sourceView = view
                    popoverController.sourceRect = view.bounds
                } else if let item = self.barbuttonItem {
                    popoverController.barButtonItem = item
                }
            }
            
            activityVC.present(animated: true, completion: nil)
            
            LocalyticsSession.shared().tagEvent("Share tapped")
        }))
        
        self.alertController.addAction(UIAlertAction(title: "cancel", style: .Cancel, handler: nil))
        
        self.alertController.present(animated: true, completion: nil)
    }
}