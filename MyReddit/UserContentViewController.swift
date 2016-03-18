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
import SafariServices
import Kingfisher

class UserContentViewController: RootViewController,
UITableViewDelegate,
UITableViewDataSource,
PostCellDelegate,
CommentCellDelegate,
PostImageCellDelegate,
AddCommentViewControllerDelegate {

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
    
    var content: [AnyObject]?
    var selectedLink: RKLink!
    var user: RKUser!
    var fetchingMore = true
    
    var resources = [String : Resource]()
    var hud: MBProgressHUD!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var listButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        self.tableView.registerNib(UINib(nibName: "CommentCell", bundle: NSBundle.mainBundle()),
            forCellReuseIdentifier: "CommentCell")
        
        self.tableView.estimatedRowHeight = 80.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.syncContent()
        
        self.navigationItem.title = self.categoryTitle.lowercaseString
        self.tableView.backgroundColor = MyRedditDarkBackgroundColor
        
        self.tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        LocalyticsSession.shared().tagScreen("UserContent")
        
        if let splitViewController = self.splitViewController {
            self.listButton.action = splitViewController.displayModeButtonItem().action
        } else {
            self.navigationController?.setToolbarHidden(true, animated: false)
        }
    }

    private func syncContent() {
        self.fetchingMore = true
        UserSession.sharedSession.userContent(self.user,
            category: self.category,
            pagination: self.pagination,
            completion: { (pagination, results, error) -> () in
                
            self.pagination = pagination
                
            if let moreContent = results {
                if self.content == nil {
                    self.content = []
                }
                
                // Prefetch urls
                var urls = Array<NSURL>()
                
                for obj in moreContent {
                    if let link = obj as? RKLink {
                        if link.hasImage() {
                            if let urlStr = link.urlForLink() {
                                if let url = NSURL(string: urlStr) {
                                    urls.append(url)
                                }
                            }
                        }
                    }
                }
                
                let prefetcher = ImagePrefetcher(urls: urls, optionsInfo: nil, progressBlock: nil, completionHandler: {
                    (skippedResources, failedResources, completedResources) -> () in
                    for resource in completedResources {
                        self.resources[resource.downloadURL.absoluteString] = resource
                    }
                    
                    self.content?.appendContentsOf(moreContent)
                    
                    if self.content?.count == 25 || self.content?.count == 0 {
                        self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
                    } else {
                        self.tableView.reloadData()
                    }
                })
                prefetcher.start()
            }
        })
    }
    
    // MARK: UITableViewDatasource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.content == nil && !self.fetchingMore {
            return 1
        }
        return self.content?.count ?? 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        if self.content == nil {
            return tableView.dequeueReusableCellWithIdentifier("NoDataCell") as! NoDataCell
        }
        
        var cell = tableView.dequeueReusableCellWithIdentifier("PostImageCell") as! PostCell

        if let link = self.content?[indexPath.row] as? RKLink {
            if link.hasImage() {
                
                if indexPath.row == 0 || SettingsManager.defaultManager.valueForSetting(.FullWidthImages) {
                    cell = tableView.dequeueReusableCellWithIdentifier("TitleCell") as! TitleCell
                } else {
                    let imageCell = tableView.dequeueReusableCellWithIdentifier("PostImageCell") as! PostImageCell
                    imageCell.postImageDelegate = self
                    imageCell.postCellDelegate = self
                    imageCell.link = link
                    if let url = link.urlForLink() {
                        if let resource = self.resources[url] {
                            KingfisherManager.sharedManager.retrieveImageWithResource(resource, optionsInfo: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, imageURL) in
                                if image != nil {
                                    if let resizedImage = image!.imageWithImage(image!,
                                        toSize: CGSizeMake(UIScreen.mainScreen().bounds.size.width, CGFloat.max)) {
                                        imageCell.postImageView.alpha = 0
                                        UIView.animateWithDuration(0.3, animations: {
                                            // update some UI
                                            imageCell.postImageView.alpha = 1
                                            imageCell.postImageViewHeightConstraint.constant = resizedImage.size.height
                                            imageCell.postImageView.image = resizedImage
                                        })
                                    }
                                }
                            })
                        }
                    }
                    return imageCell
                }
                
            } else {
                cell = tableView.dequeueReusableCellWithIdentifier("TitleCell") as! TitleCell
            }
            
            cell.link = link
        } else if let comment = self.content?[indexPath.row] as? RKComment {
            
            let commentCell = tableView.dequeueReusableCellWithIdentifier("CommentCell") as! CommentCell
            
            commentCell.indentationLevel = 1
            commentCell.indentationWidth = 15
            commentCell.commentDelegate = self
            
            commentCell.configueForComment(comment: comment, isLinkAuthor: true)
            
            commentCell.bodyLabel.font = UIFont(name: MyRedditTitleFont.fontName,
                size: SettingsManager.defaultManager.titleFontSizeForDefaultTextSize)
            
            return commentCell
        }
        
        cell.postCellDelegate = self
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)

        if self.content == nil {
            return
        }
        if let link = self.content?[indexPath.row] as? RKLink {
            self.selectedLink = link
            if link.selfPost {
                self.performSegueWithIdentifier("CommentsSegue", sender: link)
            } else {
                if let cell = tableView.cellForRowAtIndexPath(indexPath) as? PostImageCell {
                    if (link.domain == "imgur.com") {
                        if link.isGifLink() {
                            self.performSegueWithIdentifier("SubredditLink", sender: link.URL)
                        } else {
                            if link.domain == "imgur.com" && !link.URL.absoluteString.hasExtension() {
                                var urlComponents = link.URL.absoluteString.componentsSeparatedByString("/")
                                if urlComponents.count > 4 {
                                    let albumID = urlComponents[4]
                                    IMGAlbumRequest.albumWithID(albumID, success: { (album) -> Void in
                                        self.performSegueWithIdentifier("GallerySegue", sender: album.images)
                                        }) { (error) -> Void in
                                            LocalyticsSession.shared().tagEvent("Imgur album request failed")
                                            self.performSegueWithIdentifier("SubredditLink", sender: link)
                                    }
                                } else {
                                    if urlComponents.count > 3 {
                                        let imageID = urlComponents[3]
                                        IMGImageRequest.imageWithID(imageID, success: { (image) -> Void in
                                            self.performSegueWithIdentifier("GallerySegue", sender: [image])
                                            }, failure: { (error) -> Void in
                                                LocalyticsSession.shared().tagEvent("Imgur image request failed")
                                                self.performSegueWithIdentifier("SubredditLink", sender: link)
                                        })
                                    } else {
                                        self.performSegueWithIdentifier("GallerySegue", sender: [cell.postImageView?.image ?? link.URL])
                                    }
                                }
                            } else {
                                self.performSegueWithIdentifier("GallerySegue", sender: [cell.postImageView?.image ?? link.URL])
                            }
                        }
                    } else {
                        self.performSegueWithIdentifier("SubredditLink", sender: link)
                    }
                } else {
                    self.performSegueWithIdentifier("SubredditLink", sender: link)
                }
            }
        } else if let comment = self.content?[indexPath.row] as? RKComment {
            self.fetchLinkForComment(comment)
        }

        if let titleCell = tableView.cellForRowAtIndexPath(indexPath) as? TitleCell {
            titleCell.titleLabel.textColor = UIColor.grayColor()
        } else if let imageCell = tableView.cellForRowAtIndexPath(indexPath) as? PostImageCell {
            imageCell.titleTextView.textColor = UIColor.grayColor()
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
        } else if segue.identifier == "AddCommentSegue" {
            if let controller = segue.destinationViewController as? AddCommentViewController {
                if let comment = sender as? RKComment {
                    controller.comment = comment
                    controller.delegate = self
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
        }
    }
    
    func commentCell(cell: CommentCell, didLongLeftSwipeForItem item: AnyObject) {
        if let comment = item as? RKComment {
            self.commentMoreActions(cell, comment: comment)
        } else if let link = item as? RKLink {
            self.linkMoreActions(link, sourceView: cell)
        }
    }
    
    private func commentMoreActions(sourceView: AnyObject, comment: RKComment) {
        LocalyticsSession.shared().tagEvent("Swipe more")
        let alertController = UIAlertController(title: "Select comment options",
            message: nil,
            preferredStyle: .ActionSheet)
        
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
                                self.content?.removeAtIndex(indexPath.row)
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

    func postCell(cell: PostCell, didTapComments link: RKLink) {
        self.performSegueWithIdentifier("CommentsSegue", sender: link)
    }
    
    func postCell(cell: PostCell, didShortLeftSwipeForLink link: RKLink) {
        // Upvote
        self.upvote(link)
    }
    
    func postCell(cell: PostCell, didShortRightSwipeForLink link: RKLink) {
        // Downvote
        self.downvote(link)
    }
    
    func postCell(cell: PostCell, didLongRightSwipeForLink link: RKLink) {
        LocalyticsSession.shared().tagEvent("Swipe share")
        
        let alert = UIAlertController.swipeShareAlertControllerWithLink(link) { (url, action) -> () in
            var objectsToShare = ["\(link.title) #getmyreddit", url]
            
            if action.title == "share image" {
                if let indexPath = self.tableView.indexPathForCell(cell) {
                    if let imageCell = self.tableView.cellForRowAtIndexPath(indexPath) as? PostImageCell {
                        if let image = imageCell.postImageView.image {
                            objectsToShare = [image]
                        }
                    }
                }
            }
            
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            if let popoverController = activityVC.popoverPresentationController {
                popoverController.sourceView = cell
                popoverController.sourceRect = cell.bounds
            }
            
            activityVC.present(animated: true, completion: nil)
            
            LocalyticsSession.shared().tagEvent("Share tapped")
        }
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func postCell(cell: PostCell, didLongLeftSwipeForLink link: RKLink) {
        self.linkMoreActions(link, sourceView: cell)
    }
    
    private func linkMoreActions(link: RKLink, sourceView: UIView) {
        LocalyticsSession.shared().tagEvent("Swipe more")
        let alert = UIAlertController.swipeMoreAlertControllerWithLink(link) { (action) -> () in
            if let title = action.title {
                
                var hudTitle = ""
                
                let sh: () -> () = {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                        self.hud.labelFont = MyRedditSelfTextFont
                        self.hud.mode = .Text
                        self.hud.labelText = hudTitle
                        self.hud.show(true)
                        self.hud.hide(true, afterDelay: 0.3)
                    })
                }
                
                switch title {
                case "open in safari":
                    if #available(iOS 9.0, *) {
                        let svc = SFSafariViewController(URL: link.URL, entersReaderIfAvailable: true)
                        self.presentViewController(svc, animated: true, completion: nil)
                    } else {
                        UIApplication.sharedApplication().openURL(link.URL)
                    }
                case "unhide":
                    RedditSession.sharedSession.unHideLink(link, completion: { (error) -> () in
                        link.unHideLink()
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            if let cell = sourceView as? UITableViewCell {
                                if let indexPath = self.tableView.indexPathForCell(cell) {
                                    self.content?.removeAtIndex(indexPath.row)
                                    self.tableView.beginUpdates()
                                    self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                                    self.tableView.endUpdates()
                                    hudTitle = "unhidden!"
                                    sh()
                                }
                            }
                        })
                    })
                case "hide":
                    RedditSession.sharedSession.hideLink(link, completion: { (error) -> () in
                        link.hideLink()
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            if let cell = sourceView as? UITableViewCell {
                                if let indexPath = self.tableView.indexPathForCell(cell) {
                                    self.content?.removeAtIndex(indexPath.row)
                                    self.tableView.beginUpdates()
                                    self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                                    self.tableView.endUpdates()
                                    hudTitle = "hidden!"
                                    sh()
                                }
                            }
                        })
                    })
                case "unsave":
                    RedditSession.sharedSession.unSaveLink(link, completion: { (error) -> () in
                        link.unSaveLink()
                        if self.category == .Saved {
                            if let cell = sourceView as? UITableViewCell {
                                if let indexPath = self.tableView.indexPathForCell(cell) {
                                    self.content?.removeAtIndex(indexPath.row)
                                    self.tableView.beginUpdates()
                                    self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                                    self.tableView.endUpdates()
                                    hudTitle = "unsaved!"
                                    sh()
                                }
                            }
                        }
                    })
                case "save":
                    RedditSession.sharedSession.saveLink(link, completion: { (error) -> () in
                        link.saveLink()
                        hudTitle = "saved!"
                        sh()
                    })
                case "report":
                    RedditSession.sharedSession.reportLink(link, completion: { (error) -> () in
                        hudTitle = "reported!"
                        sh()
                    })
                case "go to /r/\(link.subreddit)":
                    if let subredditName = link.subreddit {
                        self.goToSubreddit(subredditName)
                    }
                default: break
                }
            }
        }
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = sourceView
            popoverController.sourceRect = sourceView.bounds
        }
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func goToSubreddit(subredditName: String) {
        RedditSession.sharedSession.searchForSubredditByName(subredditName, pagination: nil, completion: { (pagination, results, error) -> () in
            
            var foundSubreddit: RKSubreddit?
            
            if let subreddits = results as? [RKSubreddit] {
                for subreddit in subreddits {
                    if subreddit.name.lowercaseString == subredditName.lowercaseString {
                        foundSubreddit = subreddit
                        break
                    }
                }
                
                if foundSubreddit == nil {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        UIAlertView(title: "Error!",
                            message: "Unable to find subreddit by that name.",
                            delegate: self,
                            cancelButtonTitle: "OK").show()
                    })
                } else {
                    let subredditViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SubredditViewController") as! SubredditViewController
                    subredditViewController.subreddit = foundSubreddit
                    subredditViewController.front = false
                    subredditViewController.all = false
                    self.navigationController?.pushViewController(subredditViewController, animated: true)
                }
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
    
    
    private func downvote(link: RKVotable) {
        LocalyticsSession.shared().tagEvent("Swipe Downvote")
        RedditSession.sharedSession.downvote(link, completion: { (error) -> () in
            self.hud?.hide(true)
            
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
            self.hud?.hide(true)
            
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
        RedditSession.sharedSession.fetchLinkWithComment(comment,
            completion: { (pagination, results, error) -> () in
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
    
    func addCommentViewController(controller: AddCommentViewController, didAddComment success: Bool) {
        if success {
            self.syncContent()
        }
    }
    
    // MARK: UIScrollViewDelegate
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let endScrolling = scrollView.contentOffset.y + scrollView.frame.size.height
        if endScrolling >= scrollView.contentSize.height && !self.fetchingMore && self.pagination != nil {
            self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            self.fetchingMore = true
            self.syncContent()
        }
    }
    
    func commentCell(cell: CommentCell, didTapLink link: NSURL) { }
    
    override func preferredAppearance() {
        self.navigationController?.navigationBar.backgroundColor = MyRedditBackgroundColor
        self.navigationController?.navigationBar.barTintColor = MyRedditBackgroundColor
        self.navigationController?.navigationBar.tintColor = MyRedditLabelColor
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : MyRedditLabelColor]
        
        self.tableView.backgroundColor = MyRedditDarkBackgroundColor
        
        self.tableView.reloadData()
    }
}
