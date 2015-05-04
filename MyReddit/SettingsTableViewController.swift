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
    
    @IBOutlet weak var showFlairCell: UserInfoCell!
    @IBOutlet weak var showNSFWCell: UserInfoCell!
    @IBOutlet weak var hideSubredditLogosCell: UserInfoCell!
    @IBOutlet weak var nightModeCell: UserInfoCell!
    @IBOutlet weak var textSizeCell: UserInfoCell!
    @IBOutlet weak var infinitePostScrollingCell: UserInfoCell!
    @IBOutlet weak var goToMyRedditCell: UserInfoCell!
    @IBOutlet weak var rateThisAppCell: UserInfoCell!
    @IBOutlet weak var likeUsOnFacebookCell: UserInfoCell!
    @IBOutlet weak var shareAppCell: UserInfoCell!
    @IBOutlet weak var restorePurchaseCell: UserInfoCell!
    @IBOutlet weak var nytekProductionsCreatorCell: UserInfoCell!
    @IBOutlet weak var nickolasLanasaCreatorCell: UserInfoCell!
    @IBOutlet weak var samanthaLanasaCreatorCell: UserInfoCell!
    @IBOutlet weak var otherAppMuzCell: UserInfoCell!
    
    var hud: MBProgressHUD! {
        didSet {
            hud.labelFont = MyRedditSelfTextFont
            hud.mode = .Indeterminate
            hud.labelText = "Loading"
        }
    }
    
    override func viewDidLoad() {
        self.updateTable()
    }
    
    private func updateTable() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            var currentTextSize = SettingsManager.defaultManager.defaultTextSize
            self.showFlairSwitch.on = SettingsManager.defaultManager.valueForSetting(.Flair)
            self.showNSFWSwitch.on = SettingsManager.defaultManager.valueForSetting(.NSFW)
            self.showSubredditLogosSwitch.on = SettingsManager.defaultManager.valueForSetting(.SubredditLogos)
            self.nightModeSwitch.on = SettingsManager.defaultManager.valueForSetting(.NightMode)
            self.infiniteScrollingSwitch.on = SettingsManager.defaultManager.valueForSetting(.InfiniteScrolling)
            self.textSizeLabel.text = SettingsManager.defaultManager.valueForTextSizeSetting(currentTextSize)
            
            self.showFlairCell.backgroundColor = MyRedditBackgroundColor
            self.showFlairCell.titleLabel.textColor = MyRedditLabelColor
            self.showNSFWCell.titleLabel.textColor = MyRedditLabelColor
            self.showNSFWCell.backgroundColor = MyRedditBackgroundColor
            self.hideSubredditLogosCell.titleLabel.textColor = MyRedditLabelColor
            self.hideSubredditLogosCell.backgroundColor = MyRedditBackgroundColor
            self.nightModeCell.titleLabel.textColor = MyRedditLabelColor
            self.nightModeCell.backgroundColor = MyRedditBackgroundColor
            self.textSizeCell.titleLabel.textColor = MyRedditLabelColor
            self.textSizeCell.backgroundColor = MyRedditBackgroundColor
            self.infinitePostScrollingCell.titleLabel.textColor = MyRedditLabelColor
            self.infinitePostScrollingCell.backgroundColor = MyRedditBackgroundColor
            self.goToMyRedditCell.titleLabel.textColor = MyRedditLabelColor
            self.goToMyRedditCell.backgroundColor = MyRedditBackgroundColor
            self.rateThisAppCell.titleLabel.textColor = MyRedditLabelColor
            self.rateThisAppCell.backgroundColor = MyRedditBackgroundColor
            self.likeUsOnFacebookCell.titleLabel.textColor = MyRedditLabelColor
            self.likeUsOnFacebookCell.backgroundColor = MyRedditBackgroundColor
            self.shareAppCell.titleLabel.textColor = MyRedditLabelColor
            self.shareAppCell.backgroundColor = MyRedditBackgroundColor
            self.restorePurchaseCell.titleLabel.textColor = MyRedditLabelColor
            self.restorePurchaseCell.backgroundColor = MyRedditBackgroundColor
            self.nytekProductionsCreatorCell.titleLabel.textColor = MyRedditLabelColor
            self.nytekProductionsCreatorCell.backgroundColor = MyRedditBackgroundColor
            self.nickolasLanasaCreatorCell.titleLabel.textColor = MyRedditLabelColor
            self.nickolasLanasaCreatorCell.backgroundColor = MyRedditBackgroundColor
            self.samanthaLanasaCreatorCell.titleLabel.textColor = MyRedditLabelColor
            self.samanthaLanasaCreatorCell.backgroundColor = MyRedditBackgroundColor
            self.otherAppMuzCell.titleLabel.textColor = MyRedditLabelColor
            self.otherAppMuzCell.backgroundColor = MyRedditBackgroundColor
            
            self.tableView.backgroundColor = MyRedditDarkBackgroundColor
            self.navigationController?.navigationBar.barTintColor = MyRedditBackgroundColor
            self.navigationController?.navigationBar.tintColor = MyRedditLabelColor
            self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : MyRedditLabelColor]
        })
    }
    
    @IBAction func nightModeValueChanged(sender: AnyObject) {
        SettingsManager.defaultManager.updateValueForSetting(.NightMode, value: self.nightModeSwitch.on)
        
        if SettingsManager.defaultManager.valueForSetting(.NightMode) {
            UserSession.sharedSession.nightMode()
        } else {
            UserSession.sharedSession.dayMode()
        }
        
        self.updateTable()
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
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.section == 1 {
            if indexPath.row == 1 {
                // Text Size
                var alert = UIAlertController(title: "Text Size",
                    message: "Please select the text size. This will change the text size for both comments and posts.",
                    preferredStyle: .ActionSheet)
                
                alert.addAction(UIAlertAction(title: "Small", style: .Default, handler: { (action) -> Void in
                    SettingsManager.defaultManager.updateValueForTextSizeSetting(.Small)
                    self.updateTable()
                }))
                
                alert.addAction(UIAlertAction(title: "Medium", style: .Default, handler: { (action) -> Void in
                    SettingsManager.defaultManager.updateValueForTextSizeSetting(.Medium)
                    self.updateTable()
                }))
                
                alert.addAction(UIAlertAction(title: "Large", style: .Default, handler: { (action) -> Void in
                    SettingsManager.defaultManager.updateValueForTextSizeSetting(.Large)
                    self.updateTable()
                }))
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
                
                self.presentViewController(alert, animated: true, completion: nil)
            }
        } else if indexPath.section == 2 {
            switch indexPath.row {
            case 0:
                RedditSession.sharedSession.subredditWithSubredditName("myreddit_app", completion: { (pagination, results, error) -> () in
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
                var url = NSURL(string: "twitter://user?screen_name=Nytekproduction")
                UIApplication.sharedApplication().openURL(url!)
            case 1:
                var url = NSURL(string: "twitter://user?screen_name=nicklanasa")
                UIApplication.sharedApplication().openURL(url!)
            case 2:
                var url = NSURL(string: "twitter://user?screen_name=3lovethemapples")
                UIApplication.sharedApplication().openURL(url!)
            default: return
            }
        } else if indexPath.section == 4 {
            UIApplication.sharedApplication().openURL(NSURL(string: "itms://itunes.apple.com/us/app/apple-store/id951709415?mt=8")!)
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if identifier == "WebViewSegue" {
            if let requestURL = sender as? NSURL {
                return true
            } else {
                return false
            }
        } else if identifier == "MyRedditSubredditSegue" {
            if let subreddit = sender as? RKSubreddit {
                return true
            } else {
                return false
            }
        }
        
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "WebViewSegue" {
            if let nav = segue.destinationViewController as? UINavigationController {
                if let controller = nav.viewControllers[0] as? WebViewController {
                    if let requestURL = sender as? NSURL {
                        controller.url = requestURL
                    }
                }
            }
        } else if segue.identifier == "MyRedditSubredditSegue" {
            if let nav = segue.destinationViewController as? NavBarController {
                if let controller = nav.viewControllers[0] as? SubredditViewController {
                    if let subreddit = sender as? RKSubreddit {
                        controller.subreddit = subreddit
                        controller.front = false
                    }
                }
            }
        }
    }
    
    func didFailIAP() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.hud.hide(true)
        })
        UIAlertView(title: "Error!",
            message: "Unable to purchase! Please make sure you have an internet connection.",
            delegate: self,
            cancelButtonTitle: "Ok").show()
    }
    
    func didEndIAS() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.hud.hide(true)
        })
    }
    
    func didFailIAS() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.hud.hide(true)
        })
        UIAlertView(title: "Error!",
            message: "Unable to purchase! Please make sure you have an internet connection.",
            delegate: self,
            cancelButtonTitle: "Ok").show()
    }
    
    func didCancelIAP() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.hud.hide(true)
        })
    }
    
    func didPurchaseIAP() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.hud.hide(true)
        })
        NSUserDefaults.standardUserDefaults().setObject(true, forKey: "purchased")
    }
    
    func didRestoreIAP(productID: String!) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.hud.hide(true)
        })
        NSUserDefaults.standardUserDefaults().setObject(true, forKey: "purchased")
        
        UIAlertView(title: "Success!",
            message: "Purchase restored!",
            delegate: self,
            cancelButtonTitle: "Ok").show()
    }
    
    func dismissVC() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.hud.hide(true)
        })
    }
    
    func presentVC(viewController: UIViewController!) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.hud.hide(true)
        })
    }
}
