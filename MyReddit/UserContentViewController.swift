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
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.syncContent()
        
        self.navigationItem.title = self.categoryTitle
    }
    
    private func syncContent() {
        UserSession.sharedSession.userContent(self.category, pagination: self.pagination) { (pagination, results, error) -> () in
            
            self.pagination = pagination
            if let moreContent = results {
                self.content.extend(moreContent)
            }
            
            if self.content.count == 25 || self.content.count == 0 {
                self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
            } else {
                self.tableView.reloadData()
            }
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
            if self.category == .Overview {
                cell = tableView.dequeueReusableCellWithIdentifier("TitleCell") as! TitleCell
                cell.linkComment = comment
            } else {
                var cell = tableView.dequeueReusableCellWithIdentifier("CommentCell") as! CommentCell
                cell.comment = comment
                cell.delegate = self
                return cell
            }
        }
        
        cell.delegate = self
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.section == 2 {
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SubredditLink" {
            if let link = sender as? RKLink {
                if let controller = segue.destinationViewController as? LinkViewController {
                    controller.link = link
                }
            }
        } else {
            if let comment = sender as? RKComment {
                if let controller = segue.destinationViewController as? CommentsViewController {
                    controller.comment = comment
                    controller.forComment = true
                }
            } else if let link = sender as? RKLink {
                if let controller = segue.destinationViewController as? CommentsViewController {
                    controller.link = link
                    controller.forComment = false
                }
            }
        }
    }
    
    func swipeCell(cell: JZSwipeCell!, triggeredSwipeWithType swipeType: JZSwipeType) {
        if swipeType.value != JZSwipeTypeNone.value {
            cell.reset()
//            if NSUserDefaults.standardUserDefaults().objectForKey("purchased") == nil {
//                self.performSegueWithIdentifier("PurchaseSegue", sender: self)
//            } else {
//                
//                self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
//                
//                if let indexPath = self.tableView.indexPathForCell(cell) {
//                    if let link = self.links[indexPath.row] as? RKLink {
//                        if swipeType.value == JZSwipeTypeShortLeft.value {
//                            // Upvote
//                            RedditSession.sharedSession.upvote(link, completion: { (error) -> () in
//                                self.hud.hide(true)
//                                
//                                if error != nil {
//                                    UIAlertView(title: "Error!",
//                                        message: "Unable to upvote! Please try again!",
//                                        delegate: self,
//                                        cancelButtonTitle: "Ok").show()
//                                } else {
//                                    self.syncLinks(self.currentCategory)
//                                }
//                            })
//                        } else if swipeType.value == JZSwipeTypeShortRight.value {
//                            // Downvote
//                            RedditSession.sharedSession.downvote(link, completion: { (error) -> () in
//                                self.hud.hide(true)
//                                
//                                if error != nil {
//                                    UIAlertView(title: "Error!",
//                                        message: "Unable to downvote! Please try again!",
//                                        delegate: self,
//                                        cancelButtonTitle: "Ok").show()
//                                } else {
//                                    self.syncLinks(self.currentCategory)
//                                }
//                            })
//                        }
//                    }
//                }
//            }
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