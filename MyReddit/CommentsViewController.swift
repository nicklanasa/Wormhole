//
//  CommentsViewController.swift
//  MyReddit
//
//  Created by Nickolas Lanasa on 4/27/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation
import UIKit

class CommentsViewController: UITableViewController, CommentCellDelegate, JZSwipeCellDelegate, UITextFieldDelegate, AddCommentViewControllerDelegate {
    
    var link: RKLink!
    var comment: RKComment!
    
    var forComment = false
        
    var comments: [AnyObject]? {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    var hud: MBProgressHUD! {
        didSet {
            hud.labelFont = MyRedditSelfTextFont
            hud.mode = .Indeterminate
            hud.labelText = "Loading"
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.syncComments()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    lazy var refreshCommentsControl: UIRefreshControl! = {
        var control = UIRefreshControl()
        control.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes: [NSFontAttributeName : MyRedditCommentTextBoldFont, NSForegroundColorAttributeName : MyRedditLabelColor])
        control.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        return control
    }()
    
    func refresh(sender: AnyObject)
    {
        self.syncComments()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !self.forComment {
            self.refreshControl = self.refreshCommentsControl
        }
        
        self.navigationItem.title =  !self.forComment ? "\(self.link.author) | \(self.link.totalComments) comments" : "\(self.comment.author) | \(self.comment.replies.count) replies"
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.navigationController?.navigationBar.tintColor = MyRedditLabelColor
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: MyRedditLabelColor]
        
        self.tableView.backgroundColor = MyRedditBackgroundColor
        
        if self.forComment {
            if self.comment.replies.count == 0 {
                self.performSegueWithIdentifier("AddCommentSegue", sender: self)
            }
        }
        
        self.tableView.tableFooterView = UIView()
    }
    
    func syncComments() {
        if !self.forComment {
            RedditSession.sharedSession.fetchComments(nil, link: self.link) { (pagination, results, error) -> () in
                self.comments = results
                self.refreshCommentsControl.endRefreshing()
            }
        }
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 107
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.forComment {
            return self.comment.replies?.count ?? 0
        }
        
        if let comments = self.comments {
            return comments.count + 1
        }
        
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("CommentCell") as! CommentCell

        var comment: RKComment!
        
        if self.forComment {
            comment = self.comment.replies?[indexPath.row] as! RKComment
            cell.comment = comment
        } else {
            if indexPath.row == 0 {
                cell.link = self.link
            } else {
                comment = self.comments?[indexPath.row - 1] as! RKComment
                cell.comment = comment
            }
        }
        
        cell.delegate = self
        
        cell.commentDelegate = self
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if identifier == "RepliesSegue" {
            if let cell = sender as? CommentCell {
                var indexPath: NSIndexPath = self.tableView.indexPathForCell(cell)!
                
                if indexPath.row == 0 && !self.forComment {
                    return false
                }
            }
        }
        
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "RepliesSegue" {
            if let controller = segue.destinationViewController as? CommentsViewController {
                if let cell = sender as? CommentCell {
                    var indexPath: NSIndexPath = self.tableView.indexPathForCell(cell)!
                    
                    if !self.forComment {
                        controller.comment = self.comments?[indexPath.row - 1] as! RKComment
                    } else {
                        controller.comment = self.comment.replies?[indexPath.row] as! RKComment
                    }
                    
                    controller.forComment = true
                    controller.link = self.link
                }
            }
        } else if segue.identifier == "AddCommentSegue" {
            if let nav = segue.destinationViewController as? UINavigationController {
                if let controller = nav.viewControllers[0] as? AddCommentViewController {
                    if self.forComment {
                        if let replyComment = sender as? RKComment {
                            controller.comment = replyComment
                        } else {
                            controller.comment = self.comment
                        }
                    } else {
                        if let replyComment = sender as? RKComment {
                            controller.comment = replyComment
                        } else {
                            controller.link = self.link
                        }
                    }
                    
                    controller.delegate = self
                }
            }
        } else {
            if let nav = segue.destinationViewController as? UINavigationController {
                if let controller = nav.viewControllers[0] as? WebViewController {
                    controller.url = sender as! NSURL
                }
            }
        }
    }
    
    @IBAction func addCommentButtonTapped(sender: AnyObject) {
        if NSUserDefaults.standardUserDefaults().objectForKey("purchased") == nil {
            self.performSegueWithIdentifier("PurchaseSegue", sender: self)
        } else {
            self.performSegueWithIdentifier("AddCommentSegue", sender: self)
        }
    }
    
    func commentCell(cell: CommentCell, didTapLink link: NSURL) {
        self.performSegueWithIdentifier("CommentLinkSegue", sender: link)
    }
   
    func swipeCell(cell: JZSwipeCell!, triggeredSwipeWithType swipeType: JZSwipeType) {
        if swipeType.value != JZSwipeTypeNone.value {
            cell.reset()
            if NSUserDefaults.standardUserDefaults().objectForKey("purchased") == nil {
                self.performSegueWithIdentifier("PurchaseSegue", sender: self)
            } else {
                
                self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                
                if let indexPath = self.tableView.indexPathForCell(cell) {
                    
                    var votedable: RKVotable?
                    
                    if self.forComment {
                        votedable = self.comment.replies?[indexPath.row] as? RKComment
                    } else {
                        if indexPath.row == 0 {
                            votedable = self.link
                        } else {
                            votedable = self.comments?[indexPath.row - 1] as? RKComment
                        }
                    }
                    
                    if let object = votedable {
                        if swipeType.value == JZSwipeTypeShortRight.value || swipeType.value == JZSwipeTypeLongRight.value {
                            // Downvote
                            RedditSession.sharedSession.downvote(object, completion: { (error) -> () in
                                self.hud.hide(true)
                                
                                if error != nil {
                                    UIAlertView(title: "Error!",
                                        message: "Unable to downvote! Please try again!",
                                        delegate: self,
                                        cancelButtonTitle: "Ok").show()
                                } else {
                                    self.tableView.reloadData()
                                }
                            })
                        } else if swipeType.value == JZSwipeTypeShortLeft.value {
                            // Upvote
                            RedditSession.sharedSession.upvote(object, completion: { (error) -> () in
                                self.hud.hide(true)
                                
                                if error != nil {
                                    UIAlertView(title: "Error!",
                                        message: "Unable to upvote! Please try again!",
                                        delegate: self,
                                        cancelButtonTitle: "Ok").show()
                                } else {
                                    self.tableView.reloadData()
                                }
                            })
                        } else if swipeType.value == JZSwipeTypeLongLeft.value {
                            
                            var comment: RKComment!
                            
                            if self.forComment {
                                comment = self.comment.replies?[indexPath.row] as? RKComment
                            } else {
                                if indexPath.row == 0 {
                                    self.performSegueWithIdentifier("AddCommentSegue", sender: self)
                                } else {
                                    comment = self.comments?[indexPath.row - 1] as? RKComment
                                }
                            }
                            
                            self.performSegueWithIdentifier("AddCommentSegue", sender: comment)
                        } else {
                            self.hud.hide(true)
                        }
                    }
                }
            }
        }
    }
    
    func swipeCell(cell: JZSwipeCell!, swipeTypeChangedFrom from: JZSwipeType, to: JZSwipeType) {

    }
    
    func addCommentViewController(controller: AddCommentViewController, didAddComment success: Bool) {
        if success {
            if !self.forComment {
                RedditSession.sharedSession.fetchComments(nil, link: self.link) { (pagination, results, error) -> () in
                    
                    if let comments = results {
                        self.comments = comments
                    }
                }
            } else {
                RedditSession.sharedSession.fetchComments(nil, link: self.link) { (pagination, results, error) -> () in
                    if let comments = results {
                        self.findCurrentCommentInComments(comments)
                    }
                }
            }
        }
    }
    
    private func findCurrentCommentInComments(comments: [AnyObject]) {
        for comment in comments as! [RKComment] {
            
            if self.comment.fullName == comment.fullName {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.comment = comment
                    self.tableView.reloadData()
                    
                    self.navigationItem.title =  !self.forComment ? "\(self.link.author) | \(self.link.totalComments) comments" : "\(self.comment.author) | \(self.comment.replies.count) replies"
                })
            }
            
            if comment.replies.count > 0 {
                self.findCurrentCommentInComments(comment.replies)
            }
        }
    }
}