//
//  MultiRedditsViewController.swift
//  MyReddit
//
//  Created by Nick Lanasa on 5/3/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation
import UIKit

protocol MultiRedditsViewControllerDelegate {
    func multiRedditsViewController(controller: MultiRedditsViewController, didTapMultiReddit multiReddit: RKMultireddit)
}

class MultiRedditsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
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
        }
    }
    
    var syncMultiSubreddits = Array<AnyObject>()
    
    var delegate: MultiRedditsViewControllerDelegate?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        self.syncMultiSubreddits = Array<AnyObject>()
        
        if let subredditsData = NSUserDefaults.standardUserDefaults().objectForKey("multiSubreddits") as? NSData {
            if let subreddits = NSKeyedUnarchiver.unarchiveObjectWithData(subredditsData) as? [RKMultireddit] {
                self.multiSubreddits = subreddits
            }
        }

        self.tableView.backgroundColor = MyRedditDarkBackgroundColor
        
        self.syncMultiReddits()
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
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.multiSubreddits.count + 1
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("SubredditCell") as! SubredditCell
        
        if indexPath.row == 0 {
            var cell = tableView.dequeueReusableCellWithIdentifier("NewMultiRedditCell") as! UserInfoCell
            return cell
        } else {
            if let subreddit = self.multiSubreddits[indexPath.row - 1] as? RKMultireddit {
                cell.rkMultiSubreddit = subreddit
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
        if indexPath.row == 0 {
            var alert = UIAlertController(title: "New", message: "Please enter the MutliReddit's name.", preferredStyle: .Alert)
            
            alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
                
            })
            
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action) -> Void in
                if let textfield = alert.textFields?.first as? UITextField {
                    
                    var multiRedditName = textfield.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                    
                    if count(multiRedditName) == 0 || multiRedditName.componentsSeparatedByString(" ").count > 1 {
                        UIAlertView(title: "Error!", message: "You must enter a valid MultiReddit name! Please make sure it doesn't contain spaces.", delegate: self, cancelButtonTitle: "Ok").show()
                    } else {
                        
                        if count(multiRedditName) > 3 {
                            UIAlertView(title: "Error!", message: "Multireddit name is too short!", delegate: self, cancelButtonTitle: "Ok").show()
                        } else {
                            var visibilityAlert = UIAlertController(title: "Visibility", message: "Please select the visibility for the MultiReddit.", preferredStyle: .Alert)
                            visibilityAlert.addAction(UIAlertAction(title: "Public", style: .Default, handler: { (a) -> Void in
                                RedditSession.sharedSession.createMultiReddit(multiRedditName, visibility: .Public, completion: { (error) -> () in
                                    self.syncMultiReddits()
                                })
                            }))
                            
                            visibilityAlert.addAction(UIAlertAction(title: "Private", style: .Default, handler: { (a) -> Void in
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
            
            if UserSession.sharedSession.isSignedIn {
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                UIAlertView(title: "Error!",
                    message: "You must logged in to do that!",
                    delegate: self,
                    cancelButtonTitle: "Ok").show()
            }
        } else {
            if let subreddit = self.multiSubreddits[indexPath.row - 1] as? RKMultireddit {
                self.dismissViewControllerAnimated(true, completion: { () -> Void in
                    self.delegate?.multiRedditsViewController(self, didTapMultiReddit: subreddit)
                })
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
                                } else {
                                    self.multiSubreddits.removeAtIndex(indexPath.row - 1)
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
        return "MultiReddits"
    }
}