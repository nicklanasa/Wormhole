//
//  SubredditsViewController.swift
//  MyReddit
//
//  Created by Nickolas Lanasa on 3/25/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class SubredditsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var savedButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func editButtonTApped(sender: AnyObject) {
        LocalyticsSession.shared().tagEvent("Subreddits edit button tapped")
        self.tableView.setEditing(true, animated: true)
        
        if let barButton = sender as? UIBarButtonItem {
            barButton.action = "finishEditing:"
            barButton.title = "Done"
        }
    }
    
    var syncSubreddits = Array<AnyObject>()
    var syncMultiSubreddits = Array<AnyObject>()
    
    lazy var refreshControl: UIRefreshControl! = {
        var control = UIRefreshControl()
        control.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes: [NSFontAttributeName : MyRedditCommentTextBoldFont, NSForegroundColorAttributeName : MyRedditLabelColor])
        control.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        return control
    }()
    
    var addSubredditsToMultiRedditAlert: UIAlertController! {
        get {
            var alert = UIAlertController(title: "Search", message: "Would you like to go to search now to add subreddit's to your multireddits?", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Sure", style: .Default, handler: { (a) -> Void in
                LocalyticsSession.shared().tagEvent("Subreddit search after creating multireddit")
                self.performSegueWithIdentifier("SearchSegue", sender: self)
            }))
            
            alert.addAction(UIAlertAction(title: "No", style: .Cancel, handler: { (a) -> Void in
                LocalyticsSession.shared().tagEvent("Cancelled subreddit search after creating multireddit")
            }))
            
            return alert
        }
    }
    
    var subreddits = Array<AnyObject>() {
        didSet {
            self.subreddits.sort({ (first, second) -> Bool in
                if let subreddit1 = first as? RKSubreddit {
                    if let subreddit2 = second as? RKSubreddit {
                        return subreddit1.name.caseInsensitiveCompare(subreddit2.name) == .OrderedAscending
                    }
                }
                
                return false
            })
            
            self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .None)
            
            let subredditsData = NSKeyedArchiver.archivedDataWithRootObject(self.subreddits)
            
            NSUserDefaults.standardUserDefaults().setObject(subredditsData, forKey: "subreddits")
            
            LocalyticsSession.shared().tagEvent("Updated subreddits")
        }
    }
    
    var multiSubreddits = Array<AnyObject>() {
        didSet {
            self.multiSubreddits.sort({ (first, second) -> Bool in
                if let subreddit1 = first as? RKMultireddit {
                    if let subreddit2 = second as? RKMultireddit {
                        return subreddit1.name.caseInsensitiveCompare(subreddit2.name) == .OrderedAscending
                    }
                }
                
                return false
            })
            
            self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .None)
            
            let subredditsData = NSKeyedArchiver.archivedDataWithRootObject(self.multiSubreddits)
            
            NSUserDefaults.standardUserDefaults().setObject(subredditsData, forKey: "multiSubreddits")
            
            LocalyticsSession.shared().tagEvent("Updated multireddits")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.addSubview(self.refreshControl)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        LocalyticsSession.shared().tagScreen("Subreddits")
        
        for item in self.toolbarItems as! [UIBarButtonItem] {
            item.tintColor = MyRedditLabelColor
        }
        
        self.fetchSubreddits()
        
        self.tableView.backgroundColor = MyRedditDarkBackgroundColor
        
    }
    
    func fetchSubreddits() {
        
        self.syncSubreddits = Array<AnyObject>()
        self.syncMultiSubreddits = Array<AnyObject>()
        
        if let subredditsData = NSUserDefaults.standardUserDefaults().objectForKey("subreddits") as? NSData {
            if let subreddits = NSKeyedUnarchiver.unarchiveObjectWithData(subredditsData) as? [RKSubreddit] {
                self.subreddits = subreddits
            }
        }
        
        if let subredditsData = NSUserDefaults.standardUserDefaults().objectForKey("multiSubreddits") as? NSData {
            if let subreddits = NSKeyedUnarchiver.unarchiveObjectWithData(subredditsData) as? [RKMultireddit] {
                self.multiSubreddits = subreddits
            }
        }
        
        self.syncSubreddits(nil)
        self.syncMultiReddits()
        
        self.refreshControl.endRefreshing()
    }
    
    func syncSubreddits(pagination: RKPagination?) {
        
        if UserSession.sharedSession.isSignedIn {
            RedditSession.sharedSession.fetchSubscribedSubreddits(pagination, category: .Subscriber, completion: { (pagination, results, error) -> () in
                if let subreddits = results {
                    if subreddits.count == 0 {
                        self.syncPopularSubreddits()
                    } else {
                        self.syncSubreddits.extend(subreddits)
                        if pagination != nil {
                            self.syncSubreddits(pagination)
                        } else {
                            self.subreddits = self.syncSubreddits
                        }
                    }
                }
            })
        } else {
            self.syncPopularSubreddits()
        }
    }
    
    func syncPopularSubreddits() {
        RedditSession.sharedSession.fetchPopularSubreddits(nil, completion: { (pagination, results, error) -> () in
            if let subreddits = results {
                self.subreddits = subreddits
            }
        })
    }
    
    func syncMultiReddits() {
        if UserSession.sharedSession.isSignedIn {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                RedditSession.sharedSession.fetchMultiReddits({ (pagination, results, error) -> () in
                    if let subreddits = results {
                        self.multiSubreddits = subreddits
                    }
                })
            })
        }
    }
    
    func finishEditing(sender: AnyObject) {
        LocalyticsSession.shared().tagEvent("Finished editing subreddits")
        self.tableView.setEditing(false, animated: true)
        
        if let barButton = sender as? UIBarButtonItem {
            barButton.action = "editButtonTApped:"
            barButton.title = "Edit"
        }
    }
    
    func refresh(sender: AnyObject)
    {
        self.fetchSubreddits()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.multiSubreddits.count + 1
        }
        return self.subreddits.count + 1
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("SubredditCell") as! SubredditCell
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                var cell = tableView.dequeueReusableCellWithIdentifier("NewMultiRedditCell") as! UserInfoCell
                cell.titleLabel.textColor = MyRedditLabelColor
                return cell
            } else {
                if let subreddit = self.multiSubreddits[indexPath.row - 1] as? RKMultireddit {
                    cell.rkMultiSubreddit = subreddit
                }
            }
        } else {
            if indexPath.row == 0 {
                var cell = tableView.dequeueReusableCellWithIdentifier("FrontCell") as! FrontCell
                cell.frontLabel.textColor = MyRedditLabelColor
                
                if SettingsManager.defaultManager.valueForSetting(.NightMode) {
                    cell.starImageView.image = UIImage(named: "starWhite")
                } else {
                    cell.starImageView.image = UIImage(named: "Star")
                }
                
                return cell
            } else {
                if let subreddit = self.subreddits[indexPath.row - 1] as? RKSubreddit {
                    cell.rkSubreddit = subreddit
                }
            }
        }

        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.row == 0 {
            return false
        }
        return true
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        if indexPath.row == 0 {
            return .None
        }
        return .Delete
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {

    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                var alert = UIAlertController(title: "New", message: "Please enter the multireddit name.", preferredStyle: .Alert)
                
                alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
                    
                })
                
                alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action) -> Void in
                    if let textfield = alert.textFields?.first as? UITextField {
                        
                        var multiRedditName = textfield.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                        
                        if count(multiRedditName) == 0 || multiRedditName.componentsSeparatedByString(" ").count > 1 {
                            UIAlertView(title: "Error!", message: "You must enter in a multireddit name!", delegate: self, cancelButtonTitle: "Ok").show()
                            LocalyticsSession.shared().tagEvent("Invalid multireddit name")
                        } else {
                            
                            if count(multiRedditName) < 3 {
                                LocalyticsSession.shared().tagEvent("Invalid multireddit name")
                                UIAlertView(title: "Error!", message: "Multireddit name must be greater than 3 characters!", delegate: self, cancelButtonTitle: "Ok").show()
                            } else {
                                var visibilityAlert = UIAlertController(title: "Visibility", message: "Please select the visibility for the multireddit.", preferredStyle: .Alert)
                                visibilityAlert.addAction(UIAlertAction(title: "Public", style: .Default, handler: { (a) -> Void in
                                    LocalyticsSession.shared().tagEvent("Created public multireddit")
                                    RedditSession.sharedSession.createMultiReddit(multiRedditName, visibility: .Public, completion: { (error) -> () in
                                        self.syncMultiReddits()
                                        self.presentViewController(self.addSubredditsToMultiRedditAlert, animated: true, completion: nil)
                                    })
                                }))
                                
                                visibilityAlert.addAction(UIAlertAction(title: "Private", style: .Default, handler: { (a) -> Void in
                                    LocalyticsSession.shared().tagEvent("Created private multireddit")
                                    RedditSession.sharedSession.createMultiReddit(multiRedditName, visibility: .Private, completion: { (error) -> () in
                                        self.syncMultiReddits()
                                        
                                        self.presentViewController(self.addSubredditsToMultiRedditAlert, animated: true, completion: nil)
                                    })
                                }))
                                
                                self.presentViewController(visibilityAlert, animated: true, completion: nil)
                            }
                        }
                    }
                }))
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
                
                if UserSession.sharedSession.isSignedIn {
                    self.presentViewController(alert, animated: true, completion: nil)
                } else {
                    UIAlertView(title: "Error!",
                        message: "You must logged in to do that!",
                        delegate: self,
                        cancelButtonTitle: "Ok").show()
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        if indexPath.row != 0 {
            let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default,
                title: "Delete",
                handler: { (action, indexPath) -> Void in
                    if indexPath.section == 0 {
                        if let multiReddit = self.multiSubreddits[indexPath.row - 1] as? RKMultireddit {
                            RedditSession.sharedSession.deleteMultiReddit(multiReddit, completion: { (error) -> () in
                                if error != nil {
                                    UIAlertView(title: "Error!", message: "Unable to delete MultiReddit! Please make sure you're connected to the internets.", delegate: self, cancelButtonTitle: "Ok").show()
                                    LocalyticsSession.shared().tagEvent("Delete multireddit failed")
                                } else {
                                    self.multiSubreddits.removeAtIndex(indexPath.row - 1)
                                    LocalyticsSession.shared().tagEvent("Deleted multireddit")
                                }
                            })
                        }
                    } else {
                        if let subreddit = self.subreddits[indexPath.row - 1] as? RKSubreddit {
                            RedditSession.sharedSession.unsubscribe(subreddit, completion: { (error) -> () in
                                if error != nil {
                                    UIAlertView(title: "Error!", message: "Unable to unsubscribe to Subreddit! Please make sure you're connected to the internets.", delegate: self, cancelButtonTitle: "Ok").show()
                                    LocalyticsSession.shared().tagEvent("Subreddit Unsubscribe failed")
                                } else {
                                    self.subreddits.removeAtIndex(indexPath.row-1)
                                    LocalyticsSession.shared().tagEvent("Subreddit unsubscribe")
                                }
                            })
                        }
                    }
            })
            
            return [deleteAction]
        }
        
        return nil
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "MultiReddits"
        }
        
        if UserSession.sharedSession.isSignedIn {
            return "Subscribed"
        } else {
            return "Popular"
        }
    }
    
    @IBAction func savedButtonTapped(sender: AnyObject) {
        if !SettingsManager.defaultManager.purchased {
            self.performSegueWithIdentifier("PurchaseSegue", sender: self)
        } else {
            if UserSession.sharedSession.isSignedIn {
                self.performSegueWithIdentifier("SavedSegue", sender: self)
            } else {
                self.performSegueWithIdentifier("AccountsSegue", sender: self)
            }
        }
    }
    
    @IBAction func loginButtonTapped(sender: AnyObject) {
        if !SettingsManager.defaultManager.purchased {
            self.performSegueWithIdentifier("PurchaseSegue", sender: self)
        } else {
            self.performSegueWithIdentifier("AccountsSegue", sender: self)
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if identifier == "SubredditPosts" && UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            if let controller = self.splitViewController?.viewControllers[1] as? NavBarController {
                if let subredditViewController = controller.viewControllers[0] as? SubredditViewController {
                    if let cell = sender as? UITableViewCell {
                        
                        var indexPath: NSIndexPath = self.tableView.indexPathForCell(cell)!
                        
                        if indexPath.section == 0 {
                            if indexPath.row != 0 {
                                if let subreddit = self.multiSubreddits[indexPath.row - 1] as? RKMultireddit {
                                    subredditViewController.multiReddit = subreddit
                                    subredditViewController.front = false
                                }
                            }
                        } else {
                            if indexPath.row != 0 {
                                if let subreddit = self.subreddits[indexPath.row - 1] as? RKSubreddit {
                                    subredditViewController.subreddit = subreddit
                                    subredditViewController.front = false
                                }
                            }
                        }
                    }
                }
            }
            return false
        }
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SubredditPosts" {
            if let controller = segue.destinationViewController as? NavBarController {
                if let subredditViewController = controller.viewControllers[0] as? SubredditViewController {
                    if let cell = sender as? UITableViewCell {
                        
                        var indexPath: NSIndexPath = self.tableView.indexPathForCell(cell)!
                        
                        if indexPath.section == 0 {
                            if indexPath.row != 0 {
                                if let subreddit = self.multiSubreddits[indexPath.row - 1] as? RKMultireddit {
                                    subredditViewController.multiReddit = subreddit
                                    subredditViewController.front = false
                                }
                            }
                        } else {
                            if indexPath.row != 0 {
                                if let subreddit = self.subreddits[indexPath.row - 1] as? RKSubreddit {
                                    subredditViewController.subreddit = subreddit
                                    subredditViewController.front = false
                                }
                            }
                        }
                    }
                }
            }
        } else if segue.identifier == "SavedSegue" {
            if let nav = segue.destinationViewController as? UINavigationController {
                if let controller = nav.viewControllers[0] as? UserContentViewController {
                    controller.category = .Saved
                    controller.categoryTitle = "Saved"
                    controller.user = RKClient.sharedClient().currentUser
                }
            }
        }
    }
}