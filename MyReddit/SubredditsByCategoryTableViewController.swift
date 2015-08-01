//
//  SubredditsByCategoryTableViewController.swift
//  MyReddit
//
//  Created by Nickolas Lanasa on 7/31/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import UIKit

class SubredditsByCategoryTableViewController: RootTableViewController {
    
    var category: String!
    
    var subreddits: [String]? {
        didSet {
            self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        RedditSession.sharedSession.subredditsForCategory(self.category, completion: { (pagination, results, error) -> () in
            if let subreddits = results as? [String] {
                self.subreddits = subreddits
            } else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    UIAlertView(title: "Error!",
                        message: error?.localizedDescription,
                        delegate: self,
                        cancelButtonTitle: "OK").show()
                })
            }
        })
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.subreddits?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("SubredditCategoryCell") as! SubredditCell
        var subreddit = self.subreddits?[indexPath.row]
        cell.nameLabel.text = subreddit
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        RedditSession.sharedSession.subredditWithSubredditName(self.subreddits![indexPath.row],
            completion: { (pagination, results, error) -> () in
            
            if let subreddits = results as? [RKSubreddit] {
                var foundSubreddit: RKSubreddit?
                
                for subreddit in subreddits {
                    if subreddit.name.lowercaseString == self.subreddits![indexPath.row].lowercaseString {
                        foundSubreddit = subreddit
                        break
                    }
                }
                
                if foundSubreddit == nil {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        UIAlertView(title: "Error!",
                            message: error?.localizedDescription,
                            delegate: self,
                            cancelButtonTitle: "OK").show()
                    })
                } else {
                    self.performSegueWithIdentifier("SubredditPostsSegue", sender: foundSubreddit)
                }
            } else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    UIAlertView(title: "Error!",
                        message: error?.localizedDescription,
                        delegate: self,
                        cancelButtonTitle: "OK").show()
                })
            }
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let controller = segue.destinationViewController as? NavBarController {
            if let subredditViewController = controller.viewControllers[0] as? SubredditViewController {
                if let subreddit = sender as? RKSubreddit {
                    subredditViewController.subreddit = subreddit
                    subredditViewController.front = false
                }
            }
        }
    }
}
