//
//  IPadSettingsViewController.swift
//  MyReddit
//
//  Created by Nick Lanasa on 5/15/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation
import UIKit
import MBProgressHUD
import SafariServices

class IPadSettingsViewController: UITableViewController, BDGIAPDelegate {
    
    @IBOutlet weak var showFlairSwitch: UISwitch!
    @IBOutlet weak var showNSFWSwitch: UISwitch!
    @IBOutlet weak var showSubredditLogosSwitch: UISwitch!
    @IBOutlet weak var defaultToReaderModeSwitch: UISwitch!
    @IBOutlet weak var fullWidthImagesSwitch: UISwitch!
    @IBOutlet weak var nightModeSwitch: UISwitch!
    @IBOutlet weak var textSizeLabel: UILabel!
    @IBOutlet weak var commentTextSizeLabel: UILabel!
    
    @IBOutlet weak var showFlairCell: UserInfoCell!
    @IBOutlet weak var showNSFWCell: UserInfoCell!
    @IBOutlet weak var hideSubredditLogosCell: UserInfoCell!
    @IBOutlet weak var textSizeCell: UserInfoCell!
    @IBOutlet weak var commentTextSizeCell: UserInfoCell!
    @IBOutlet weak var infinitePostScrollingCell: UserInfoCell!
    @IBOutlet weak var goToMyRedditCell: UserInfoCell!
    @IBOutlet weak var rateThisAppCell: UserInfoCell!
    @IBOutlet weak var likeUsOnFacebookCell: UserInfoCell!
    @IBOutlet weak var shareAppCell: UserInfoCell!
    @IBOutlet weak var restorePurchaseCell: UserInfoCell!
    @IBOutlet weak var removeAdsCell: UserInfoCell!
    @IBOutlet weak var nytekProductionsCreatorCell: UserInfoCell!
    @IBOutlet weak var nickolasLanasaCreatorCell: UserInfoCell!
    @IBOutlet weak var samanthaLanasaCreatorCell: UserInfoCell!
    @IBOutlet weak var otherAppMuzCell: UserInfoCell!
    @IBOutlet weak var hideFullWidthImagesCell: UserInfoCell!
    @IBOutlet weak var defaultToReaderModeCell: UserInfoCell!
    
    var hud: MBProgressHUD! {
        didSet {
            hud.labelFont = MyRedditSelfTextFont
            hud.mode = .Indeterminate
            hud.labelText = "Loading"
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        LocalyticsSession.shared().tagScreen("Settings")
    }
    
    override func viewDidLoad() {
        self.updateTable()
    }
    
    private func updateTable() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let currentTextSize = SettingsManager.defaultManager.defaultTextSize
            self.showFlairSwitch.on = SettingsManager.defaultManager.valueForSetting(.Flair)
            self.showNSFWSwitch.on = SettingsManager.defaultManager.valueForSetting(.NSFW)
            self.showSubredditLogosSwitch.on = SettingsManager.defaultManager.valueForSetting(.SubredditLogos)
            self.fullWidthImagesSwitch.on = SettingsManager.defaultManager.valueForSetting(.FullWidthImages)
            self.nightModeSwitch.on = SettingsManager.defaultManager.valueForSetting(.NightMode)
            self.textSizeLabel.text = SettingsManager.defaultManager.valueForTextSizeSetting(currentTextSize)
            self.commentTextSizeLabel.text = SettingsManager.defaultManager.valueForCommentTextSizeSetting(currentTextSize)
            self.defaultToReaderModeSwitch.on = SettingsManager.defaultManager.valueForSetting(.DefaultToReaderMode)
            
            self.showFlairCell.backgroundColor = MyRedditBackgroundColor
            self.showFlairCell.titleLabel.textColor = MyRedditLabelColor
            self.showNSFWCell.titleLabel.textColor = MyRedditLabelColor
            self.showNSFWCell.backgroundColor = MyRedditBackgroundColor
            self.hideSubredditLogosCell.titleLabel.textColor = MyRedditLabelColor
            self.hideSubredditLogosCell.backgroundColor = MyRedditBackgroundColor
            self.textSizeCell.titleLabel.textColor = MyRedditLabelColor
            self.textSizeCell.backgroundColor = MyRedditBackgroundColor
            self.commentTextSizeCell.titleLabel.textColor = MyRedditLabelColor
            self.commentTextSizeCell.backgroundColor = MyRedditBackgroundColor
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
            self.defaultToReaderModeCell.titleLabel.textColor = MyRedditLabelColor
            self.defaultToReaderModeCell.backgroundColor = MyRedditBackgroundColor
            self.removeAdsCell.titleLabel.textColor = MyRedditLabelColor
            self.removeAdsCell.backgroundColor = MyRedditBackgroundColor
            
            self.hideFullWidthImagesCell.titleLabel.textColor = MyRedditLabelColor
            self.hideFullWidthImagesCell.backgroundColor = MyRedditBackgroundColor
            
            self.tableView.separatorColor = MyRedditTableSeparatorColor
            self.tableView.backgroundColor = MyRedditDarkBackgroundColor
            self.navigationController?.navigationBar.barTintColor = MyRedditBackgroundColor
            self.navigationController?.navigationBar.tintColor = MyRedditLabelColor
            self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : MyRedditLabelColor]
        })
    }
    
    @IBAction func defaultToReaderModeValueChanged(sender: AnyObject) {
        SettingsManager.defaultManager.updateValueForSetting(.DefaultToReaderMode, value: self.defaultToReaderModeSwitch.on)
    }
    
    @IBAction func hideFullWidthImagesValueChanged(sender: AnyObject) {
        SettingsManager.defaultManager.updateValueForSetting(.FullWidthImages,
            value: self.fullWidthImagesSwitch.on)
        NSNotificationCenter.defaultCenter().postNotificationName(MyRedditAppearanceDidChangeNotification,
            object: nil)
    }
    
    @IBAction func showSubredditLogosValueChanged(sender: AnyObject) {
        SettingsManager.defaultManager.updateValueForSetting(.SubredditLogos,
            value: self.showSubredditLogosSwitch.on)
    }
    
    @IBAction func showNSFWValueChanged(sender: AnyObject) {
        SettingsManager.defaultManager.updateValueForSetting(.NSFW,
            value: self.showNSFWSwitch.on)
        NSNotificationCenter.defaultCenter().postNotificationName(MyRedditAppearanceDidChangeNotification,
            object: nil)
    }
    
    @IBAction func showFlairValueChanged(sender: AnyObject) {
        SettingsManager.defaultManager.updateValueForSetting(.Flair,
            value: self.showFlairSwitch.on)
        NSNotificationCenter.defaultCenter().postNotificationName(MyRedditAppearanceDidChangeNotification,
            object: nil)
    }

    @IBAction func nightModeValueChanged(sender: AnyObject) {
        SettingsManager.defaultManager.updateValueForSetting(.NightMode, value: self.nightModeSwitch.on)
        
        if SettingsManager.defaultManager.valueForSetting(.NightMode) {
            UserSession.sharedSession.nightMode()
        } else {
            UserSession.sharedSession.dayMode()
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(MyRedditAppearanceDidChangeNotification,
            object: nil)
        
        self.updateTable()
    }
    
    private func showTextSizeDialogForType(type: TextSizeType) {
        let alert = UIAlertController(title: "Text Size",
            message: "Please select the text size. This will change the text size for both comments and posts.",
            preferredStyle: .ActionSheet)
        
        alert.addAction(UIAlertAction(title: "small", style: .Default, handler: { (action) -> Void in
            SettingsManager.defaultManager.updateValueForTextSizeType(type, setting: .Small)
            self.updateTable()
            
            NSNotificationCenter.defaultCenter().postNotificationName(MyRedditAppearanceDidChangeNotification,
                object: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "medium", style: .Default, handler: { (action) -> Void in
            SettingsManager.defaultManager.updateValueForTextSizeType(type, setting: .Medium)
            self.updateTable()
            
            NSNotificationCenter.defaultCenter().postNotificationName(MyRedditAppearanceDidChangeNotification,
                object: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "large", style: .Default, handler: { (action) -> Void in
            SettingsManager.defaultManager.updateValueForTextSizeType(type, setting: .Large)
            self.updateTable()
            
            NSNotificationCenter.defaultCenter().postNotificationName(MyRedditAppearanceDidChangeNotification,
                object: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "cancel", style: .Cancel, handler: nil))
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceRect = textSizeCell.bounds
            popoverController.sourceView = textSizeCell
        }
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    private func loadMyRedditSubreddit() {
        let subredditName = "myreddit_app"
        
        RedditSession.sharedSession.searchForSubredditByName(subredditName, pagination: nil, completion: { (pagination, results, error) -> () in
            
            var foundSubreddit: RKSubreddit?
            
            if let subreddits = results as? [RKSubreddit] {
                for subreddit in subreddits {
                    if subreddit.name.lowercaseString == subredditName.lowercaseString {
                        foundSubreddit = subreddit
                        break
                    }
                }
                
                if foundSubreddit == nil {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.presentViewController(UIAlertController.errorAlertControllerWithMessage("Unable to find subreddit."), animated: true, completion: nil)
                    })
                } else {
                    self.performSegueWithIdentifier("MyRedditSubredditSegue", sender: foundSubreddit)
                    LocalyticsSession.shared().tagEvent("Loaded Myreddit subreddit")
                }
            } else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.presentViewController(UIAlertController.errorAlertControllerWithMessage("Unable to find subreddit."), animated: true, completion: nil)
                })
            }
        })
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                // Text Size
                self.showTextSizeDialogForType(.Post)
            } else if indexPath.row == 1 {
                self.showTextSizeDialogForType(.Comment)
            }
        } else if indexPath.section == 2 {
            switch indexPath.row {
            case 0:
                self.loadMyRedditSubreddit()
            case 1:
                LocalyticsSession.shared().tagEvent("Rate app button tapped")
                UIApplication.sharedApplication().openURL(NSURL(string: "itms://itunes.apple.com/us/app/apple-store/id995067625?mt=8")!)
            case 2:
                LocalyticsSession.shared().tagEvent("MyReddit Facebook button tapped")
                let url = NSURL(string: "https://www.facebook.com/pages/MyReddit/442141645823510?ref=hl")
                let svc = SFSafariViewController(URL: url!, entersReaderIfAvailable: true)
                self.presentViewController(svc, animated: true, completion: nil)
            case 3:
                LocalyticsSession.shared().tagEvent("Settings share button tapped")
                let url = NSURL(string: "http://myredditapp.com")
                let shareText = "Check out MyReddit - an iOS app for reddit available on iPhone and iPad #getmyreddit - http://myredditapp.com"
                let objectsToShare = [shareText, url!]
                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                if let popoverController = activityVC.popoverPresentationController {
                    popoverController.sourceRect = shareAppCell.bounds
                    popoverController.sourceView = shareAppCell
                }
                self.presentViewController(activityVC, animated: true, completion: nil)
            case 4:
                LocalyticsSession.shared().tagEvent("Settings restore button tapped")
                // Restore purchase
                self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                BDGInAppPurchase.sharedBDGInAppPurchase().delegate = self
                BDGInAppPurchase.sharedBDGInAppPurchase().productID = SettingsManager.defaultManager.productID
                BDGInAppPurchase.sharedBDGInAppPurchase().restoreIAP()
            case 5: self.performSegueWithIdentifier("PurchaseSegue", sender: nil)
            default: return
            }
        } else if indexPath.section == 3 {
            switch indexPath.row {
            case 0:
                LocalyticsSession.shared().tagEvent("Nytek Productions twitter")
                let url = NSURL(string: "twitter://user?screen_name=Nytekproduction")
                UIApplication.sharedApplication().openURL(url!)
            case 1:
                LocalyticsSession.shared().tagEvent("Nick Lanasa twitter")
                let url = NSURL(string: "twitter://user?screen_name=nicklanasa")
                UIApplication.sharedApplication().openURL(url!)
            case 2:
                LocalyticsSession.shared().tagEvent("Samantha Lanasa twitter")
                let url = NSURL(string: "twitter://user?screen_name=3lovethemapples")
                UIApplication.sharedApplication().openURL(url!)
            default: return
            }
        } else if indexPath.section == 4 {
            LocalyticsSession.shared().tagEvent("Muz button tapped")
            UIApplication.sharedApplication().openURL(NSURL(string: "itms://itunes.apple.com/us/app/apple-store/id951709415?mt=8")!)
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if identifier == "WebViewSegue" {
            if let _ = sender as? NSURL {
                return true
            } else {
                return false
            }
        } else if identifier == "MyRedditSubredditSegue" {
            if let _ = sender as? RKSubreddit {
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
                        
                        if let splitViewController = self.splitViewController {
                            let barButtonItem = splitViewController.displayModeButtonItem()
                            UIApplication.sharedApplication().sendAction(barButtonItem.action,
                                to: barButtonItem.target,
                                from: nil,
                                forEvent: nil)
                        }
                    }
                }
            }
        }
    }
    
    func didFailIAP() {
        LocalyticsSession.shared().tagEvent("Unable to purchase")
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.hud.hide(true)
        })
        UIAlertView(title: "Error!",
            message: "Unable to purchase! Please make sure you have an internet connection.",
            delegate: self,
            cancelButtonTitle: "Ok").show()
    }
    
    func didEndIAS() {
        LocalyticsSession.shared().tagEvent("Purchased cancelled")
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.hud.hide(true)
        })
    }
    
    func didFailIAS() {
        LocalyticsSession.shared().tagEvent("Unable to purchase")
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.hud.hide(true)
        })
        UIAlertView(title: "Error!",
            message: "Unable to purchase! Please make sure you have an internet connection.",
            delegate: self,
            cancelButtonTitle: "Ok").show()
    }
    
    func didCancelIAP() {
        LocalyticsSession.shared().tagEvent("Purchase cancelled")
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.hud.hide(true)
        })
    }
    
    func didPurchaseIAP() {
        LocalyticsSession.shared().tagEvent("Purchased premium with pID: \(SettingsManager.defaultManager.productID)")
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.hud.hide(true)
        })
        NSUserDefaults.standardUserDefaults().setObject(true, forKey: "purchased")
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "expirationDate")
    }
    
    func didRestoreIAP(productID: String!) {
        LocalyticsSession.shared().tagEvent("Restored premium")
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.hud.hide(true)
        })
        NSUserDefaults.standardUserDefaults().setObject(true, forKey: "purchased")
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "expirationDate")
        
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
