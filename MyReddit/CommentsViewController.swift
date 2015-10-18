//
//  CommentsViewController.swift
//  MyReddit
//
//  Created by Nickolas Lanasa on 4/27/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation
import UIKit

class CommentsViewController: RootTableViewController,
CommentCellDelegate,
JZSwipeCellDelegate,
UITextFieldDelegate,
AddCommentViewControllerDelegate {
    
    @IBOutlet weak var filterButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    var hiddenIndexPaths = [NSIndexPath]()
    var closedIndexPaths = [NSIndexPath]()
    var collapsedIndexPaths = [NSIndexPath]()
    
    var link: RKLink! {
        didSet {
            self.tableView.beginUpdates()
            self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Fade)
            self.tableView.endUpdates()
        }
    }
    var optionsController: LinkShareOptionsViewController!
    
    var filter: RKCommentSort! {
        didSet {
            self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            RedditSession.sharedSession.fetchCommentsWithFilter(filter,
                pagination: nil, link: self.link, completion: { (pagination, results, error) -> () in
                self.comments = results
                self.refreshControl?.endRefreshing()
                self.hud.hide(true)
            })
        }
    }
        
    var comments: [AnyObject]? {
        didSet {
            if self.comments?.count > 0 {
                self.commentsBySection = self.buildCommentsBySection()
                self.navigationItem.title =  "\(self.link.totalComments) comments"
            }
        }
    }
    
    private func buildCommentsBySection() -> [NSDictionary] {
        
        var comments = [NSDictionary]()
        
        for comment in self.comments as! [RKComment] {
            comments.append(["comment" : comment, "level" : 0])
            let dictionary = self.repliesForComment(comment, level: 1)
            comments.appendContentsOf(dictionary)
        }
        
        return comments
    }
    
    private func repliesForComment(comment: RKComment, level: Int) -> [NSDictionary] {
        var replies = [NSDictionary]()
        
        for reply in comment.replies as! [RKComment] {
            replies.append(["comment" : reply, "level" : level])
            replies.appendContentsOf(self.repliesForComment(reply, level: level + 1))
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
    
    func refresh(sender: AnyObject) {
        
        RedditSession.sharedSession.linkWithFullName(self.link, completion: { (pagination, results, error) -> () in
            if error != nil {
                UIAlertView(title: "Error!",
                    message: "Unable to get refresh link!",
                    delegate: self,
                    cancelButtonTitle: "OK").show()
            } else {
                if let link = results?.first as? RKLink {
                    self.link = link
                }
            }
        })
        
        self.syncComments()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        LocalyticsSession.shared().tagScreen("Comments")
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.navigationItem.title =  "\(self.link.totalComments) comments"
            if let _ = self.splitViewController {
                self.navigationController?.setToolbarHidden(false, animated: false)
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.syncComments()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self,
            action: "refresh:",
            forControlEvents: .ValueChanged)
        
        RedditSession.sharedSession.markLinkAsViewed(self.link,
            completion: { (error) -> () in })
        
        self.preferredAppearance()
    }
    
    func syncComments() {
        self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        RedditSession.sharedSession.fetchComments(nil, link: self.link) { (pagination, results, error) -> () in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.comments = results
                self.refreshControl?.endRefreshing()
                self.hud.hide(true)
            })
        }
    }
    
    @IBAction func filterButtonTapped(sender: AnyObject) {
        let actionSheet = UIAlertController(title: "Select sort", message: nil, preferredStyle: .ActionSheet)
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
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return self.heightForLink()
        }
        
        for closedIndexPath in self.closedIndexPaths {
            if indexPath.section == closedIndexPath.section {
                return 30
            }
        }
        
        for hiddenIndexPath in self.hiddenIndexPaths {
            if indexPath.section == hiddenIndexPath.section {
                return 0
            }
        }
        
        return self.heightForIndexPath(indexPath)
    }
    
    private func heightForLink() -> CGFloat {
        
        var selfText = ""
        
        if link.selfPost && link.selfText.characters.count > 0 {
            selfText = "\n\n\(link.selfText)".stringByReplacingOccurrencesOfString("&gt;",
                withString: ">",
                options: .CaseInsensitiveSearch,
                range: nil)
        }
        
        let parser = XNGMarkdownParser()
        parser.paragraphFont = MyRedditSelfTextFont
        parser.boldFontName = MyRedditCommentTextBoldFont.familyName
        parser.boldItalicFontName = MyRedditCommentTextItalicFont.familyName
        parser.italicFontName = MyRedditCommentTextItalicFont.familyName
        parser.linkFontName = MyRedditCommentTextBoldFont.familyName
        
        let title = link.title.stringByReplacingOccurrencesOfString("&gt;", withString: ">", options: .CaseInsensitiveSearch, range: nil)
        
        let parsedString = NSMutableAttributedString(attributedString: parser.attributedStringFromMarkdownString("\(title)\(selfText)"))
        
        let str = parsedString.string as NSString
        let rect = str.boundingRectWithSize(CGSizeMake(self.tableView.frame.size.width - 30, CGFloat.max),
            options: NSStringDrawingOptions.UsesLineFragmentOrigin,
            attributes: [NSFontAttributeName : MyRedditSelfTextFont],
            context: nil)
        return rect.height + 60
    }
    
    private func heightForIndexPath(indexPath: NSIndexPath) -> CGFloat {
        
        var commentDictionary = self.self.commentsBySection?[indexPath.section - 1] as! [String : AnyObject]
        let indentationLevel = commentDictionary["level"] as! Int
        let indentationWidth = CGFloat(15)
        let comment = commentDictionary["comment"] as! RKComment
        
        let body = comment.body.stringByReplacingOccurrencesOfString("&gt;", withString: ">",
            options: .CaseInsensitiveSearch,
            range: nil).stringByReplacingOccurrencesOfString("&amp;", withString: "&", options: .CaseInsensitiveSearch, range: nil)
        
        let parser = XNGMarkdownParser()
        parser.paragraphFont = MyRedditCommentTextBoldFont
        parser.boldFontName = MyRedditCommentTextBoldFont.familyName
        parser.boldItalicFontName = MyRedditCommentTextItalicFont.familyName
        parser.italicFontName = MyRedditCommentTextItalicFont.familyName
        parser.linkFontName = MyRedditCommentTextBoldFont.familyName
        
        let parsedString = NSMutableAttributedString(attributedString: parser.attributedStringFromMarkdownString("\(body)"))
    
        let rect = parsedString.string.boundingRectWithSize(CGSizeMake((self.tableView.frame.size.width - 18) - (CGFloat(indentationLevel + 1) * indentationWidth), CGFloat.max),
            options: NSStringDrawingOptions.UsesLineFragmentOrigin,
            attributes: [NSFontAttributeName : MyRedditCommentTextFont],
            context: nil)

        return rect.height + 60
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return (self.commentsBySection?.count ?? 0) + 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CommentCell") as! CommentCell

        var comment: RKComment!
        
        if indexPath.section == 0 {
            cell.link = self.link
        } else {
            var commentDictionary = self.commentsBySection?[indexPath.section - 1] as! [String : AnyObject]
            let indent = commentDictionary["level"] as! Int
            cell.indentationLevel = indent + 1
            cell.indentationWidth = 15
            comment = commentDictionary["comment"] as! RKComment
            
            var hidden = false
            var collapsed = false
            
            for hiddenIndexPath in self.hiddenIndexPaths {
                if indexPath.section == hiddenIndexPath.section {
                    hidden = true
                }
            }
            
            for closedIndexPath in self.closedIndexPaths {
                if indexPath.section == closedIndexPath.section {
                    collapsed = true
                }
            }
            
            if !hidden {
                cell.configueForComment(comment: comment,
                    isLinkAuthor: self.link.author == comment.author)
            }
            
            cell.separatorInset = UIEdgeInsets(top: 0,
                left: self.tableView.frame.size.width,
                bottom: 0,
                right: 0)
        }
        
        cell.delegate = self
        cell.commentDelegate = self
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        })
        
        if indexPath.section != 0 {
            var remove = false
            
            for collapsedIndexPath in self.closedIndexPaths {
                if indexPath.section == collapsedIndexPath.section {
                    remove = true
                    break
                }
            }
            
            var commentDictionary = self.commentsBySection?[indexPath.section - 1] as! [String : AnyObject]
            var collapsedIndexPaths = [NSIndexPath]()
            var hiddenIndexPaths = [NSIndexPath]()
            
            // Get comment to start collapse
            let comment = commentDictionary["comment"] as! RKComment
            
            // Get replies for comment
            let repliesForComment = self.repliesForComment(comment, level: 0)
            
            collapsedIndexPaths.append(indexPath)
            
            if remove {

                var sectionCount = indexPath.section
                for _ in repliesForComment {
                    sectionCount += 1
                    hiddenIndexPaths.append(NSIndexPath(forRow: 0, inSection: sectionCount))
                }
                
                for removedIndexPath in collapsedIndexPaths {
                    for var i = 0; i < self.closedIndexPaths.count; i++ {
                        let closedIndexPath = self.closedIndexPaths[i]
                        if closedIndexPath.section == removedIndexPath.section {
                            self.closedIndexPaths.removeAtIndex(i)
                        }
                    }
                }
                
                for hiddenIndexPath in hiddenIndexPaths {
                    for var i = 0; i < self.hiddenIndexPaths.count; i++ {
                        let closedIndexPath = self.hiddenIndexPaths[i]
                        if closedIndexPath.section == hiddenIndexPath.section {
                            self.hiddenIndexPaths.removeAtIndex(i)
                        }
                    }
                }
            } else {
                var sectionCount = indexPath.section
                for _ in repliesForComment {
                    sectionCount += 1
                    hiddenIndexPaths.append(NSIndexPath(forRow: 0, inSection: sectionCount))
                }
                
                self.hiddenIndexPaths.appendContentsOf(hiddenIndexPaths)
                self.closedIndexPaths.appendContentsOf(collapsedIndexPaths)
            }
            
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
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
        } else if segue.identifier == "EditCommentSegue" {
            if let nav = segue.destinationViewController as? UINavigationController {
                if let controller = nav.viewControllers[0] as? AddCommentViewController {
                    
                    if let editComment = sender as? RKComment {
                        controller.comment = editComment
                        controller.edit =  true
                    } else if let editLink = sender as? RKLink {
                        controller.link = editLink
                        controller.edit = true
                    }
                    
                    controller.delegate = self
                }
            }
        } else if segue.identifier == "DeletePostSegue" {
            
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
        if swipeType.rawValue != JZSwipeTypeNone.rawValue {
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
                        
                        if swipeType.rawValue == JZSwipeTypeShortRight.rawValue {
                            self.downVote(object)
                        } else if swipeType.rawValue == JZSwipeTypeShortLeft.rawValue {
                            self.upVote(object)
                        } else if swipeType.rawValue == JZSwipeTypeLongLeft.rawValue {
                            if indexPath.section != 0 {
                                self.hud.hide(true)
                                var commentDictionary = self.self.commentsBySection?[indexPath.section - 1] as! [String : AnyObject]
                                let comment = commentDictionary["comment"] as! RKComment
                                self.commentMoreActions(cell, comment: comment)
                            } else {
                                self.linkMoreActions(cell)
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
    
    private func linkMoreActions(sourceView: AnyObject) {
        LocalyticsSession.shared().tagEvent("Swipe more")
        // More
        self.hud.hide(true)
        let alertController = UIAlertController(title: "Select options", message: nil, preferredStyle: .ActionSheet)
        
        alertController.addAction(UIAlertAction(title: "add comment", style: .Default, handler: { (action) -> Void in
            self.performSegueWithIdentifier("AddCommentSegue", sender: nil)
        }))
        
        alertController.addAction(UIAlertAction(title: "report", style: .Default, handler: { (action) -> Void in
            RedditSession.sharedSession.reportLink(self.link, completion: { (error) -> () in
                if error != nil {
                    UIAlertView.showUnableToReportLinkError()
                } else {
                    UIAlertView.showReportLinkSuccess()
                }
            })
        }))
        
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
        
        if self.link.author == UserSession.sharedSession.currentUser?.username {
            if self.link.selfPost == true {
                alertController.addAction(UIAlertAction(title: "edit", style: .Default, handler: { (action) -> Void in
                    self.performSegueWithIdentifier("EditCommentSegue", sender: self.link)
                }))
            }
            
            alertController.addAction(UIAlertAction(title: "delete", style: .Default, handler: { (action) -> Void in
                RedditSession.sharedSession.deleteLink(self.link, completion: { (error) -> () in
                    if error != nil {
                        UIAlertView.showUnableToDeleteLinkError()
                    } else {
                        let deleteAlert = UIAlertController(title: "Delete post", message: "Are you sure you want to delete this post?", preferredStyle: .Alert)
                        
                        deleteAlert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action) -> Void in
                            self.performSegueWithIdentifier("DeletePostSegue", sender: nil)
                        }))
                        
                        deleteAlert.addAction(UIAlertAction(title: "No", style: .Cancel, handler: nil))
                        deleteAlert.present(animated: true, completion: nil)
                    }
                })
            }))
        }
        
        alertController.addAction(UIAlertAction(title: "cancel", style: .Cancel, handler: nil))
        
        if let popoverController = alertController.popoverPresentationController {
            if let view = sourceView as? UITableViewCell {
                popoverController.sourceView = view
                popoverController.sourceRect = sourceView.bounds
            } else {
                popoverController.barButtonItem = sourceView as? UIBarButtonItem
            }
        }
        
        alertController.present(animated: true, completion: nil)
    }
    
    private func commentMoreActions(sourceView: AnyObject, comment: RKComment) {
        LocalyticsSession.shared().tagEvent("Swipe more")
        
        let alertController = UIAlertController(title: "Select comment options", message: nil, preferredStyle: .ActionSheet)
        
        alertController.addAction(UIAlertAction(title: "save", style: .Default, handler: { (action) -> Void in
            RedditSession.sharedSession.saveComment(comment, completion: { (error) -> () in
                // alert or do something else...
                if error != nil {
                    UIAlertView.showUnableToSaveCommentError()
                } else {
                    UIAlertView.showSaveCommentSuccess()
                }
            })
        }))
        
        if comment.author == UserSession.sharedSession.currentUser?.username {
            alertController.addAction(UIAlertAction(title: "edit", style: .Default, handler: { (action) -> Void in
                self.performSegueWithIdentifier("EditCommentSegue", sender: comment)
            }))
            
            alertController.addAction(UIAlertAction(title: "delete", style: .Default, handler: { (action) -> Void in
                RedditSession.sharedSession.deleteComment(comment, completion: { (error) -> () in
                    if error != nil {
                        UIAlertView.showUnableToDeleteCommentError()
                    } else {
                        UIAlertView.showDeleteCommentSuccess()
                        self.syncComments()
                    }
                })
            }))
        }
        
        alertController.addAction(UIAlertAction(title: "reply", style: .Default, handler: { (action) -> Void in
            self.performSegueWithIdentifier("AddCommentSegue", sender: comment)
        }))
        
        alertController.addAction(UIAlertAction(title: "report", style: .Default, handler: { (action) -> Void in
            RedditSession.sharedSession.reportComment(comment, completion: { (error) -> () in
                if error != nil {
                    UIAlertView.showUnableToReportCommentError()
                } else {
                    UIAlertView.showReportCommentSuccess()
                }
            })
        }))
        
        alertController.addAction(UIAlertAction(title: "cancel", style: .Cancel, handler: nil))
        
        if let popoverController = alertController.popoverPresentationController {
            if let view = sourceView as? UITableViewCell {
                popoverController.sourceView = view
                popoverController.sourceRect = sourceView.bounds
            } else {
                popoverController.barButtonItem = sourceView as? UIBarButtonItem
            }
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
            if controller.edit {
                if let _ = controller.link {
                    RedditSession.sharedSession.linkWithFullName(self.link, completion: { (pagination, results, error) -> () in
                        if let refreshedLink = results?.first as? RKLink {
                            self.link = refreshedLink
                        }
                    })
                    LocalyticsSession.shared().tagEvent("Edited link")
                } else {
                    LocalyticsSession.shared().tagEvent("Edited comment")
                }
            } else {
                if let _ = controller.comment {
                    LocalyticsSession.shared().tagEvent("Reply comment added")
                } else {
                    LocalyticsSession.shared().tagEvent("Added comment")
                }
            }
            self.syncComments()
        } else {
            if controller.edit {
                UIAlertView.showUnableToEditCommentError()
                LocalyticsSession.shared().tagEvent("Edited comment failed")
            } else {
                if let _ = controller.comment {
                    UIAlertView.showUnableToReplyCommentError()
                    LocalyticsSession.shared().tagEvent("Reply comment failed")
                } else {
                    UIAlertView.showUnableToAddCommentError()
                    LocalyticsSession.shared().tagEvent("Added comment failed")
                }
            }
        }
    }
    
    @IBAction func moreButtonTapped(sender: AnyObject) {
        self.linkMoreActions(sender)
    }
    
    @IBAction func shareButtonTapped(sender: AnyObject) {
        let linkOptions = LinkShareOptionsViewController(link: self.link)
        linkOptions.barbuttonItem = self.shareButton
        linkOptions.showInView(self.view)
    }
    
    override func preferredAppearance() {
        
        self.tableView.backgroundColor = MyRedditBackgroundColor
        
        self.navigationController?.navigationBar.backgroundColor = MyRedditBackgroundColor
        self.navigationController?.navigationBar.barTintColor = MyRedditBackgroundColor
        self.navigationController?.navigationBar.tintColor = MyRedditLabelColor
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : MyRedditLabelColor,
            NSFontAttributeName : MyRedditTitleFont]
        
        self.navigationController?.toolbar.barTintColor = MyRedditBackgroundColor
        self.navigationController?.toolbar.backgroundColor = MyRedditBackgroundColor
        self.navigationController?.toolbar.tintColor = MyRedditLabelColor
        self.navigationController?.toolbar.translucent = false
        
        self.addButton.tintColor = MyRedditLabelColor
        
        if let _ = self.splitViewController {
            self.navigationController?.setToolbarHidden(false, animated: false)
        }
        
        self.tableView.reloadData()
    }
}