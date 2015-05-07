//
//  SubredditSearchViewController.swift
//  MyReddit
//
//  Created by Nick Lanasa on 5/1/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation
import UIKit

protocol SearchViewControllerDelegate {
    func searchViewController(controller: SearchViewController, didTapSubreddit subreddit: RKSubreddit)
}

class SearchViewController: UIViewController,
UITableViewDelegate,
UITableViewDataSource,
UISearchResultsUpdating,
UISearchDisplayDelegate,
UISearchBarDelegate,
JZSwipeCellDelegate,
MultiRedditsViewControllerDelegate {
    
    var delegate: SearchViewControllerDelegate?
    var pagination: RKPagination?
    
    var multiReddit: RKMultireddit!
    var subreddit: RKSubreddit!
    var selectedSubreddit: RKSubreddit!
    var isFiltering = false
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentationControl: UISegmentedControl!
    @IBOutlet weak var restrictToSubredditSwitch: UIBarButtonItem!
    @IBOutlet weak var restrictSubreddit: UISwitch!
    
    var subreddits = Array<AnyObject>() {
        didSet {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
            })
        }
    }
    
    var links = Array<AnyObject>() {
        didSet {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
            })
        }
    }
    
    var users = Array<AnyObject>() {
        didSet {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
            })
        }
    }
    
    var hud: MBProgressHUD! {
        didSet {
            hud.labelFont = MyRedditSelfTextFont
            hud.mode = .Indeterminate
            hud.labelText = "Loading"
        }
    }
    
    lazy var searchController: UISearchController = {
        var controller = UISearchController(searchResultsController: nil)
        controller.searchResultsUpdater = self
        controller.dimsBackgroundDuringPresentation = false
        controller.searchBar.delegate = self
        controller.hidesNavigationBarDuringPresentation = false
        controller.searchBar.sizeToFit()
        controller.searchBar.searchBarStyle = .Minimal
        controller.searchBar.returnKeyType = .Done
        controller.searchBar.placeholder = "Enter subreddit name..."
        return controller
    }()
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        self.subreddits = Array<AnyObject>()
        self.links = Array<AnyObject>()
        self.tableView.reloadData()
        
        if count(searchController.searchBar.text) == 0 {
            self.isFiltering = false
            self.subreddits = Array<AnyObject>()
        } else {
            self.isFiltering = true
            self.search()
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
    }
    
    func search() {
        if self.segmentationControl.selectedSegmentIndex == 1 {
            RedditSession.sharedSession.searchForSubredditByName(searchController.searchBar.text, pagination: nil, completion: { (pagination, results, error) -> () in
                if error == nil {
                    if let subreddits = results {
                        self.subreddits = subreddits
                    }
                }
                
            })
        } else if self.segmentationControl.selectedSegmentIndex == 0 {
            if self.restrictSubreddit.on {
                if let subreddit = self.subreddit {
                    RedditSession.sharedSession.searchForLinksInSubreddit(self.subreddit, searchText: searchController.searchBar.text, pagination: self.pagination, completion: { (pagination, results, error) -> () in
                        if error == nil {
                            if let links = results {
                                self.links = links
                            }
                        }
                        
                    })
                } else {
                    RedditSession.sharedSession.searchForLinks(searchController.searchBar.text, pagination: self.pagination, completion: { (pagination, results, error) -> () in
                        if error == nil {
                            if let links = results {
                                self.links = links
                            }
                        }
                        
                    })
                }
            } else {
                RedditSession.sharedSession.searchForLinks(searchController.searchBar.text, pagination: self.pagination, completion: { (pagination, results, error) -> () in
                    if error == nil {
                        if let links = results {
                            self.links = links
                        }
                    }
                })
            }
        } else {
            RedditSession.sharedSession.searchForUser(searchController.searchBar.text.stringByReplacingOccurrencesOfString(" ", withString: "", options: nil, range: nil), completion: { (pagination, results, error) -> () in
                if error == nil {
                    if let users = results {
                        self.users = users
                    }
                }
            })
        }
    }
    
    @IBAction func segmentationControlValueChanged(sender: AnyObject) {
        if self.segmentationControl.selectedSegmentIndex == 0 {
            self.restrictToSubredditSwitch.enabled = true
            self.searchController.searchBar.placeholder = "Search for link..."
        } else if self.segmentationControl.selectedSegmentIndex == 1 {
            self.restrictToSubredditSwitch.enabled = false
            self.searchController.searchBar.placeholder = "Enter subreddit name..."
        } else {
            self.restrictToSubredditSwitch.enabled = false
            self.searchController.searchBar.placeholder = "Enter username..."
        }
        
        self.subreddits = Array<AnyObject>()
        self.links = Array<AnyObject>()
        self.tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.isFiltering = false
    }
    
    override func viewDidAppear(animated: Bool) {
        self.tableView.tableHeaderView = self.searchController.searchBar
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.backgroundColor = MyRedditBackgroundColor
        
        for subView in self.searchController.searchBar.subviews {
            if let textField = subView as? UITextField {
                textField.textColor = MyRedditLabelColor
            }
        }
        
        self.tableView.tableFooterView = UIView()
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.searchController.searchBar.becomeFirstResponder()
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let delegateObj = self.delegate as? PostTableViewController {
            self.segmentationControl.selectedSegmentIndex = 1
            self.segmentationControl.setEnabled(false, forSegmentAtIndex: 0)
            self.segmentationControl.setEnabled(false, forSegmentAtIndex: 2)
            self.searchController.active = true
        } else {
            var restrictToSubreddit: UIBarButtonItem!
            if let subreddit = self.subreddit {
                restrictToSubreddit = UIBarButtonItem(title: "/r/\(subreddit.name)", style: .Plain, target: self, action: nil)
            } else {
                restrictToSubreddit = UIBarButtonItem(title: "front", style: .Plain, target: self, action: nil)
            }
            
            self.navigationItem.rightBarButtonItems = [restrictToSubredditSwitch, restrictToSubreddit]
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.searchController.active = false
    }
    
    @IBAction func restrictToSubredditSwitchValueChanged(sender: AnyObject) {
        
    }

    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.segmentationControl.selectedSegmentIndex == 1 {
            if self.subreddits.count > 0 {
                if let searchedSubreddits = self.subreddits[0] as? Array<RKSubreddit> {
                    return searchedSubreddits.count
                }
            }
            
            return self.subreddits.count ?? 0
        } else if self.segmentationControl.selectedSegmentIndex == 0 {
            return self.links.count ?? 0
        } else {
            return self.users.count ?? 0
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if self.segmentationControl.selectedSegmentIndex == 1 {
            var cell = tableView.dequeueReusableCellWithIdentifier("SubredditCell") as! SubredditCell
            
            if let subreddit = self.subreddits[0][indexPath.row] as? RKSubreddit {
                cell.rkSubreddit = subreddit
            }
            
            return cell
        } else if self.segmentationControl.selectedSegmentIndex == 0 {
            var cell = tableView.dequeueReusableCellWithIdentifier("PostImageCell") as! PostCell
            
            if let link = self.links[indexPath.row] as? RKLink {
                if link.isImageLink() || link.media != nil || link.domain == "imgur.com" {
                    cell = tableView.dequeueReusableCellWithIdentifier("PostImageCell") as! PostImageCell
                    
                    if indexPath.row == 0 {
                        cell = tableView.dequeueReusableCellWithIdentifier("TitleCell") as! TitleCell
                    }
                    
                } else {
                    cell = tableView.dequeueReusableCellWithIdentifier("TitleCell") as! TitleCell
                }
                
                cell.link = link
            }
            
            cell.delegate = self
            
            return cell
        } else {
            var cell = tableView.dequeueReusableCellWithIdentifier("AccountCell") as! UserInfoCell
            if let user = self.users[indexPath.row] as? RKUser {
                cell.user = user
            }
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if self.segmentationControl.selectedSegmentIndex == 1 {
            if let subreddit = self.subreddits[0][indexPath.row] as? RKSubreddit {
                
                if let delegateObj = self.delegate as? PostTableViewController {
                    self.searchController.active = false
                    self.dismissViewControllerAnimated(true, completion: { () -> Void in
                        self.delegate?.searchViewController(self, didTapSubreddit: subreddit)
                    })
                } else {
                    var alert = UIAlertController(title: "Add subreddit",
                        message: "Would you like to add this subreddit to a multireddit?",
                        preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (a) -> Void in
                        self.selectedSubreddit = subreddit
                        self.searchController.active = false
                        self.performSegueWithIdentifier("MultiRedditSegue", sender: self)
                    }))
                    
                    alert.addAction(UIAlertAction(title: "See posts", style: .Cancel, handler: { (a) -> Void in
                        self.searchController.active = false
                        self.dismissViewControllerAnimated(true, completion: { () -> Void in
                            self.delegate?.searchViewController(self, didTapSubreddit: subreddit)
                        })
                    }))
                    
                    alert.present(animated: true, completion: { () -> Void in
                        
                    })
                }
            }
        } else if self.segmentationControl.selectedSegmentIndex == 0 {
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
            if indexPath.section == 0 {
                if let link = self.links[indexPath.row] as? RKLink {
                    if link.selfPost {
                        self.performSegueWithIdentifier("CommentsSegue", sender: link)
                    } else {
                        self.performSegueWithIdentifier("SubredditLink", sender: link)
                    }
                }
            }
        } else {
            if indexPath.section == 0 {
                if let user = self.users[indexPath.row] as? RKUser {
                    self.performSegueWithIdentifier("UserSegue", sender: user)
                }
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SubredditImageLink" || segue.identifier == "SubredditLink" {
            if let link = sender as? RKLink {
                if let controller = segue.destinationViewController as? LinkViewController {
                    controller.link = link
                }
            }
        } else if segue.identifier == "MultiRedditSegue" {
            if let controller = segue.destinationViewController as? UINavigationController {
                if let subredditViewController = controller.viewControllers[0] as? MultiRedditsViewController {
                    subredditViewController.delegate = self
                }
            }
        } else if segue.identifier == "UserSegue" {
            if let controller = segue.destinationViewController as? UINavigationController {
                if let profileController = controller.viewControllers[0] as? ProfileViewController {
                    if let user = sender as? RKUser {
                        profileController.user = user
                    }
                }
            }
        } else {
            if let link = sender as? RKLink {
                if let nav = segue.destinationViewController as? UINavigationController {
                    if let controller = nav.viewControllers[0] as? CommentsViewController {
                        controller.link = link
                    }
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 500
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.searchController.searchBar.resignFirstResponder()
    }
    
    func swipeCell(cell: JZSwipeCell!, triggeredSwipeWithType swipeType: JZSwipeType) {
        if swipeType.value != JZSwipeTypeNone.value {
            cell.reset()
            if !SettingsManager.defaultManager.purchased {
                self.performSegueWithIdentifier("PurchaseSegue", sender: self)
            } else {
                
                self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                
                if let indexPath = self.tableView.indexPathForCell(cell) {
                    if let link = self.links[indexPath.row] as? RKLink {
                        if swipeType.value == JZSwipeTypeShortLeft.value {
                            // Upvote
                            RedditSession.sharedSession.upvote(link, completion: { (error) -> () in
                                self.hud.hide(true)
                                
                                if error != nil {
                                    UIAlertView(title: "Error!",
                                        message: "Unable to upvote! Please try again!",
                                        delegate: self,
                                        cancelButtonTitle: "Ok").show()
                                } else {
                                    
                                }
                            })
                        } else if swipeType.value == JZSwipeTypeShortRight.value {
                            // Downvote
                            RedditSession.sharedSession.downvote(link, completion: { (error) -> () in
                                self.hud.hide(true)
                                
                                if error != nil {
                                    UIAlertView(title: "Error!",
                                        message: "Unable to downvote! Please try again!",
                                        delegate: self,
                                        cancelButtonTitle: "Ok").show()
                                } else {
                                    
                                }
                            })
                        } else if swipeType.value == JZSwipeTypeLongLeft.value {
                            // Save
                            if link.saved() {
                                RedditSession.sharedSession.unSaveLink(link, completion: { (error) -> () in
                                    self.hud.hide(true)
                                    link.unSaveLink()
                                })
                            } else {
                                RedditSession.sharedSession.saveLink(link, completion: { (error) -> () in
                                    self.hud.hide(true)
                                    link.saveLink()
                                })
                            }
                        } else {
                            // Hide
                            if link.isHidden() {
                                RedditSession.sharedSession.unHideLink(link, completion: { (error) -> () in
                                    self.hud.hide(true)
                                    link.unHideink()
                                })
                            } else {
                                RedditSession.sharedSession.hideLink(link, completion: { (error) -> () in
                                    self.hud.hide(true)
                                    link.hideLink()
                                    self.links.removeAtIndex(indexPath.row)
                                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                                    })
                                })
                            }
                        }
                    }
                }

            }
        }
    }
    
    func swipeCell(cell: JZSwipeCell!, swipeTypeChangedFrom from: JZSwipeType, to: JZSwipeType) {
        
    }
    
    func multiRedditsViewController(controller: MultiRedditsViewController, didTapMultiReddit multiReddit: RKMultireddit) {
        RedditSession.sharedSession.addSubredditToMultiReddit(multiReddit, subreddit: self.selectedSubreddit, completion: { (error) -> () in
            if error != nil {
                UIAlertView(title: "Error!",
                    message: "Unable to add subreddit to multireddit! Please check your internet connection.",
                    delegate: self,
                    cancelButtonTitle: "Ok").show()
            } else {
                UIAlertView(title: "Sucess!",
                    message: "Added subreddit!",
                    delegate: self,
                    cancelButtonTitle: "Ok").show()
            }
        })
    }
}