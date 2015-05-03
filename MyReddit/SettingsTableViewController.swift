//
//  SettingsTableViewController.swift
//  MyReddit
//
//  Created by Nick Lanasa on 5/2/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation
import UIKit

class SettingsTableViewController: UITableViewController, BDGIAPDelegate {
    
    @IBOutlet weak var showFlairSwitch: UISwitch!
    @IBOutlet weak var showNSFWSwitch: UISwitch!
    @IBOutlet weak var showSubredditLogosSwitch: UISwitch!
    @IBOutlet weak var nightModeSwitch: UISwitch!
    @IBOutlet weak var infiniteScrollingSwitch: UISwitch!
    @IBOutlet weak var textSizeLabel: UILabel!
    
    var hud: MBProgressHUD! {
        didSet {
            hud.labelFont = MyRedditSelfTextFont
            hud.mode = .Indeterminate
            hud.labelText = "Loading"
        }
    }
    
    override func viewDidLoad() {
        var currentTextSize = SettingsManager.defaultManager.defaultTextSize
        
        self.showFlairSwitch.on = SettingsManager.defaultManager.valueForSetting(.Flair)
        self.showNSFWSwitch.on = SettingsManager.defaultManager.valueForSetting(.NSFW)
        self.showSubredditLogosSwitch.on = true
        self.nightModeSwitch.on = SettingsManager.defaultManager.valueForSetting(.NightMode)
        self.infiniteScrollingSwitch.on = SettingsManager.defaultManager.valueForSetting(.InfiniteScrolling)
        self.textSizeLabel.text = SettingsManager.defaultManager.valueForTextSizeSetting(currentTextSize)
    }
    
    @IBAction func nightModeValueChanged(sender: AnyObject) {
        SettingsManager.defaultManager.updateValueForSetting(.NightMode, value: self.nightModeSwitch.on)
    }
    
    @IBAction func showSubredditLogosValueChanged(sender: AnyObject) {
        SettingsManager.defaultManager.updateValueForSetting(.SubredditLogos, value: self.showSubredditLogosSwitch.on)
    }
    
    @IBAction func showNSFWValueChanged(sender: AnyObject) {
        SettingsManager.defaultManager.updateValueForSetting(.NSFW, value: self.showNSFWSwitch.on)
    }
    
    @IBAction func showFlairValueChanged(sender: AnyObject) {
        SettingsManager.defaultManager.updateValueForSetting(.Flair, value: self.showFlairSwitch.on)
    }
    
    @IBAction func infiniteScrollingSwitchValueChanged(sender: AnyObject) {
        SettingsManager.defaultManager.updateValueForSetting(.InfiniteScrolling, value: self.infiniteScrollingSwitch.on)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            if indexPath.row == 1 {
                // Text Size
            }
        } else if indexPath.section == 2 {
            switch indexPath.row {
            case 0:
                RedditSession.sharedSession.subredditWithSubredditName("myreddit", completion: { (pagination, results, error) -> () in
                    if error != nil {
                        UIAlertView(title: "Error!",
                            message: "Unable to find that subreddit! Please check your internet connection.",
                            delegate: self,
                            cancelButtonTitle: "Ok").show()
                    } else {
                        if let subreddit = results?.first as? RKSubreddit {
                            self.performSegueWithIdentifier("MyRedditSubredditSegue", sender: subreddit)
                        }
                    }
                })
            case 1:
                UIApplication.sharedApplication().openURL(NSURL(string: "itms://itunes.apple.com/us/app/apple-store/id544533053?mt=8")!)
            case 2:
                var url = NSURL(string: "https://www.facebook.com/pages/MyReddit/442141645823510?ref=hl")
                self.performSegueWithIdentifier("WebViewSegue", sender: url)
            case 3:
                var url = NSURL(string: "https://www.facebook.com/pages/MyReddit/442141645823510?ref=hl")
                var shareText = "Check out MyReddit - A Reddit client for iOS that rocks!"
                let objectsToShare = [shareText, url!]
                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                self.presentViewController(activityVC, animated: true, completion: nil)
            case 4:
                // Restore purchase
                self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                BDGInAppPurchase.sharedBDGInAppPurchase().delegate = self
                BDGInAppPurchase.sharedBDGInAppPurchase().productID = "myreddit.premium"
                BDGInAppPurchase.sharedBDGInAppPurchase().restoreIAP()
            default: return
            }
        } else if indexPath.section == 3 {
            switch indexPath.row {
            case 0:
                var url = NSURL(string: "https://twitter.com/Nytekproduction")
                self.performSegueWithIdentifier("WebViewSegue", sender: url)
            case 1:
                var url = NSURL(string: "https://twitter.com/nicklanasa")
                self.performSegueWithIdentifier("WebViewSegue", sender: url)
            case 2:
                var url = NSURL(string: "https://twitter.com/3lovethemapples")
                self.performSegueWithIdentifier("WebViewSegue", sender: url)
            default: return
            }
        } else if indexPath.section == 3 {
            UIApplication.sharedApplication().openURL(NSURL(string: "itms://itunes.apple.com/us/app/apple-store/id951709415?mt=8")!)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "WebViewSegue" {
            if let controller = segue.destinationViewController as? WebViewController {
                if let requestURL = sender as? NSURL {
                    controller.url = requestURL
                }
            }
        }
    }
    
    func didFailIAP() {
        self.hud.hide(true)
        UIAlertView(title: "Error!",
            message: "Unable to purchase! Please make sure you have an internet connection.",
            delegate: self,
            cancelButtonTitle: "Ok").show()
    }
    
    func didEndIAS() {
        self.hud.hide(true)
    }
    
    func didFailIAS() {
        self.hud.hide(true)
        UIAlertView(title: "Error!",
            message: "Unable to purchase! Please make sure you have an internet connection.",
            delegate: self,
            cancelButtonTitle: "Ok").show()
    }
    
    func didCancelIAP() {
        self.hud.hide(true)
    }
    
    func didPurchaseIAP() {
        self.hud.hide(true)
        NSUserDefaults.standardUserDefaults().setObject(true, forKey: "purchased")
        UIAlertView(title: "Success!",
            message: "Purchase restored!",
            delegate: self,
            cancelButtonTitle: "Ok").show()
    }
    
    func didRestoreIAP(productID: String!) {
        NSUserDefaults.standardUserDefaults().setObject(true, forKey: "purchased")
        UIAlertView(title: "Success!",
            message: "Purchase restored!",
            delegate: self,
            cancelButtonTitle: "Ok").show()
    }
    
    func dismissVC() {
        self.hud.hide(true)
    }
    
    func presentVC(viewController: UIViewController!) {
        self.hud.hide(true)
    }
}
