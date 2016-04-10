//
//  PurchaseViewController.swift
//  MyReddit
//
//  Created by Nick Lanasa on 4/30/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation
import UIKit
import Social
import MBProgressHUD

class PurchaseViewController: UIViewController, BDGIAPDelegate {
    
    var hud: MBProgressHUD! {
        didSet {
            hud.labelFont = MyRedditSelfTextFont
            hud.mode = .Indeterminate
            hud.labelText = "Loading"
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        LocalyticsSession.shared().tagScreen("Purchase")
        
        self.view.backgroundColor = MyRedditBackgroundColor
        self.purchaseLabel.textColor = MyRedditLabelColor
        let atts = [NSForegroundColorAttributeName : MyRedditUpvoteColor, NSFontAttributeName : MyRedditTitleFont]
        self.purchaseButton.setTitleTextAttributes(atts,
            forState: .Normal)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    @IBOutlet weak var purchaseButton: UIBarButtonItem!
    @IBOutlet weak var purchaseLabel: UILabel!
    
    @IBAction func purchaseButtonTapped(sender: AnyObject) {
        self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        BDGInAppPurchase.sharedBDGInAppPurchase().delegate = self
        BDGInAppPurchase.sharedBDGInAppPurchase().productID = SettingsManager.defaultManager.productID
        BDGInAppPurchase.sharedBDGInAppPurchase().purchaseIAP()
    }
    
    @IBAction func shareToUnlockButtonTapped(sender: AnyObject) {
        let alert = UIAlertController(title: "Share", message: nil, preferredStyle: .ActionSheet)
        alert.addAction(UIAlertAction(title: "facebook", style: .Default, handler: { (action) -> Void in
            if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook) {
                let socialVC = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
                socialVC.setInitialText("Check out Wormhole - an iOS app for reddit available on iPhone and iPad #getmyreddit - http://myredditapp.com")
                
                let completion: SLComposeViewControllerCompletionHandler = { (result) -> Void in
                    if result == .Done {
                        LocalyticsSession.shared().tagEvent("Facebook share to unlock")
                        NSUserDefaults.standardUserDefaults().setObject(true, forKey: "purchased")
                        NSUserDefaults.standardUserDefaults().setObject(NSDate().dateByAddingMonth(1), forKey: "expirationDate")
                        self.cancelButtonTapped(self)
                    }
                }
                
                socialVC.completionHandler = completion
                
                self.presentViewController(socialVC, animated: true, completion: nil)
            } else {
                self.presentViewController(UIAlertController.errorAlertControllerWithMessage("Please make sure you are logged in to facebook in the Settings app on your device."), animated: true, completion: nil)
                
                LocalyticsSession.shared().tagEvent("Facebook unavailable")
            }
        }))
        alert.addAction(UIAlertAction(title: "twitter", style: .Default, handler: { (action) -> Void in
            if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
                let socialVC = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
                socialVC.setInitialText("Check out Wormhole - an iOS app for reddit available on iPhone and iPad #getmyreddit - http://myredditapp.com")
                
                let completion: SLComposeViewControllerCompletionHandler = { (result) -> Void in
                    if result == .Done {
                        LocalyticsSession.shared().tagEvent("Twitter share to unlock")
                        NSUserDefaults.standardUserDefaults().setObject(true, forKey: "purchased")
                        NSUserDefaults.standardUserDefaults().setObject(NSDate().dateByAddingMonth(1), forKey: "expirationDate")
                        self.cancelButtonTapped(self)
                    }
                }
                
                socialVC.completionHandler = completion
                
                self.presentViewController(socialVC, animated: true, completion: nil)
            } else {
                self.presentViewController(UIAlertController.errorAlertControllerWithMessage("Please make sure you are logged in to twitter in the Settings app on your device."), animated: true, completion: nil)
                LocalyticsSession.shared().tagEvent("Twitter unavailable")
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        if let popoverController = alert.popoverPresentationController {
            let button = sender as! UIButton
            popoverController.sourceView = button
            popoverController.sourceRect = button.bounds
        }
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func didFailIAP() {
        self.hud.hide(true)
        self.presentViewController(UIAlertController.errorAlertControllerWithMessage("Unable to purchase! Please make sure you have an internet connection."), animated: true, completion: nil)
        LocalyticsSession.shared().tagEvent("Unable to purchase")
    }
    
    func didEndIAS() {
        self.hud.hide(true)
        LocalyticsSession.shared().tagEvent("Cancelled purchase")
    }
    
    func didFailIAS() {
        self.hud.hide(true)
        self.presentViewController(UIAlertController.errorAlertControllerWithMessage("Unable to purchase! Please make sure you have an internet connection."), animated: true, completion: nil)
        LocalyticsSession.shared().tagEvent("Unable to purchase")
    }
    
    func didCancelIAP() {
        self.hud.hide(true)
        LocalyticsSession.shared().tagEvent("Cancelled purchase")
    }
    
    func didPurchaseIAP() {
        self.hud.hide(true)
        LocalyticsSession.shared().tagEvent("Purchased premium with pID: \(SettingsManager.defaultManager.productID)")
        NSUserDefaults.standardUserDefaults().setObject(true, forKey: "purchased")
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "expirationDate")
        self.cancelButtonTapped(self)
    }
    
    func didRestoreIAP(productID: String!) {
        LocalyticsSession.shared().tagEvent("Restored premium")
        NSUserDefaults.standardUserDefaults().setObject(true, forKey: "purchased")
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "expirationDate")
        self.cancelButtonTapped(self)
    }
    
    func dismissVC() {
        self.hud.hide(true)
    }
    
    func presentVC(viewController: UIViewController!) {
        self.hud.hide(true)
    }
}
