//
//  UserContentViewController.swift
//  MyReddit
//
//  Created by Nick Lanasa on 5/1/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation
import UIKit

class UserContentViewController: UIViewController,
UITableViewDelegate,
UITableViewDataSource,
JZSwipeCellDelegate,
LoadMoreHeaderDelegate {
    
    var category: RKUserContentCategory!
    var categoryTitle: String!
    var pagination: RKPagination?
    var content = Array<AnyObject>()
    var optionsController: LinkShareOptionsViewController!
    var selectedLink: RKLink!
    var user: RKUser!
    
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
        if let cell =  self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1)) as? LoadMoreHeader {
            cell.startAnimating()
            UserSession.sharedSession.userContent(self.user,
                category: self.category,
                pagination: self.pagination,
                completion: { (pagination, results, error) -> () in
                self.pagination = pagination
                if let moreContent = results {
                    self.content.extend(moreContent)
                }
                
                if self.content.count == 25 || self.content.count == 0 {
                    self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
                } else {
                    self.tableView.reloadData()
                }
                
                cell.stopAnimating()
            })
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return 1
        }
        
        return content.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.section == 1 {
            return 60
        }
        
        if let link = self.content[indexPath.row] as? RKLink {
            if link.isImageLink() || link.media != nil || link.domain == "imgur.com" {
                
                if indexPath.row == 0 || SettingsManager.defaultManager.valueForSetting(.FullWidthImages) {
                    return self.heightForLink(link)
                }
                
                return 392
                
            } else {
                return self.heightForLink(link)
            }
        } else if let comment = self.content[indexPath.row] as? RKComment {
            return self.heightForComment(comment)
        }
        
        return 0
    }
    
    private func heightForLink(link: RKLink) -> CGFloat {
        
        var title = link.title.stringByReplacingOccurrencesOfString("&gt;", withString: ">", options: nil, range: nil)
        
        var parsedString = NSMutableAttributedString(string: "\(title)")
        var frame = CGRectMake(0, 0, self.tableView.frame.size.width - 30, CGFloat.max)
        let label: UILabel = UILabel(frame: frame)
        label.numberOfLines = 0
        label.font = MyRedditSelfTextFont
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.attributedText = parsedString
        label.sizeToFit()
        
        return label.frame.size.height + 60
    }
    
    private func heightForComment(comment: RKComment) -> CGFloat {
 
        var frame = CGRectMake(0, 0, (self.tableView.frame.size.width - 18) - 15, CGFloat.max)
        let label: UILabel = UILabel(frame: frame)
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.font = MyRedditCommentTextFont
        label.text = comment.body
        label.sizeToFit()
        
        return label.frame.height + 60
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        if indexPath.section == 1 {
            var cell =  tableView.dequeueReusableCellWithIdentifier("LoadMoreHeader") as! LoadMoreHeader
            cell.delegate = self
            cell.loadMoreButton.hidden = false
            return cell
        }
        
        var cell = tableView.dequeueReusableCellWithIdentifier("PostImageCell") as! PostCell
        
        if let link = self.content[indexPath.row] as? RKLink {
            if link.isImageLink() || link.media != nil || link.domain == "imgur.com" {
                cell = tableView.dequeueReusableCellWithIdentifier("PostImageCell") as! PostImageCell
                
                if indexPath.row == 0 || SettingsManager.defaultManager.valueForSetting(.FullWidthImages) {
                    cell = tableView.dequeueReusableCellWithIdentifier("TitleCell") as! TitleCell
                }
                
            } else {
                cell = tableView.dequeueReusableCellWithIdentifier("TitleCell") as! TitleCell
            }
            
            cell.link = link
        } else if let comment = self.content[indexPath.row] as? RKComment {
            var cell = tableView.dequeueReusableCellWithIdentifier("CommentCell") as! CommentCell
            cell.indentationLevel = 1
            cell.indentationWidth = 15
            cell.configueForComment(comment: comment, isLinkAuthor: true)
            cell.delegate = self
            return cell
        }
        
        cell.delegate = self
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.section == 0 {
            if let link = self.content[indexPath.row] as? RKLink {
                self.selectedLink = link
                if link.selfPost {
                    self.performSegueWithIdentifier("CommentsSegue", sender: link)
                } else {
                    if link.domain == "imgur.com" || link.isImageLink() {
                        if link.domain == "imgur.com" && !link.URL.absoluteString!.hasExtension() {
                            var urlComponents = link.URL.absoluteString?.componentsSeparatedByString("/")
                            if urlComponents?.count > 4 {
                                let albumID = urlComponents?[4]
                                IMGAlbumRequest.albumWithID(albumID, success: { (album) -> Void in
                                    self.performSegueWithIdentifier("GallerySegue", sender: album.images)
                                    }) { (error) -> Void in
                                        self.performSegueWithIdentifier("SubredditLink", sender: link)
                                }
                            } else {
                                if urlComponents?.count > 3 {
                                    let imageID = urlComponents?[3]
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
                if self.category == .Overview {
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
                } else {
                    self.performSegueWithIdentifier("CommentsSegue", sender: comment)
                }
            }
        }
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
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
            if let comment = sender as? RKComment {
                if let nav = segue.destinationViewController as? UINavigationController {
                    if let controller = nav.viewControllers[0] as? CommentsViewController {
                        // TODO: get link for comment
                        //RedditSession.sharedSession.linkWithFullName(<#link: RKLink#>, completion: <#PaginationCompletion##(pagination: RKPagination?, results: [AnyObject]?, error: NSError?) -> ()#>)
                    }
                }
            } else if let link = sender as? RKLink {
                if let nav = segue.destinationViewController as? UINavigationController {
                    if let controller = nav.viewControllers[0] as? CommentsViewController {
                        controller.link = link
                    }
                }
            }
        }
    }
    
    func swipeCell(cell: JZSwipeCell!, triggeredSwipeWithType swipeType: JZSwipeType) {
        if swipeType.value != JZSwipeTypeNone.value {
            cell.reset()
            if !SettingsManager.defaultManager.purchased {
                self.performSegueWithIdentifier("PurchaseSegue", sender: self)
            } else {
                if let indexPath = self.tableView.indexPathForCell(cell) {
                    if let link = self.content[indexPath.row] as? RKLink  {
                        self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                        if swipeType.value == JZSwipeTypeShortLeft.value {
                            // Upvote
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
                        } else if swipeType.value == JZSwipeTypeShortRight.value {
                            // Downvote
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
                        } else if swipeType.value == JZSwipeTypeLongLeft.value {
                            // More
                            
                            LocalyticsSession.shared().tagEvent("Swipe more")
                            
                            self.hud.hide(true)
                            var alertController = UIAlertController(title: "Select option", message: nil, preferredStyle: .ActionSheet)
                            
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
                            
                            alertController.addAction(UIAlertAction(title: "see comments", style: .Default, handler: { (action) -> Void in
                                LocalyticsSession.shared().tagEvent("Swipe comments")
                                self.performSegueWithIdentifier("CommentsSegue", sender: link)
                            }))
                            
                            alertController.addAction(UIAlertAction(title: "cancel", style: .Cancel, handler: nil))
                            
                            if let popoverController = alertController.popoverPresentationController {
                                popoverController.sourceView = cell
                                popoverController.sourceRect = cell.bounds
                            }
                            
                            alertController.present(animated: true, completion: nil)
                        } else {
                            // Share
                            self.hud.hide(true)
                            self.optionsController = LinkShareOptionsViewController(link: link)
                            self.optionsController.sourceView = cell
                            self.optionsController.showInView(self.view)
                        }
                    } else if let comment = self.content[indexPath.row] as? RKComment {
                        self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                        
                        if swipeType.value == JZSwipeTypeShortRight.value || swipeType.value == JZSwipeTypeLongRight.value {
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
                        } else if swipeType.value == JZSwipeTypeShortLeft.value || swipeType.value == JZSwipeTypeLongLeft.value {
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
    
    func swipeCell(cell: JZSwipeCell!, swipeTypeChangedFrom from: JZSwipeType, to: JZSwipeType) {
        
    }
    
    func loadMoreHeader(header: LoadMoreHeader, didTapButton sender: AnyObject) {
        if self.pagination != nil {
            self.syncContent()
        } else {
            self.tableView.reloadData()
            header.stopAnimating()
        }
    }
}