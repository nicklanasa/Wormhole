//
//  UserContentViewController.swift
//  MyReddit
//
//  Created by Nick Lanasa on 5/1/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation
import UIKit
import MBProgressHUD

class UserContentViewController: RootViewController,
UITableViewDelegate,
UITableViewDataSource,
PostCellDelegate,
CommentCellDelegate,
PostImageCellDelegate {

    var category: RKUserContentCategory!
    var categoryTitle: String!
    
    var pagination: RKPagination? {
        didSet {
            self.fetchingMore = false
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                self.hud?.hide(true)
            }
        }
    }
    
    var content = Array<AnyObject>()
    var optionsController: LinkShareOptionsViewController!
    var selectedLink: RKLink!
    var user: RKUser!
    var heightsCache = [String : AnyObject]()
    var fetchingMore = false
    
    var hud: MBProgressHUD! {
        didSet {
            hud.labelFont = MyRedditSelfTextFont
            hud.mode = .Indeterminate
            hud.labelText = "Loading"
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var listButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        
        self.tableView.registerNib(UINib(nibName: "CommentCell", bundle: NSBundle.mainBundle()),
            forCellReuseIdentifier: "CommentCell")
        
        tableView.estimatedRowHeight = 68.0
        tableView.rowHeight = UITableViewAutomaticDimension
                
        self.syncContent()
        
        self.navigationItem.title = self.categoryTitle.lowercaseString
        self.tableView.backgroundColor = MyRedditBackgroundColor
        
        self.tableView.tableFooterView = UIView()
        
        if let splitViewController = self.splitViewController {
            self.listButton.action = splitViewController.displayModeButtonItem().action
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        LocalyticsSession.shared().tagScreen("UserContent")
    }

    private func syncContent() {
        UserSession.sharedSession.userContent(self.user,
            category: self.category,
            pagination: self.pagination,
            completion: { (pagination, results, error) -> () in
                
            self.pagination = pagination
                
            if let moreContent = results {
                self.content.appendContentsOf(moreContent)
            }
            
            if self.content.count == 25 || self.content.count == 0 {
                self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
            } else {
                self.tableView.reloadData()
            }
        })
    }
    
    // MARK: UITableViewDatasource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return content.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let link = self.content[indexPath.row] as? RKLink {
            if link.hasImage() {
                // Image
                
                if indexPath.row == 0 || SettingsManager.defaultManager.valueForSetting(.FullWidthImages) {
                    // regular
                    return self.heightForLink(link)
                } else {
                    
                    let url = link.urlForLink()
                    
                    if url != nil {
                        if let height = self.heightsCache[url!] as? NSNumber {
                            return CGFloat(height.floatValue)
                        }
                    }
                    
                    return 392
                }
                
            } else {
                // regular
                return self.heightForLink(link)
            }
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    private func heightForLink(link: RKLink) -> CGFloat {
        let text = link.title
        let frame = CGRectMake(0, 0, (self.tableView.frame.size.width - 18), CGFloat.max)
        let label: UILabel = UILabel(frame: frame)
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.font = UIFont(name: "AvenirNext-Medium",
            size: SettingsManager.defaultManager.titleFontSizeForDefaultTextSize)
        label.text = text
        label.sizeToFit()
        
        return label.frame.height + 80
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("PostImageCell") as! PostCell
        
        if let link = self.content[indexPath.row] as? RKLink {
            if link.hasImage() {
                
                if indexPath.row == 0 || SettingsManager.defaultManager.valueForSetting(.FullWidthImages) {
                    cell = tableView.dequeueReusableCellWithIdentifier("TitleCell") as! TitleCell
                } else {
                    let imageCell = tableView.dequeueReusableCellWithIdentifier("PostImageCell") as! PostImageCell
                    imageCell.postImageDelegate = self
                    imageCell.link = link
                    return imageCell
                }
                
            } else {
                cell = tableView.dequeueReusableCellWithIdentifier("TitleCell") as! TitleCell
            }
            
            cell.link = link
        } else if let comment = self.content[indexPath.row] as? RKComment {
            
            let commentCell = tableView.dequeueReusableCellWithIdentifier("CommentCell") as! CommentCell
            
            commentCell.indentationLevel = 1
            commentCell.indentationWidth = 15
            commentCell.commentDelegate = self
            
            commentCell.configueForComment(comment: comment, isLinkAuthor: true)
            
            return commentCell
        }
        
        cell.postCellDelegate = self
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if let link = self.content[indexPath.row] as? RKLink {
            self.selectedLink = link
            if link.selfPost {
                self.performSegueWithIdentifier("CommentsSegue", sender: link)
            } else {
                if link.domain == "imgur.com" || link.isImageLink() {
                    if link.domain == "imgur.com" && !link.URL.absoluteString.hasExtension() {
                        var urlComponents = link.URL.absoluteString.componentsSeparatedByString("/")
                        if urlComponents.count > 4 {
                            let albumID = urlComponents[4]
                            IMGAlbumRequest.albumWithID(albumID, success: { (album) -> Void in
                                self.performSegueWithIdentifier("GallerySegue", sender: album.images)
                                }) { (error) -> Void in
                                    self.performSegueWithIdentifier("SubredditLink", sender: link)
                            }
                        } else {
                            if urlComponents.count > 3 {
                                let imageID = urlComponents[3]
                                IMGImageRequest.imageWithID(imageID, success: { (image) -> Void in
                                    self.performSegueWithIdentifier("GallerySegue", sender: [image])
                                    }, failure: { (error) -> Void in
                                        self.performSegueWithIdentifier("SubredditLink", sender: link)
                                })
                            } else {
                                self.performSegueWithIdentifier("GallerySegue", sender: [link.URL])
                            }
                        }
                    } else {
                        self.performSegueWithIdentifier("GallerySegue", sender: [link.URL!])
                    }
                } else {
                    self.performSegueWithIdentifier("SubredditLink", sender: link)
                }
            }
        } else if let comment = self.content[indexPath.row] as? RKComment {
            self.fetchLinkForComment(comment)
        }

        if let titleCell = tableView.cellForRowAtIndexPath(indexPath) as? TitleCell {
            titleCell.titleLabel.textColor = UIColor.grayColor()
        } else if let imageCell = tableView.cellForRowAtIndexPath(indexPath) as? PostImageCell {
            imageCell.titleLabel.textColor = UIColor.grayColor()
        }
    }
    
    // MARK: IBActions
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SubredditLink" {
            if let link = sender as? RKLink {
                if let controller = segue.destinationViewController as? LinkViewController {
                    controller.link = link
                }
            }
        } else if segue.identifier == "GallerySegue" {
            if let controller = segue.destinationViewController as? GalleryController {
                if let images = sender as? [AnyObject] {
                    controller.images = images
                    controller.link = self.selectedLink
                }
            }
        } else {
            if let link = sender as? RKLink {
                if let controller = segue.destinationViewController as? CommentsTreeViewController {
                    controller.link = link
                }
            }
        }
    }
    
    // MARK: CommentCellDelegate
    
    func commentCell(cell: CommentCell, didShortRightSwipeForItem item: AnyObject) {
        let c: ErrorCompletion = {
            error in
            if error != nil {
                UIAlertView(title: "Error!",
                    message: error!.localizedDescription,
                    delegate: self,
                    cancelButtonTitle: "Ok").show()
            } else {
                if let indexPath = self.tableView.indexPathForCell(cell) {
                    self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                }
            }
        }
        
        if let comment = item as? RKComment {
            RedditSession.sharedSession.downvote(comment, completion: c)
            LocalyticsSession.shared().tagEvent("Swipe downvote comment")
        } else if let link = item as? RKLink {
            RedditSession.sharedSession.downvote(link, completion: c)
            LocalyticsSession.shared().tagEvent("Swipe downvote")
        }
    }
    
    func commentCell(cell: CommentCell, didShortLeftSwipeForItem item: AnyObject) {
        let c: ErrorCompletion = {
            error in
            if error != nil {
                UIAlertView(title: "Error!",
                    message: error!.localizedDescription,
                    delegate: self,
                    cancelButtonTitle: "Ok").show()
            } else {
                if let indexPath = self.tableView.indexPathForCell(cell) {
                    self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                }
            }
        }
        
        if let comment = item as? RKComment {
            RedditSession.sharedSession.upvote(comment, completion: c)
            LocalyticsSession.shared().tagEvent("Swipe upvote comment")
        } else if let link = item as? RKLink {
            RedditSession.sharedSession.upvote(link, completion: c)
            LocalyticsSession.shared().tagEvent("Swipe downvote")
        }
    }
    
    func commentCell(cell: CommentCell, didLongRightSwipeForItem item: AnyObject) {
        if let comment = item as? RKComment {
            let c: ErrorCompletion = {
                error in
                if error != nil {
                    UIAlertView(title: "Error!",
                        message: error!.localizedDescription,
                        delegate: self,
                        cancelButtonTitle: "Ok").show()
                } else {
                    if let indexPath = self.tableView.indexPathForCell(cell) {
                        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                    }
                }
            }
            
            RedditSession.sharedSession.downvote(comment, completion: c)
            LocalyticsSession.shared().tagEvent("Swipe downvote comment")
        } else if let link = item as? RKLink {
            // Share
            self.optionsController = LinkShareOptionsViewController(link: link)
            self.optionsController.sourceView = cell
            self.optionsController.showInView(self.view)
            LocalyticsSession.shared().tagEvent("Swipe share")
        }
    }
    
    func commentCell(cell: CommentCell, didLongLeftSwipeForItem item: AnyObject) {
        if let comment = item as? RKComment {
            self.commentMoreActions(cell, comment: comment)
        } else if let link = item as? RKLink {
            self.linkMoreActions(link, sourceView: cell)
        }
    }
    
    private func linkMoreActions(link: RKLink, sourceView: AnyObject) {
        let alertController = UIAlertController(title: "Select options", message: nil, preferredStyle: .ActionSheet)
        
        alertController.addAction(UIAlertAction(title: "add comment", style: .Default, handler: { (action) -> Void in
            self.performSegueWithIdentifier("AddCommentSegue", sender: nil)
        }))
        
        alertController.addAction(UIAlertAction(title: "report", style: .Default, handler: { (action) -> Void in
            RedditSession.sharedSession.reportLink(link, completion: { (error) -> () in
                if error != nil {
                    UIAlertView.showUnableToReportLinkError()
                } else {
                    UIAlertView.showReportLinkSuccess()
                }
            })
        }))
        
        if link.saved() {
            alertController.addAction(UIAlertAction(title: "unsave", style: .Default, handler: { (action) -> Void in
                RedditSession.sharedSession.unSaveLink(link, completion: { (error) -> () in
                    link.unSaveLink()
                })
            }))
        } else {
            alertController.addAction(UIAlertAction(title: "save", style: .Default, handler: { (action) -> Void in
                RedditSession.sharedSession.saveLink(link, completion: { (error) -> () in
                    self.hud.hide(true)
                    link.saveLink()
                })
            }))
        }
        
        if link.author == UserSession.sharedSession.currentUser?.username {
            if link.selfPost == true {
                alertController.addAction(UIAlertAction(title: "edit", style: .Default, handler: { (action) -> Void in
                    self.performSegueWithIdentifier("EditCommentSegue", sender: link)
                }))
            }
            
            alertController.addAction(UIAlertAction(title: "delete", style: .Default, handler: { (action) -> Void in
                RedditSession.sharedSession.deleteLink(link, completion: { (error) -> () in
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
        
        LocalyticsSession.shared().tagEvent("Swipe more")
    }
    
    private func commentMoreActions(sourceView: AnyObject, comment: RKComment) {
        LocalyticsSession.shared().tagEvent("Swipe more")
        let alertController = UIAlertController(title: "Select comment options", message: nil, preferredStyle: .ActionSheet)
        
        alertController.addAction(UIAlertAction(title: "save", style: .Default, handler: { (action) -> Void in
            RedditSession.sharedSession.saveComment(comment, completion: { (error) -> () in
                if error != nil {
                    UIAlertView.showUnableToSaveCommentError()
                } else {
                    UIAlertView.showSaveCommentSuccess()
                }
            })
        }))
        
        if comment.author == UserSession.sharedSession.currentUser?.username {
            
            alertController.addAction(UIAlertAction(title: "delete", style: .Default, handler: { (action) -> Void in
                RedditSession.sharedSession.deleteComment(comment, completion: { (error) -> () in
                    if error != nil {
                        UIAlertView.showUnableToDeleteCommentError()
                    } else {
                        if let cell = sourceView as? UITableViewCell {
                            if let indexPath = self.tableView.indexPathForCell(cell) {
                                self.content.removeAtIndex(indexPath.row)
                                self.tableView.beginUpdates()
                                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                                self.tableView.endUpdates()
                            }
                        }
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
    
    // MARK: PostCellDelegate
    
    func postCell(cell: PostCell, didShortLeftSwipeForLink link: RKLink) {
        // Upvote
        self.upvote(link)
    }
    
    func postCell(cell: PostCell, didShortRightSwipeForLink link: RKLink) {
        // Downvote
        self.downvote(link)
    }
    
    func postCell(cell: PostCell, didLongRightSwipeForLink link: RKLink) {
        self.performMoreSwipeActionForLink(link, withCell: cell)
    }
    
    func postCell(cell: PostCell, didLongLeftSwipeForLink link: RKLink) {
        self.performSegueWithIdentifier("CommentsSegue", sender: link)
    }
    
    // MARK: Private

    private func performMoreSwipeActionForLink(link: RKLink, withCell cell: UITableViewCell) {
        LocalyticsSession.shared().tagEvent("Swipe more")
        
        self.hud.hide(true)
        
        let alertController = UIAlertController(title: "Select option",
                                                message: nil,
                                                preferredStyle: .ActionSheet)
        
        if link.saved() {
            let action = UIAlertAction(
                    title: "unsave",
                    style: .Default,
                                   handler: { (action) -> Void in
                                       link.unsave({ (error) -> Void in self.hud.hide(true) })
                                   })
            
            alertController.addAction(action)
        } else {
            let action = UIAlertAction(
                    title: "save",
                    style: .Default,
                                   handler: { (action) -> Void in
                                       link.save({ (error) -> Void in self.hud.hide(true) })
                                   })
            
            alertController.addAction(action)
        }
        
        alertController.addAction(UIAlertAction(title: "share",
            style: .Default, handler: { (action) -> Void in
                // Share                
                self.hud.hide(true)
                self.optionsController = LinkShareOptionsViewController(link: link)
                self.optionsController.sourceView = cell
                self.optionsController.showInView(self.view)
        }))
        
        alertController.addAction(UIAlertAction(title: "cancel", style: .Cancel, handler: nil))
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = cell
            popoverController.sourceRect = cell.bounds
        }
        
        alertController.present(animated: true, completion: nil)

    }

    private func performSwipeActionForType(swipeType: JZSwipeType, forObject obj: RKVotable) {
        self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        if swipeType.rawValue == JZSwipeTypeShortRight.rawValue || swipeType.rawValue == JZSwipeTypeLongRight.rawValue {
            LocalyticsSession.shared().tagEvent("Swipe downvote comment")
            // Downvote
            self.downvote(obj)
        } else if swipeType.rawValue == JZSwipeTypeShortLeft.rawValue || swipeType.rawValue == JZSwipeTypeLongLeft.rawValue {
            // Upvote
            LocalyticsSession.shared().tagEvent("Swipe upvote comment")
            self.upvote(obj)
        } else {
            self.hud.hide(true)
        }
    }
    
    private func downvote(link: RKVotable) {
        LocalyticsSession.shared().tagEvent("Swipe Downvote")
        RedditSession.sharedSession.downvote(link, completion: { (error) -> () in
            self.hud.hide(true)
            
            if error != nil {
                UIAlertView(title: "Error!",
                    message: error!.localizedDescription,
                    delegate: self,
                    cancelButtonTitle: "Ok").show()
            } else {
                self.syncContent()
            }
        })
    }
    
    private func upvote(link: RKVotable) {
        LocalyticsSession.shared().tagEvent("Swipe Upvote")
        RedditSession.sharedSession.upvote(link, completion: { (error) -> () in
            self.hud.hide(true)
            
            if error != nil {
                UIAlertView(title: "Error!",
                    message: error!.localizedDescription,
                    delegate: self,
                    cancelButtonTitle: "Ok").show()
            } else {
                self.syncContent()
            }
        })
    }
    
    private func fetchLinkForComment(comment: RKComment) {
        RedditSession.sharedSession.fetchLinkWithComment(comment, completion: { (pagination, results, error) -> () in
            if let link = results?.first as? RKLink {
                if link.selfPost {
                    self.performSegueWithIdentifier("CommentsSegue", sender: link)
                } else {
                    self.performSegueWithIdentifier("SubredditLink", sender: link)
                }
            } else {
                UIAlertView(title: "Error!",
                    message: "Unable to get link!",
                    delegate: self,
                    cancelButtonTitle: "Ok").show()
            }
        })
    }
    
    // MARK: UIScrollViewDelegate
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let endScrolling = scrollView.contentOffset.y + scrollView.frame.size.height
        if endScrolling >= scrollView.contentSize.height && !self.fetchingMore {
            self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            self.fetchingMore = true
            self.syncContent()
        }
    }
    
    // MARK: PostImageCellDelegate
    
    func postImageCell(cell: PostImageCell, didDownloadImageWithHeight height: CGFloat, url: NSURL) {
        if let _ = self.tableView.indexPathForCell(cell) {
            self.heightsCache[url.description] = NSNumber(float: Float(height))
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
    }
    
    func postImageCell(cell: PostImageCell, didLongHoldOnImage image: UIImage?) {
        if let selectedImage = image {
            self.presentViewController(UIAlertController.saveImageAlertController(selectedImage),
                animated: true,
                completion: nil)
        }
    }
    
    func commentCell(cell: CommentCell, didTapLink link: NSURL) {
        
    }
    
    override func preferredAppearance() {
        self.navigationController?.navigationBar.backgroundColor = MyRedditBackgroundColor
        self.navigationController?.navigationBar.barTintColor = MyRedditBackgroundColor
        self.navigationController?.navigationBar.tintColor = MyRedditLabelColor
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : MyRedditLabelColor]
        
        self.tableView.backgroundColor = MyRedditDarkBackgroundColor
        
        self.tableView.reloadData()
    }
}
