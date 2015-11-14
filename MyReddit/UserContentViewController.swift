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
JZSwipeCellDelegate,
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
        
        self.tableView.reloadData()
        
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
        } else if let comment = self.content[indexPath.row] as? RKComment {
            return self.heightForComment(comment)
        }
        
        return 0
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
    
    private func heightForComment(comment: RKComment) -> CGFloat {
 
        let frame = CGRectMake(0, 0, (self.tableView.frame.size.width - 18) - 15, CGFloat.max)
        let label: UILabel = UILabel(frame: frame)
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.font = MyRedditCommentTextFont
        label.text = comment.body
        label.sizeToFit()
        
        return label.frame.height + 60
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
                    imageCell.delegate = self
                    return imageCell
                }
                
            } else {
                cell = tableView.dequeueReusableCellWithIdentifier("TitleCell") as! TitleCell
            }
            
            cell.link = link
        } else if let comment = self.content[indexPath.row] as? RKComment {
            let cell = tableView.dequeueReusableCellWithIdentifier("CommentCell") as! CommentCell
            cell.indentationLevel = 1
            cell.indentationWidth = 15
            cell.commentTextView.userInteractionEnabled = false
            cell.configueForComment(comment: comment, isLinkAuthor: true)
            cell.delegate = self
            return cell
        }
        
        cell.delegate = self
        
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
    
    // MARK: JZSwipeCellDelegate
    
    func swipeCell(cell: JZSwipeCell!, triggeredSwipeWithType swipeType: JZSwipeType) {
        if swipeType.rawValue != JZSwipeTypeNone.rawValue {
            cell.reset()
            if let indexPath = self.tableView.indexPathForCell(cell) {
                if let link = self.content[indexPath.row] as? RKLink  {
                    if !SettingsManager.defaultManager.purchased {
                        if swipeType.rawValue == JZSwipeTypeLongLeft.rawValue {
                            LocalyticsSession.shared().tagEvent("Swipe comments")
                            self.performSegueWithIdentifier("CommentsSegue", sender: link)
                        } else {
                            self.performSegueWithIdentifier("PurchaseSegue", sender: self)
                        }
                    } else {
                        if let indexPath = self.tableView.indexPathForCell(cell) {
                            if let link = self.content[indexPath.row] as? RKLink  {
                                let postCell = cell as! PostCell
                                self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                                if swipeType.rawValue == JZSwipeTypeShortLeft.rawValue {
                                    // Upvote
                                    self.upvote(link)
                                    postCell.upvote()
                                } else if swipeType.rawValue == JZSwipeTypeShortRight.rawValue {
                                    // Downvote
                                    self.downvote(link)
                                    postCell.downvote()
                                } else if swipeType.rawValue == JZSwipeTypeLongLeft.rawValue {
                                    LocalyticsSession.shared().tagEvent("Swipe comments")
                                    self.performSegueWithIdentifier("CommentsSegue", sender: link)
                                } else {
                                    // Share
                                    self.hud.hide(true)
                                    self.optionsController = LinkShareOptionsViewController(link: link)
                                    self.optionsController.sourceView = cell
                                    self.optionsController.showInView(self.view)
                                    
                                    // More
                                    
                                    LocalyticsSession.shared().tagEvent("Swipe more")
                                    
                                    self.hud.hide(true)
                                    let alertController = UIAlertController(title: "Select option", message: nil, preferredStyle: .ActionSheet)
                                    
                                    if link.saved() {
                                        alertController.addAction(UIAlertAction(title: "unsave", style: .Default, handler: { (action) -> Void in
                                            RedditSession.sharedSession.unSaveLink(link, completion: { (error) -> () in
                                                self.hud.hide(true)
                                                link.unSaveLink()
                                            })
                                        }))
                                    } else {
                                        alertController.addAction(UIAlertAction(title: "save", style: .Default, handler: { (action) -> Void in
                                            LocalyticsSession.shared().tagEvent("Save")
                                            RedditSession.sharedSession.saveLink(link, completion: { (error) -> () in
                                                self.hud.hide(true)
                                                link.saveLink()
                                            })
                                        }))
                                    }
                                    
                                    if link.isHidden() {
                                        if self.category != .Submissions {
                                            RedditSession.sharedSession.unHideLink(link, completion: { (error) -> () in
                                                self.hud.hide(true)
                                                link.unHideink()
                                                
                                                if self.category == .Hidden {
                                                    alertController.addAction(UIAlertAction(title: "unhide", style: .Default, handler: { (action) -> Void in
                                                        RedditSession.sharedSession.unHideLink(link, completion: { (error) -> () in
                                                            self.hud.hide(true)
                                                            link.unHideink()
                                                            
                                                            self.content.removeAtIndex(indexPath.row)
                                                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                                                self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
                                                            })
                                                        })
                                                    }))
                                                }
                                            })
                                        }
                                    } else {
                                        if self.category != .Submissions {
                                            alertController.addAction(UIAlertAction(title: "hide", style: .Default, handler: { (action) -> Void in
                                                RedditSession.sharedSession.hideLink(link, completion: { (error) -> () in
                                                    self.hud.hide(true)
                                                    link.hideLink()
                                                    
                                                    self.content.removeAtIndex(indexPath.row)
                                                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                                        self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
                                                    })
                                                })
                                            }))
                                        }
                                    }
                                    
                                    alertController.addAction(UIAlertAction(title: "more options", style: .Default, handler: { (action) -> Void in
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
                            } else if let comment = self.content[indexPath.row] as? RKComment {
                                self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                                
                                if swipeType.rawValue == JZSwipeTypeShortRight.rawValue || swipeType.rawValue == JZSwipeTypeLongRight.rawValue {
                                    LocalyticsSession.shared().tagEvent("Swipe downvote comment")
                                    // Downvote
                                    RedditSession.sharedSession.downvote(comment, completion: { (error) -> () in
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
                                } else if swipeType.rawValue == JZSwipeTypeShortLeft.rawValue || swipeType.rawValue == JZSwipeTypeLongLeft.rawValue {
                                    // Upvote
                                    LocalyticsSession.shared().tagEvent("Swipe upvote comment")
                                    RedditSession.sharedSession.upvote(comment, completion: { (error) -> () in
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
                                    self.hud.hide(true)
                                }
                            }
                        }
                    }

                }
            }
        }
    }
    
    func swipeCell(cell: JZSwipeCell!, swipeTypeChangedFrom from: JZSwipeType, to: JZSwipeType) {
        
    }
    
    // MARK: Private
    
    private func downvote(link: RKLink) {
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
    
    private func upvote(link: RKLink) {
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
    
    override func preferredAppearance() {
        self.navigationController?.navigationBar.backgroundColor = MyRedditBackgroundColor
        self.navigationController?.navigationBar.barTintColor = MyRedditBackgroundColor
        self.navigationController?.navigationBar.tintColor = MyRedditLabelColor
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : MyRedditLabelColor]
        
        self.tableView.backgroundColor = MyRedditDarkBackgroundColor
        
        self.tableView.reloadData()
    }
}
