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

class SubredditsViewController: UIViewController,
UITableViewDataSource,
UITableViewDelegate,
NSFetchedResultsControllerDelegate,
UISearchDisplayDelegate,
UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var savedButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    var foundSubreddit: RKSubreddit? {
        didSet {
            self.performSegueWithIdentifier("SubredditPosts", sender: self.foundSubreddit)
        }
    }
    
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
    
    var refreshControl = MyRedditRefreshControl()

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
            
            self.tableView.reloadSections(NSIndexSet(index: 2), withRowAnimation: .None)
            
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
            
            self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .None)
            
            let subredditsData = NSKeyedArchiver.archivedDataWithRootObject(self.multiSubreddits)
            
            NSUserDefaults.standardUserDefaults().setObject(subredditsData, forKey: "multiSubreddits")
            
            LocalyticsSession.shared().tagEvent("Updated multireddits")
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        RedditSession.sharedSession.searchForSubredditByName(searchBar.text, pagination: nil) { (pagination, results, error) -> () in
            if let subreddits = results as? [RKSubreddit] {
                for subreddit in subreddits {
                    if subreddit.name.lowercaseString == searchBar.text.lowercaseString {
                        self.foundSubreddit = subreddit
                        break
                    }
                }
                
                if self.foundSubreddit == nil {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        UIAlertView(title: "Error!",
                            message: "Unable to find subreddit by that name.",
                            delegate: self,
                            cancelButtonTitle: "OK").show()
                    })
                }
            } else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    UIAlertView(title: "Error!",
                        message: "Unable to find subreddit by that name.", 
                        delegate: self,
                        cancelButtonTitle: "OK").show()
                })
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl.addToScrollView(self.tableView, withRefreshBlock: { () -> Void in
            self.refresh(self.tableView)
        })
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "didUpdateSubreddits",
            name: "RefreshSubreddits",
            object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.fetchSubreddits()
        
        LocalyticsSession.shared().tagScreen("Subreddits")
        
        for item in self.toolbarItems as! [UIBarButtonItem] {
            item.tintColor = MyRedditLabelColor
        }
        
        self.tableView.backgroundView = UIView()
        self.tableView.backgroundColor = MyRedditBackgroundColor
        self.view.backgroundColor = MyRedditBackgroundColor
        
        self.tableView.reloadData()
    }
    
    func didUpdateSubreddits() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.fetchSubreddits()
        })
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
        } else {
            self.multiSubreddits = Array<AnyObject>()
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
    
    func refresh(sender: AnyObject) {
        self.fetchSubreddits()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 4
        }
        
        if section == 1 {
            return self.multiSubreddits.count + 1
        }
        return self.subreddits.count + 2
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("SubredditCell") as! SubredditCell
        
        if indexPath.section == 0 {
            var cell = tableView.dequeueReusableCellWithIdentifier("ExploreCell") as! ExploreCell
            cell.configureWithType(ExploreCellType(rawValue: indexPath.row)!)
            return cell
        } else if indexPath.section == 1 {
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
            } else if indexPath.row == 1 {
                var cell = tableView.dequeueReusableCellWithIdentifier("AllCell") as! FrontCell
                cell.frontLabel.textColor = MyRedditLabelColor
                
                if SettingsManager.defaultManager.valueForSetting(.NightMode) {
                    cell.starImageView.image = UIImage(named: "starWhite")
                } else {
                    cell.starImageView.image = UIImage(named: "Star")
                }
                
                return cell
            } else {
                if let subreddit = self.subreddits[indexPath.row - 2] as? RKSubreddit {
                    cell.rkSubreddit = subreddit
                }
            }
        }

        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.row == 0 || (indexPath.row == 1 && indexPath.section == 2) || indexPath.section == 0 {
            return false
        }
        
        if UserSession.sharedSession.isSignedIn {
            return true
        } else {
            return false
        }
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        if indexPath.section == 0 {
            return .None
        }
        
        if indexPath.row == 0 {
            return .None
        } else if indexPath.row == 1 && indexPath.section == 2 {
            return .None
        }
        return .Delete
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {

    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        if indexPath.section != 0 && indexPath.row != 0 {
            let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default,
                title: "delete",
                handler: { (action, indexPath) -> Void in
                    if indexPath.section == 1 {
                        if let multiReddit = self.multiSubreddits[indexPath.row - 1] as? RKMultireddit {
                            RedditSession.sharedSession.deleteMultiReddit(multiReddit, completion: { (error) -> () in
                                if error != nil {
                                    UIAlertView(title: "Error!",
                                        message: "Unable to delete MultiReddit! Please make sure you're connected to the internets.",
                                        delegate: self,
                                        cancelButtonTitle: "Ok").show()
                                    LocalyticsSession.shared().tagEvent("Delete multireddit failed")
                                } else {
                                    self.multiSubreddits.removeAtIndex(indexPath.row - 1)
                                    LocalyticsSession.shared().tagEvent("Deleted multireddit")
                                }
                            })
                        }
                    } else if indexPath.section == 2 {
                        if let subreddit = self.subreddits[indexPath.row - 2] as? RKSubreddit {
                            RedditSession.sharedSession.unsubscribe(subreddit, completion: { (error) -> () in
                                if error != nil {
                                    UIAlertView(title: "Error!",
                                        message: "Unable to unsubscribe to Subreddit! Please make sure you're connected to the internets.",
                                        delegate: self,
                                        cancelButtonTitle: "Ok").show()
                                    LocalyticsSession.shared().tagEvent("Subreddit Unsubscribe failed")
                                } else {
                                    self.subreddits.removeAtIndex(indexPath.row - 2)
                                    LocalyticsSession.shared().tagEvent("Subreddit unsubscribe")
                                }
                            })
                        }
                    }
            })
            
            if indexPath.section == 1 {
                let editAction = UITableViewRowAction(style: UITableViewRowActionStyle.Normal,
                    title: "edit",
                    handler: { (action, indexPath) -> Void in
                    if let multiReddit = self.multiSubreddits[indexPath.row - 1] as? RKMultireddit {
                        self.performSegueWithIdentifier("EditMultiRedditSegue",
                            sender: multiReddit)
                    }
                })
                
                return [deleteAction, editAction]
            }
            
            return [deleteAction]
        }
        
        return nil
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "explore"
        }
        
        if section == 1 {
            return "multireddits"
        }
        
        if UserSession.sharedSession.isSignedIn {
            return "subscribed"
        } else {
            return "popular"
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                if !SettingsManager.defaultManager.purchased {
                    self.performSegueWithIdentifier("PurchaseSegue", sender: self)
                } else {
                    if UserSession.sharedSession.isSignedIn {
                        self.showMultiRedditDialog()
                    } else {
                        self.performSegueWithIdentifier("AccountsSegue", sender: self)
                    }
                }
            }
        } else if indexPath.section == 0 {
            if let type = ExploreCellType(rawValue: indexPath.row) {
                switch type {
                case .Manual:
                    self.showManualSubredditDialog()
                case .FindUser:
                    self.showFindUserDialog()
                case .MyReddit:
                    self.showMyRedditSubreddit()
                case .Discover:
                    self.performSegueWithIdentifier("SubredditsCategoriesSegue", sender: self)
                default: break
                }
            }
        }
    }
    
    func showMyRedditSubreddit() {
        RedditSession.sharedSession.searchForSubredditByName("myreddit_app", pagination: nil) { (pagination, results, error) -> () in
            if let subreddits = results as? [RKSubreddit] {
                for subreddit in subreddits {
                    if subreddit.name.lowercaseString == "myreddit_app".lowercaseString {
                        self.foundSubreddit = subreddit
                        break
                    }
                }
                
                if self.foundSubreddit == nil {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        UIAlertView(title: "Error!",
                            message: "Unable to find subreddit by that name.",
                            delegate: self,
                            cancelButtonTitle: "OK").show()
                    })
                }
            } else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    UIAlertView(title: "Error!",
                        message: "Unable to find subreddit by that name.",
                        delegate: self,
                        cancelButtonTitle: "OK").show()
                })
            }
        }
    }
    
    func showFindUserDialog() {
        var alert = UIAlertController(title: "Find User",
            message: "Please enter the username of the user.",
            preferredStyle: .Alert)
        
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in })
        
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action) -> Void in
            if let textfield = alert.textFields?.first as? UITextField {
                
                var username = textfield.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                
                if count(username) == 0 {
                    UIAlertView(title: "Error!",
                        message: "You must enter in a username!",
                        delegate: self,
                        cancelButtonTitle: "Ok").show()
                } else {
                    RedditSession.sharedSession.searchForUser(username, completion: { (pagination, results, error) -> () in
                        if let user = results?.first as? RKUser {
                            self.performSegueWithIdentifier("UserSegue", sender: user)
                        } else {
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                UIAlertView(title: "Error!",
                                    message: "Unable to find subreddit by that name.",
                                    delegate: self,
                                    cancelButtonTitle: "OK").show()
                            })
                        }
                    })
                }
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func showManualSubredditDialog() {
        var alert = UIAlertController(title: "Find Subreddit",
            message: "Please enter the subreddit name.", 
            preferredStyle: .Alert)
        
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in })
        
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action) -> Void in
            if let textfield = alert.textFields?.first as? UITextField {
                
                var subredditName = textfield.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                
                if count(subredditName) == 0 {
                    UIAlertView(title: "Error!",
                        message: "You must enter in a subreddit name!",
                        delegate: self,
                        cancelButtonTitle: "Ok").show()
                } else {
                    RedditSession.sharedSession.searchForSubredditByName(subredditName, pagination: nil) { (pagination, results, error) -> () in
                        if let subreddits = results as? [RKSubreddit] {
                            for subreddit in subreddits {
                                if subreddit.name.lowercaseString == subredditName.lowercaseString {
                                    self.foundSubreddit = subreddit
                                    break
                                }
                            }
                            
                            if self.foundSubreddit == nil {
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    UIAlertView(title: "Error!",
                                        message: "Unable to find subreddit by that name.",
                                        delegate: self,
                                        cancelButtonTitle: "OK").show()
                                })
                            }
                        } else {
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                UIAlertView(title: "Error!",
                                    message: "Unable to find subreddit by that name.", 
                                    delegate: self,
                                    cancelButtonTitle: "OK").show()
                            })
                        }
                    }
                }
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func showMultiRedditDialog() {
        var alert = UIAlertController(title: "New", message: "Please enter the multireddit name.", preferredStyle: .Alert)
        
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            
        })
        
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action) -> Void in
            if let textfield = alert.textFields?.first as? UITextField {
                
                var multiRedditName = textfield.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: " "))
                
                if count(multiRedditName) == 0 || multiRedditName.componentsSeparatedByString(" ").count > 1 {
                    UIAlertView(title: "Error!", message: "You must enter in a valid multireddit name! Make sure it doesn't have any spaces in it.", delegate: self, cancelButtonTitle: "Ok").show()
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
                            })
                        }))
                        
                        visibilityAlert.addAction(UIAlertAction(title: "Private", style: .Default, handler: { (a) -> Void in
                            LocalyticsSession.shared().tagEvent("Created private multireddit")
                            RedditSession.sharedSession.createMultiReddit(multiRedditName, visibility: .Private, completion: { (error) -> () in
                                self.syncMultiReddits()
                            })
                        }))
                        
                        self.presentViewController(visibilityAlert, animated: true, completion: nil)
                    }
                }
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
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
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SubredditPosts" {
            if let controller = segue.destinationViewController as? NavBarController {
                if let subredditViewController = controller.viewControllers[0] as? SubredditViewController {
                    if let cell = sender as? UITableViewCell {
                        
                        var indexPath: NSIndexPath = self.tableView.indexPathForCell(cell)!
                        
                        if indexPath.section == 1 {
                            if indexPath.row != 0 {
                                if let subreddit = self.multiSubreddits[indexPath.row - 1] as? RKMultireddit {
                                    subredditViewController.multiReddit = subreddit
                                    subredditViewController.front = false
                                }
                            }
                        } else {
                            if indexPath.row != 0 {
                                if let subreddit = self.subreddits[indexPath.row - 2] as? RKSubreddit {
                                    subredditViewController.subreddit = subreddit
                                    subredditViewController.front = false
                                }
                            }
                        }
                        
                        self.toggleMaster()
                    } else {
                        if let subreddit = sender as? RKSubreddit {
                            subredditViewController.subreddit = subreddit
                            subredditViewController.front = false
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
                    
                    self.toggleMaster()
                }
            }
        } else if segue.identifier == "AccountsSegue" {
            self.toggleMaster()
        } else if segue.identifier == "FrontSegue" {
            self.toggleMaster()
        } else if segue.identifier == "AllSegue" {
            if let controller = segue.destinationViewController as? NavBarController {
                if let subredditViewController = controller.viewControllers[0] as? SubredditViewController {
                    subredditViewController.front = false
                    subredditViewController.all = true
                    self.toggleMaster()
                }
            }
        } else if segue.identifier == "UserSegue" {
            if let controller = segue.destinationViewController as? ProfileViewController {
                if let user = sender as? RKUser {
                    controller.user = user
                    self.toggleMaster()
                }
            }
        } else if segue.identifier == "EditMultiRedditSegue" {
            if let controller = segue.destinationViewController as? EditMultiRedditTableViewController {
                if let multireddit = sender as? RKMultireddit {
                    controller.multireddit = multireddit
                    self.toggleMaster()
                }
            }
        }
    }
    
    private func toggleMaster() {
        if let splitViewController = self.splitViewController {
            let barButtonItem = splitViewController.displayModeButtonItem()
            UIApplication.sharedApplication().sendAction(barButtonItem.action,
                to: barButtonItem.target,
                from: nil,
                forEvent: nil)
        }
    }
}