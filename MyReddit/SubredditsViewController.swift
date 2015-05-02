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

class SubredditsViewController: UIViewController, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
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
            
            self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .None)
            
            let subredditsData = NSKeyedArchiver.archivedDataWithRootObject(self.subreddits)
            
            NSUserDefaults.standardUserDefaults().setObject(subredditsData, forKey: "subreddits")
        }
    }
    
    var syncSubreddits = Array<AnyObject>()
    
    @IBOutlet weak var tableView: UITableView!

    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.modalTransitionStyle = .CrossDissolve
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func editButtonTApped(sender: AnyObject) {
        self.tableView.setEditing(true, animated: true)
        
        if let barButton = sender as? UIBarButtonItem {
            barButton.action = "finishEditing:"
            barButton.title = "Done"
        }
    }
    
    func finishEditing(sender: AnyObject) {
        self.tableView.setEditing(false, animated: true)
        
        if let barButton = sender as? UIBarButtonItem {
            barButton.action = "editButtonTApped:"
            barButton.title = "Edit"
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let subredditsData = NSUserDefaults.standardUserDefaults().objectForKey("subreddits") as? NSData {
            if let subreddits = NSKeyedUnarchiver.unarchiveObjectWithData(subredditsData) as? [RKSubreddit] {
                self.subreddits = subreddits
            }
        }
        
        self.fetchSubreddits()
    }
    
    func fetchSubreddits() {
       self.syncSubreddits(nil)
    }
    
    func syncSubreddits(pagination: RKPagination?) {
        
        if UserSession.sharedSession.isSignedIn {
            RedditSession.sharedSession.fetchSubscribedSubreddits(pagination, category: .Subscriber, completion: { (pagination, results, error) -> () in
                if let subreddits = results {
                    self.syncSubreddits.extend(subreddits)
                    if pagination != nil {
                        self.syncSubreddits(pagination)
                    } else {
                        self.subreddits = self.syncSubreddits
                    }
                }
            })
        } else {
            RedditSession.sharedSession.fetchPopularSubreddits(pagination, completion: { (pagination, results, error) -> () in
                if let subreddits = results {
                    self.subreddits = subreddits
                }
            })
        }
    }
    
    // MARK: Sectors NSFetchedResultsControllerDelegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.subreddits.count + 1
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("SubredditCell") as! SubredditCell
        
        if indexPath.row == 0 {
            return tableView.dequeueReusableCellWithIdentifier("FrontCell") as! UITableViewCell
        } else {
            if let subreddit = self.subreddits[indexPath.row - 1] as? RKSubreddit {
                cell.rkSubreddit = subreddit
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
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            if let subreddit = self.subreddits[indexPath.row - 1] as? RKSubreddit {
                RedditSession.sharedSession.unsubscribe(subreddit, completion: { (error) -> () in
                    if error != nil {
                        UIAlertView(title: "Error!", message: "Unable to unsubscribe to Subreddit! Please make sure you're connected to the internets.", delegate: self, cancelButtonTitle: "Ok").show()
                    } else {
                        self.subreddits.removeAtIndex(indexPath.row-1)
                        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                    }
                })
            }
        }
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default,
            title: "Delete",
            handler: { (action, indexPath) -> Void in
                
        })
        
        return [deleteAction]
    }
    
    @IBAction func messagesButtonTapped(sender: AnyObject) {
        if NSUserDefaults.standardUserDefaults().objectForKey("purchased") == nil {
            self.performSegueWithIdentifier("PurchaseSegue", sender: self)
        } else {
            self.performSegueWithIdentifier("MessagesSegue", sender: self)
        }
    }
    
    @IBAction func loginButtonTapped(sender: AnyObject) {
//        if NSUserDefaults.standardUserDefaults().objectForKey("purchased") == nil {
//            self.performSegueWithIdentifier("PurchaseSegue", sender: self)
//        } else {
//            if UserSession.sharedSession.isSignedIn {
//                self.performSegueWithIdentifier("ProfileSegue", sender: self)
//            } else {
//                self.performSegueWithIdentifier("LoginSegue", sender: self)
//            }
//        }
        
        if UserSession.sharedSession.isSignedIn {
            self.performSegueWithIdentifier("ProfileSegue", sender: self)
        } else {
            self.performSegueWithIdentifier("LoginSegue", sender: self)
        }

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SubredditPosts" {
            if let controller = segue.destinationViewController as? NavBarController {
                if let subredditViewController = controller.viewControllers[0] as? SubredditViewController {
                    if let cell = sender as? UITableViewCell {
                        
                        var indexPath: NSIndexPath = self.tableView.indexPathForCell(cell)!
                        
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
    }
}