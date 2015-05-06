//
//  UserContentViewController.swift
//  MyReddit
//
//  Created by Nick Lanasa on 5/1/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation
import UIKit

class UserContentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, JZSwipeCellDelegate, LoadMoreHeaderDelegate {
    
    var category: RKUserContentCategory!
    var categoryTitle: String!
    var pagination: RKPagination?
    var content = Array<AnyObject>()
    
    var user: RKUser!
    
    var hud: MBProgressHUD! {
        didSet {
            hud.labelFont = MyRedditSelfTextFont
            hud.mode = .Indeterminate
            hud.labelText = "Loading"
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.reloadData()
        self.syncContent()
        
        self.navigationItem.title = self.categoryTitle.lowercaseString
        self.tableView.backgroundColor = MyRedditBackgroundColor
        
        self.tableView.tableFooterView = UIView()
    }
    
    private func syncContent() {
        if let cell =  self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1)) as? LoadMoreHeader {
            cell.startAnimating()
            UserSession.sharedSession.userContent(self.user, category: self.category, pagination: self.pagination, completion: { (pagination, results, error) -> () in
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
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 500
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        if indexPath.section == 1 {
            var cell =  tableView.dequeueReusableCellWithIdentifier("LoadMoreHeader") as! LoadMoreHeader
            cell.delegate = self
            
            cell.activityIndicator.hidden = true
            cell.loadMoreButton.hidden = false
            
            return cell
        }
        
        var cell = tableView.dequeueReusableCellWithIdentifier("PostImageCell") as! PostCell
        
        if let link = self.content[indexPath.row] as? RKLink {
            if link.isImageLink() || link.media != nil || link.domain == "imgur.com" {
                cell = tableView.dequeueReusableCellWithIdentifier("PostImageCell") as! PostImageCell
                
                if indexPath.row == 0 {
                    cell = tableView.dequeueReusableCellWithIdentifier("TitleCell") as! TitleCell
                }
                
            } else {
                cell = tableView.dequeueReusableCellWithIdentifier("TitleCell") as! TitleCell
            }
            
            cell.link = link
        } else if let comment = self.content[indexPath.row] as? RKComment {
            var cell = tableView.dequeueReusableCellWithIdentifier("CommentCell") as! CommentCell
            cell.comment = comment
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
                if link.selfPost {
                    self.performSegueWithIdentifier("CommentsSegue", sender: link)
                } else {
                    self.performSegueWithIdentifier("SubredditLink", sender: link)
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
        } else {
            if let comment = sender as? RKComment {
                if let nav = segue.destinationViewController as? UINavigationController {
                    if let controller = nav.viewControllers[0] as? CommentsViewController {
                        controller.comment = comment
                        controller.forComment = true
                    }
                }
            } else if let link = sender as? RKLink {
                if let nav = segue.destinationViewController as? UINavigationController {
                    if let controller = nav.viewControllers[0] as? CommentsViewController {
                        controller.link = link
                        controller.forComment = false
                    }
                }
            }
        }
    }
    
    func swipeCell(cell: JZSwipeCell!, triggeredSwipeWithType swipeType: JZSwipeType) {
        if swipeType.value != JZSwipeTypeNone.value {
            cell.reset()
            if let indexPath = self.tableView.indexPathForCell(cell) {
                if let link = self.content[indexPath.row] as? RKLink  {
                    self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                    if swipeType.value == JZSwipeTypeShortLeft.value {
                        // Upvote
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
                                
                                if self.category == .Hidden {
                                    self.content.removeAtIndex(indexPath.row)
                                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                        self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
                                    })
                                }
                            })
                        } else {
                            RedditSession.sharedSession.hideLink(link, completion: { (error) -> () in
                                self.hud.hide(true)
                                link.hideLink()
                                self.content.removeAtIndex(indexPath.row)
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
                                })
                            })
                        }
                    }
                } else if let comment = self.content[indexPath.row] as? RKComment {
                    self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                    
                    if swipeType.value == JZSwipeTypeShortRight.value || swipeType.value == JZSwipeTypeLongRight.value {
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
    
    func swipeCell(cell: JZSwipeCell!, swipeTypeChangedFrom from: JZSwipeType, to: JZSwipeType) {
        
    }
    
    func loadMoreHeader(header: LoadMoreHeader, didTapButton sender: AnyObject) {
        if let button = sender as? UIButton {
            
            button.hidden = true
            header.activityIndicator.hidden = false
            header.activityIndicator.startAnimating()
            
            if self.pagination != nil {
                self.syncContent()
            } else {
                self.tableView.reloadData()
            }
        }
    }
}