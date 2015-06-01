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
    
    @IBOutlet weak var filterButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    var link: RKLink!
    var comment: RKComment!
    var optionsController: LinkShareOptionsViewController!
    
    var forComment = false
    
    var filter: RKCommentSort! {
        didSet {
            self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            RedditSession.sharedSession.fetchCommentsWithFilter(filter, pagination: nil, link: self.link, completion: { (pagination, results, error) -> () in
                self.comments = results
                self.refreshCommentsControl.endRefreshing()
                self.hud.hide(true)
            })
        }
    }
        
    var comments: [AnyObject]? {
        didSet {
            self.navigationItem.title =  !self.forComment ? "\(self.link.totalComments) comments" :
            "\(self.comment.author) | \(self.comment.replies.count) replies"
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
    
    lazy var refreshCommentsControl: UIRefreshControl! = {
        var control = UIRefreshControl()
        control.attributedTitle = NSAttributedString(string: "", attributes: [NSFontAttributeName : MyRedditCommentTextBoldFont, NSForegroundColorAttributeName : MyRedditLabelColor])
        control.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        return control
    }()
    
    func refresh(sender: AnyObject)
    {
        self.syncComments()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        LocalyticsSession.shared().tagScreen("Comments")
        
        if !forComment {
            self.filterButton.enabled = true
        } else {
            self.filterButton.enabled = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !self.forComment {
            self.refreshControl = self.refreshCommentsControl
            self.navigationItem.rightBarButtonItem?.enabled = true
        } else {
            self.navigationItem.rightBarButtonItem?.enabled = false
        }
        
        self.syncComments()
        
        self.navigationItem.title =  !self.forComment ? "\(self.link.totalComments) comments" : "\(self.comment.author) | \(self.comment.replies.count) replies"
        
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
            self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            RedditSession.sharedSession.fetchComments(nil, link: self.link) { (pagination, results, error) -> () in
                self.comments = results
                self.refreshCommentsControl.endRefreshing()
                self.hud.hide(true)
            }
        }
    }
    
    @IBAction func filterButtonTapped(sender: AnyObject) {
        if !self.forComment {
            var actionSheet = UIAlertController(title: "Select sort", message: nil, preferredStyle: .ActionSheet)
            actionSheet.addAction(UIAlertAction(title: "Top", style: .Default, handler: { (action) -> Void in
                self.filter = RKCommentSort.Top
            }))
            
            actionSheet.addAction(UIAlertAction(title: "Hot", style: .Default, handler: { (action) -> Void in
                self.filter = RKCommentSort.Hot
            }))
            
            actionSheet.addAction(UIAlertAction(title: "New", style: .Default, handler: { (action) -> Void in
                self.filter = RKCommentSort.New
            }))
            
            actionSheet.addAction(UIAlertAction(title: "Controversial", style: .Default, handler: { (action) -> Void in
                self.filter = RKCommentSort.Controversial
            }))
            
            actionSheet.addAction(UIAlertAction(title: "Old", style: .Default, handler: { (action) -> Void in
                self.filter = RKCommentSort.Old
            }))
            
            actionSheet.addAction(UIAlertAction(title: "Best", style: .Default, handler: { (action) -> Void in
                self.filter = RKCommentSort.Best
            }))
            
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) -> Void in
            }))
            
            if let popoverController = actionSheet.popoverPresentationController {
                popoverController.barButtonItem = self.filterButton
            }
            
            actionSheet.present(animated: true, completion: nil)
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
                if (self.link.isImageLink() || self.link.media != nil || self.link.domain == "imgur.com") && !SettingsManager.defaultManager.valueForSetting(.FullWidthImages)  {
                    var imageCell = tableView.dequeueReusableCellWithIdentifier("PostImageCell") as! PostImageCell
                    imageCell.link = self.link
                    imageCell.delegate = self
                    return imageCell
                } else {
                    cell.link = self.link
                }
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
        if !SettingsManager.defaultManager.purchased {
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
            if !SettingsManager.defaultManager.purchased {
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
                            LocalyticsSession.shared().tagEvent("Swipe downvote comment")
                            votedable = self.comments?[indexPath.row - 1] as? RKComment
                        }
                    }
                    
                    if let object = votedable {
                        if swipeType.value == JZSwipeTypeShortRight.value {
                            // Downvote
                            LocalyticsSession.shared().tagEvent("Swipe downvote comment")
                            RedditSession.sharedSession.downvote(object, completion: { (error) -> () in
                                self.hud.hide(true)
                                
                                if error != nil {
                                    UIAlertView(title: "Error!",
                                        message: error!.localizedDescription,
                                        delegate: self,
                                        cancelButtonTitle: "Ok").show()
                                } else {
                                    self.tableView.reloadData()
                                }
                            })
                        } else if swipeType.value == JZSwipeTypeShortLeft.value {
                            // Upvote
                            LocalyticsSession.shared().tagEvent("Swipe upvote comment")
                            RedditSession.sharedSession.upvote(object, completion: { (error) -> () in
                                self.hud.hide(true)
                                
                                if error != nil {
                                    UIAlertView(title: "Error!",
                                        message: error!.localizedDescription,
                                        delegate: self,
                                        cancelButtonTitle: "Ok").show()
                                } else {
                                    self.tableView.reloadData()
                                }
                            })
                        } else if swipeType.value == JZSwipeTypeLongLeft.value {
                            if indexPath.row != 0 || self.forComment {
                                // Upvote
                                LocalyticsSession.shared().tagEvent("Swipe upvote comment")
                                RedditSession.sharedSession.upvote(object, completion: { (error) -> () in
                                    self.hud.hide(true)
                                    
                                    if error != nil {
                                        UIAlertView(title: "Error!",
                                            message: error!.localizedDescription,
                                            delegate: self,
                                            cancelButtonTitle: "Ok").show()
                                    } else {
                                        self.tableView.reloadData()
                                    }
                                })
                            } else {
                                LocalyticsSession.shared().tagEvent("Swipe more")
                                // More
                                self.hud.hide(true)
                                var alertController = UIAlertController(title: "Select option", message: nil, preferredStyle: .ActionSheet)
                                
                                if link.saved() {
                                    alertController.addAction(UIAlertAction(title: "unsave", style: .Default, handler: { (action) -> Void in
                                        RedditSession.sharedSession.unSaveLink(self.link, completion: { (error) -> () in
                                            self.hud.hide(true)
                                            self.link.unSaveLink()
                                        })
                                    }))
                                } else {
                                    alertController.addAction(UIAlertAction(title: "save", style: .Default, handler: { (action) -> Void in
                                        RedditSession.sharedSession.saveLink(self.link, completion: { (error) -> () in
                                            self.hud.hide(true)
                                            self.link.saveLink()
                                        })
                                    }))
                                }
                                
                                alertController.addAction(UIAlertAction(title: "cancel", style: .Cancel, handler: nil))
                                
                                
                                if let popoverController = alertController.popoverPresentationController {
                                    popoverController.sourceView = cell
                                    popoverController.sourceRect = cell.bounds
                                }
                                
                                alertController.present(animated: true, completion: nil)
                            }
                        } else {
                            if indexPath.row != 0 || self.forComment {
                                // Downvote
                                LocalyticsSession.shared().tagEvent("Swipe downvote comment")
                                RedditSession.sharedSession.downvote(object, completion: { (error) -> () in
                                    self.hud.hide(true)
                                    
                                    if error != nil {
                                        UIAlertView(title: "Error!",
                                            message: error!.localizedDescription,
                                            delegate: self,
                                            cancelButtonTitle: "Ok").show()
                                    } else {
                                        self.tableView.reloadData()
                                    }
                                })
                            } else {
                                LocalyticsSession.shared().tagEvent("Swipe share")
                                // Share
                                self.hud.hide(true)
                                self.optionsController = LinkShareOptionsViewController(link: link)
                                self.optionsController.sourceView = cell
                                self.optionsController.showInView(self.view)
                            }
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
            
            LocalyticsSession.shared().tagEvent("Added comment")
            
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
        } else {
            LocalyticsSession.shared().tagEvent("Add comment failed")
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
    
    @IBAction func shareButtonTapped(sender: AnyObject) {
        var linkOptions = LinkShareOptionsViewController(link: self.link)
        linkOptions.barbuttonItem = self.shareButton
        linkOptions.showInView(self.view)
    }
}