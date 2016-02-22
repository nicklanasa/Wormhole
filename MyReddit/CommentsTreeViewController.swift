//
//  CommentsTreeViewController.swift
//  MyReddit
//
//  Created by Nickolas Lanasa on 11/14/15.
//  Copyright © 2015 Nytek Production. All rights reserved.
//

import UIKit
import MBProgressHUD
import RATreeView

class CommentsTreeViewController: RootViewController,
UIScrollViewDelegate,
RATreeViewDelegate,
RATreeViewDataSource,
CommentCellDelegate,
UITextFieldDelegate,
AddCommentViewControllerDelegate {

    @IBOutlet weak var treeView: RATreeView!
    @IBOutlet weak var filterButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!

    var optionsController: LinkShareOptionsViewController!
    
    var hud: MBProgressHUD! {
        didSet {
            hud.labelFont = MyRedditSelfTextFont
            hud.mode = .Indeterminate
            hud.labelText = "Loading"
        }
    }
    
    var link: RKLink! {
        didSet {
            if let treeView = self.treeView {
                treeView.reloadRowsForItems([self.link], withRowAnimation: RATreeViewRowAnimation.init(0))
            }
        }
    }

    var filter: RKCommentSort! {
        didSet {
            self.treeView.hidden = true
            self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            RedditSession.sharedSession.fetchCommentsWithFilter(filter,
                                                                pagination: nil,
                                                                link: self.link,
                                                                completion: { (pagination, results, error) -> () in
                                                                    self.comments = results
                                                                    self.reloadComments()
                                                                })
        }
    }
    
    var comments: [AnyObject]? {
        didSet {
            self.navigationItem.title =  "\(self.link.totalComments) comments"
            self.treeView.reloadData()
        }
    }
    
    let refreshControl = UIRefreshControl()
    
    func refresh(sender: AnyObject) {
        
        RedditSession.sharedSession.linkWithFullName(self.link, completion: { (pagination, results, error) -> () in
            if error != nil {
                let alert = UIAlertController.errorAlertControllerWithMessage("Unable to get refresh link!")
                self.presentViewController(alert, animated: true, completion: nil)
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
        self.treeView.hidden = true
        LocalyticsSession.shared().tagScreen("Comments")
    }
    
    override func viewDidAppear(animated: Bool) {
        self.navigationItem.title =  "\(self.link.totalComments) comments"
        self.navigationController?.setToolbarHidden(false, animated: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Action,
            target: self,
            action: "shareButtonTapped:")
        
        self.refreshControl.addTarget(self, action: "syncComments", forControlEvents: .ValueChanged)
        self.treeView.scrollView.addSubview(self.refreshControl)
        
        self.treeView.delegate = self
        self.treeView.dataSource = self
        self.treeView.expandsChildRowsWhenRowExpands = true
        self.treeView.collapsesChildRowsWhenRowCollapses = true
        self.treeView.separatorStyle = RATreeViewCellSeparatorStyle.init(0)
        self.treeView.treeFooterView = UIView()
        self.treeView.rowsExpandingAnimation = RATreeViewRowAnimation.init(0)
        self.treeView.rowsCollapsingAnimation = RATreeViewRowAnimation.init(0)
        
        self.treeView.registerNib(UINib(nibName: "CommentCell", bundle: NSBundle.mainBundle()),
            forCellReuseIdentifier: "CommentCell")
        
        self.syncComments()

        RedditSession.sharedSession.markLinkAsViewed(self.link,
            completion: { (error) -> () in })
        
        self.preferredAppearance()
    }

    func reloadComments() {
        self.treeView.reloadRows()
        for item in self.treeView.itemsForRowsInRect(self.treeView.frame) as! [AnyObject] {
            if let comment = item as? RKComment {
                self.treeView.expandRowForItem(comment,
                    expandChildren: true,
                    withRowAnimation: RATreeViewRowAnimation.init(5))
            }
        }
        self.hud.hide(true)
        self.treeView.hidden = false
        self.refreshControl.endRefreshing()
    }

    func syncComments() {
        self.treeView.hidden = true
        self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        RedditSession.sharedSession.fetchComments(nil, link: self.link) { (pagination, results, error) -> () in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.comments = results
                self.reloadComments()
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

    // MARK: RATreeViewDatasource
    
    func treeView(treeView: RATreeView, numberOfChildrenOfItem item: AnyObject?) -> Int {
        if let _ = item as? RKLink {
            return 0
        } else if let comment = item as? RKComment {
            return comment.replies?.count ?? 0
        } else {
            if self.comments?.count == 0 {
                return 1
            } else {
                if let comments = self.comments {
                    return comments.count + 1
                }
                
                return 1
            }
        }
    }
    
    func treeView(treeView: RATreeView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
        if let comment = item as? RKComment {
            return comment.replies[index]
        } else {
            if index == 0 {
                return self.link
            } else {
                return self.comments![index - 1]
            }
        }
    }
    
    func treeView(treeView: RATreeView, cellForItem item: AnyObject?) -> UITableViewCell {
        let cell = treeView.dequeueReusableCellWithIdentifier("CommentCell") as! CommentCell
        
        cell.indentationWidth = 10
        
        if let link = item as? RKLink {
            cell.indentationLevel = 1
            cell.link = link
        } else if let comment = item as? RKComment {
            cell.indentationLevel = treeView.levelForCellForItem(comment) + 1
            cell.configueForComment(comment: comment, isLinkAuthor: self.link.author == comment.author)
        }
        
        cell.commentDelegate = self
        
        return cell
    }
    
    func treeView(treeView: RATreeView, estimatedHeightForRowForItem item: AnyObject) -> CGFloat {
        if let _ = item as? RKLink {
            return UITableViewAutomaticDimension
        } else if treeView.isCellForItemExpanded(item) {
            return 40
        }
        
        return UITableViewAutomaticDimension
    }
    
    func treeView(treeView: RATreeView, editingStyleForRowForItem item: AnyObject) -> UITableViewCellEditingStyle {
        return .None
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "AddCommentSegue" {
            if let controller = segue.destinationViewController as? AddCommentViewController {
                
                if let replyComment = sender as? RKComment {
                    controller.comment = replyComment
                } else {
                    controller.link = self.link
                }
                
                controller.delegate = self
            }
        } else if segue.identifier == "EditCommentSegue" {
            if let controller = segue.destinationViewController as? AddCommentViewController {
                
                if let editComment = sender as? RKComment {
                    controller.comment = editComment
                    controller.edit =  true
                } else if let editLink = sender as? RKLink {
                    controller.link = editLink
                    controller.edit = true
                }
                
                controller.delegate = self
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
        self.performSegueWithIdentifier("AddCommentSegue", sender: self)
    }
    
    // MARK: CommentCellDelegate
    
    func commentCell(cell: CommentCell, didShortRightSwipeForItem item: AnyObject) {
        let c: ErrorCompletion = {
            error in
            self.hud.hide(true)
            if error != nil {
                let alert = UIAlertController.errorAlertControllerWithMessage(error!.localizedDescription)
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                self.treeView.reloadRowsForItems([item], withRowAnimation: RATreeViewRowAnimation.init(0))
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
            self.hud.hide(true)
            if error != nil {
                let alert = UIAlertController.errorAlertControllerWithMessage(error!.localizedDescription)
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                self.treeView.reloadRowsForItems([item], withRowAnimation: RATreeViewRowAnimation.init(0))
            }
        }
        
        if let comment = item as? RKComment {
            RedditSession.sharedSession.upvote(comment, completion: c)
            LocalyticsSession.shared().tagEvent("Swipe upvote comment")
        } else if let link = item as? RKLink {
            RedditSession.sharedSession.upvote(link, completion: c)
            LocalyticsSession.shared().tagEvent("Swipe upvote")
        }
    }
    
    func commentCell(cell: CommentCell, didLongRightSwipeForItem item: AnyObject) {
        if let comment = item as? RKComment {
            let c: ErrorCompletion = {
                error in
                self.hud.hide(true)
                if error != nil {
                    let alert = UIAlertController.errorAlertControllerWithMessage(error!.localizedDescription)
                    self.presentViewController(alert, animated: true, completion: nil)
                } else {
                    self.treeView.reloadRowsForItems([item], withRowAnimation: RATreeViewRowAnimation.init(0))
                }
            }
            
            RedditSession.sharedSession.downvote(comment, completion: c)
            LocalyticsSession.shared().tagEvent("Swipe downvote comment")
        } else if let _ = item as? RKLink {
            LocalyticsSession.shared().tagEvent("Swipe share")
            
            let alert = UIAlertController.swipeShareAlertControllerWithLink(link) { (url, action) -> () in
                let objectsToShare = ["\(self.link.title) @myreddit", url]
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
    }
    
    func commentCell(cell: CommentCell, didLongLeftSwipeForItem item: AnyObject) {
        if let comment = item as? RKComment {
            self.commentMoreActions(cell, comment: comment)
        } else if let _ = item as? RKLink {
            self.linkMoreActions(cell)
        }
    }
    
    func commentCell(cell: CommentCell, didTapLink link: NSURL) {
        self.performSegueWithIdentifier("CommentLinkSegue", sender: link)
    }
    
    private func linkMoreActions(sourceView: AnyObject) {
        LocalyticsSession.shared().tagEvent("Swipe more")
        // More
        self.hud.hide(true)
        let alertController = UIAlertController(title: "Select options", message: nil, preferredStyle: .ActionSheet)
        
        alertController.addAction(UIAlertAction(title: "add comment", style: .Default, handler: { (action) -> Void in
            self.performSegueWithIdentifier("AddCommentSegue", sender: nil)
        }))
        
        alertController.addAction(UIAlertAction(title: "refresh", style: .Default, handler: { (action) -> Void in
            self.syncComments()
        }))
        
        alertController.addAction(UIAlertAction(title: "report", style: .Default, handler: { (action) -> Void in
            RedditSession.sharedSession.reportLink(self.link, completion: { (error) -> () in
                if error != nil {
                    let alert = UIAlertController.errorAlertControllerWithMessage(error!.localizedDescription)
                    self.presentViewController(alert, animated: true, completion: nil)
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
                        let alert = UIAlertController.errorAlertControllerWithMessage(error!.localizedDescription)
                        self.presentViewController(alert, animated: true, completion: nil)
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
        self.hud.hide(true)
        let alertController = UIAlertController(title: "Select comment options", message: nil, preferredStyle: .ActionSheet)
        
        alertController.addAction(UIAlertAction(title: "save", style: .Default, handler: { (action) -> Void in
            RedditSession.sharedSession.saveComment(comment, completion: { (error) -> () in
                // alert or do something else...
                if error != nil {
                    let alert = UIAlertController.errorAlertControllerWithMessage(error!.localizedDescription)
                    self.presentViewController(alert, animated: true, completion: nil)
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
                        let alert = UIAlertController.errorAlertControllerWithMessage(error!.localizedDescription)
                        self.presentViewController(alert, animated: true, completion: nil)
                    } else {
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
                    let alert = UIAlertController.errorAlertControllerWithMessage(error!.localizedDescription)
                    self.presentViewController(alert, animated: true, completion: nil)
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
                LocalyticsSession.shared().tagEvent("Edited comment failed")
            } else {
                if let _ = controller.comment {
                    LocalyticsSession.shared().tagEvent("Reply comment failed")
                } else {
                    LocalyticsSession.shared().tagEvent("Added comment failed")
                }
            }
        }
    }
    
    @IBAction func moreButtonTapped(sender: AnyObject) {
        self.linkMoreActions(sender)
    }
    
    func shareButtonTapped(sender: AnyObject) {
        LocalyticsSession.shared().tagEvent("Swipe share")
        
        let alert = UIAlertController.swipeShareAlertControllerWithLink(self.link) { (url, action) -> () in
            var objectsToShare = ["\(self.link.title) @myreddit", url]
            
            if self.link.hasImage() {
                if let urlString = self.link.urlForLink() {
                    if let url = NSURL(string: urlString) {
                        let downloader = SDWebImageDownloader.sharedDownloader()
                        downloader.downloadImageWithURL(url, options: .ContinueInBackground, progress: { (r, r1) -> Void in
                            
                        }, completed: { (image, data, error, s) -> Void in
                            if let downloadedImage = image {
                                objectsToShare = [downloadedImage]
                            } else {
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    let alert = UIAlertController(title: "Error!",
                                        message: "Unable to download image!",
                                        preferredStyle: .Alert)
                                    self.presentViewController(alert, animated: true, completion: nil)
                                })
                            }
                        })
                    }
                }
            }
            
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            if let popoverController = activityVC.popoverPresentationController {
                if let button = sender as? UIBarButtonItem {
                    popoverController.barButtonItem = button
                }
            }
            
            activityVC.present(animated: true, completion: nil)
            
            LocalyticsSession.shared().tagEvent("Share tapped")
        }
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func preferredAppearance() {
    
        self.treeView.backgroundColor = MyRedditBackgroundColor
        
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
        
        // iPad
        if let _ = self.splitViewController {
            self.navigationController?.setToolbarHidden(false, animated: false)
        }
        
        self.treeView.reloadData()
    }
}
