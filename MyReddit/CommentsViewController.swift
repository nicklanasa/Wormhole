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
    var optionsController: LinkShareOptionsViewController!
    
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
            self.commentsBySection = self.buildCommentsBySection()
            self.navigationItem.title =  "\(self.link.totalComments) comments"
        }
    }
    
    private func buildCommentsBySection() -> [NSDictionary] {
        
        var comments = [NSDictionary]()
        
        for comment in self.comments as! [RKComment] {
            comments.append(["comment" : comment, "level" : 0])
            var dictionary = self.repliesForComment(comment, level: 1)
            comments.extend(dictionary)
        }
        
        return comments
    }
    
    private func repliesForComment(comment: RKComment, level: Int) -> [NSDictionary] {
        var replies = [NSDictionary]()
        
        for reply in comment.replies as! [RKComment] {
            replies.append(["comment" : reply, "level" : level])
            replies.extend(self.repliesForComment(reply, level: level + 1))
        }
        
        return replies
    }
    
    var commentsBySection: [AnyObject]? {
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.syncComments()
        
        self.navigationItem.title =  "\(self.link.totalComments) comments"
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.navigationController?.navigationBar.tintColor = MyRedditLabelColor
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: MyRedditLabelColor]
        
        self.tableView.backgroundColor = MyRedditBackgroundColor
        
        self.tableView.tableFooterView = UIView()
    }
    
    func syncComments() {
        self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        RedditSession.sharedSession.fetchComments(nil, link: self.link) { (pagination, results, error) -> () in
            self.comments = results
            self.refreshCommentsControl.endRefreshing()
            self.hud.hide(true)
        }
    }
    
    @IBAction func filterButtonTapped(sender: AnyObject) {
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
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 107
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1 + (self.commentsBySection?.count ?? 0)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("CommentCell") as! CommentCell

        var comment: RKComment!
        
        if indexPath.section == 0 {
            if (self.link.isImageLink() || self.link.media != nil || self.link.domain == "imgur.com") && !SettingsManager.defaultManager.valueForSetting(.FullWidthImages)  {
                var imageCell = tableView.dequeueReusableCellWithIdentifier("PostImageCell") as! PostImageCell
                imageCell.link = self.link
                imageCell.delegate = self
                return imageCell
            } else {
                cell.link = self.link
            }
        } else {
            
            var commentDictionary = self.self.commentsBySection?[indexPath.section - 1] as! [String : AnyObject]
            cell.indentationLevel = commentDictionary["level"] as! Int
            cell.indentationWidth = 10
            comment = commentDictionary["comment"] as! RKComment
            
            cell.configueForComment(comment: comment,
                isLinkAuthor: self.link.author == comment.author)
            
            cell.separatorInset = UIEdgeInsets(top: 0,
                left: CGFloat(cell.indentationLevel) * cell.indentationWidth,
                bottom: 0,
                right: 0)
        }
        
        cell.delegate = self
        cell.commentDelegate = self
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "AddCommentSegue" {
            if let nav = segue.destinationViewController as? UINavigationController {
                if let controller = nav.viewControllers[0] as? AddCommentViewController {
                    
                    if let replyComment = sender as? RKComment {
                        controller.comment = replyComment
                    } else {
                        controller.link = self.link
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
                    
                    if indexPath.section == 0 {
                        votedable = self.link
                    } else {
                        var commentDictionary = self.self.commentsBySection?[indexPath.section - 1] as! [String : AnyObject]
                        votedable = commentDictionary["comment"] as! RKComment
                    }
                    
                    if let object = votedable {
                        
                        if swipeType.value == JZSwipeTypeShortRight.value {
                            self.downVote(object)
                        } else if swipeType.value == JZSwipeTypeShortLeft.value {
                            self.upVote(object)
                        } else if swipeType.value == JZSwipeTypeLongLeft.value {
                            if indexPath.section != 0 {
                                self.performSegueWithIdentifier("AddCommentSegue",
                                    sender: object)
                            } else {
                                self.saveUnSaveLink(cell)
                            }
                        } else {
                            if indexPath.section != 0 {
                                self.downVote(object)
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
    
    private func saveUnSaveLink(sourceView: UIView) {
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
            popoverController.sourceView = sourceView
            popoverController.sourceRect = sourceView.bounds
        }
        
        alertController.present(animated: true, completion: nil)
    }
    
    private func upVote(object: RKVotable) {
        RedditSession.sharedSession.upvote(object, completion: { (error) -> () in
            self.hud.hide(true)
            
            if error != nil {
                UIAlertView(title: "Error!",
                    message: error!.localizedDescription,
                    delegate: self,
                    cancelButtonTitle: "Ok").show()
            } else {
                LocalyticsSession.shared().tagEvent("Swipe upvote comment")
                self.tableView.reloadData()
            }
        })
    }
    
    private func downVote(object: RKVotable) {
        RedditSession.sharedSession.downvote(object, completion: { (error) -> () in
            self.hud.hide(true)
            
            if error != nil {
                UIAlertView(title: "Error!",
                    message: error!.localizedDescription,
                    delegate: self,
                    cancelButtonTitle: "Ok").show()
            } else {
                LocalyticsSession.shared().tagEvent("Swipe downvote comment")
                self.tableView.reloadData()
            }
        })
    }
    
    func addCommentViewController(controller: AddCommentViewController, didAddComment success: Bool) {
        
        self.hud.hide(true)
        
        if success {
            LocalyticsSession.shared().tagEvent("Added comment")
            
            RedditSession.sharedSession.fetchComments(nil, link: self.link) { (pagination, results, error) -> () in
                self.comments = results
            }
        } else {
            LocalyticsSession.shared().tagEvent("Add comment failed")
        }
    }
    
    @IBAction func shareButtonTapped(sender: AnyObject) {
        var linkOptions = LinkShareOptionsViewController(link: self.link)
        linkOptions.barbuttonItem = self.shareButton
        linkOptions.showInView(self.view)
    }
}