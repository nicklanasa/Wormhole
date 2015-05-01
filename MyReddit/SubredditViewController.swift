//
//  SubredditViewController.swift
//  MyReddit
//
//  Created by Nick Lanasa on 3/25/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation
import UIKit
import CoreData

let HeaderHeight: CGFloat = 300.0

enum FilterSwitchType: Int {
    case Hot
    case New
    case Rising
    case Controversial
    case Top
}

class SubredditViewController: UIViewController,
UITableViewDataSource,
UITableViewDelegate,
NSFetchedResultsControllerDelegate,
LoadMoreHeaderDelegate,
UIGestureRecognizerDelegate,
GHContextOverlayViewDataSource,
GHContextOverlayViewDelegate,
JZSwipeCellDelegate,
SearchViewControllerDelegate {
    
    var subreddit: Subreddit!
    var front = true
    var pagination: RKPagination?
    var pageIndex: Int!
    var currentCategory: RKSubredditCategory?
    var contextMenu: GHContextMenuView!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var headerImage: UIImageView!
    @IBOutlet weak var subscribeButton: UIBarButtonItem!
    
    @IBOutlet weak var filterView: UIView! {
        didSet {
            filterView.layer.shadowColor = UIColor.blackColor().CGColor
            filterView.layer.shadowOffset = CGSize(width: 10, height: 15)
            filterView.layer.shadowOpacity = 0.8
            filterView.layer.shadowRadius = 30
        }
    }
    
    var hud: MBProgressHUD! {
        didSet {
            hud.labelFont = MyRedditSelfTextFont
            hud.mode = .Indeterminate
            hud.labelText = "Loading"
        }
    }
    
    @IBOutlet weak var filterViewBottomConstraint: NSLayoutConstraint!
    
    var links = Array<AnyObject>() {
        didSet {
            if self.links.count == 25 || self.links.count == 0 {
                self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
            } else {
                self.tableView.reloadData()
            }
            
            var foundImage = false
            if let post = self.links.first as? RKLink {
                if post.isImageLink() {
                    self.headerImage.sd_setImageWithURL(post.URL)
                    self.displayHeader(true)
                } else if let media = post.media {
                    self.headerImage.sd_setImageWithURL(media.thumbnailURL)
                    self.displayHeader(true)
                } else if post.domain == "imgur.com" {
                    if let absoluteString = post.URL.absoluteString {
                        var stringURL = absoluteString + ".jpg"
                        var imageURL = NSURL(string: stringURL)
                        self.headerImage.sd_setImageWithURL(imageURL, placeholderImage: UIImage(), completed: { (image, error, cacheType, url) -> Void in
                            if error != nil {
                                self.displayHeader(false)
                            } else {
                                self.displayHeader(true)
                            }
                        })
                    }
                } else {
                    self.displayHeader(false)
                }
            }
        }
    }
    
    private func displayHeader(foundImage: Bool) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if !foundImage {
                self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
                self.headerImage.removeFromSuperview()
            } else {
                self.tableView.contentInset = UIEdgeInsetsMake(HeaderHeight, 0, 0, 0)
                self.tableView.addSubview(self.headerImage)
                self.headerImage.frame = CGRectMake(0, -HeaderHeight, UIScreen.mainScreen().bounds.size.width, HeaderHeight)
            }
        })
    }
    
    @IBAction func filterButtonTapped(sender: AnyObject) {
        if let filterButton = sender as? UIButton {
            self.pagination = nil
            
            self.links = Array<AnyObject>()
            
            if let type = FilterSwitchType(rawValue: filterButton.tag) {
                self.currentCategory = RKSubredditCategory(rawValue: UInt(type.rawValue))
                
                self.filterViewCloseButtonPressed(sender)
                
                self.syncLinks()
            }
        }
    }
    
    @IBAction func filterViewCloseButtonPressed(sender: AnyObject) {
        self.filterViewBottomConstraint.constant += 330
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.view.layoutIfNeeded()
            
            self.navigationItem.rightBarButtonItem?.enabled = true
        })
    }
    
    @IBAction func filterButtonPressed(sender: AnyObject) {
        self.filterViewBottomConstraint.constant -= 330
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.view.layoutIfNeeded()
            
            self.navigationItem.rightBarButtonItem?.enabled = false
        })
    }
    
    @IBAction func subscribeButtonTapped(sender: AnyObject) {
        if self.subreddit.subscriber.boolValue {
            RedditSession.sharedSession.unsubscribe(subreddit, completion: { (error) -> () in
                if error != nil {
                    UIAlertView(title: "Error!", message: "Unable to unsubscribe to Subreddit. Please make sure you are connected to the internets.", delegate: self, cancelButtonTitle: "Ok").show()
                } else {
                    DataManager.manager.datastore.mainQueueContext.deleteObject(self.subreddit)
                    self.front = true
                    self.currentCategory = nil
                    self.syncLinks()
                }
            })
        } else {
            RedditSession.sharedSession.subscribe(self.subreddit, completion: { (error) -> () in
                if error != nil {
                    UIAlertView(title: "Error!", message: "Unable to subscribe to Subreddit. Please make sure you are connected to the internets.", delegate: self, cancelButtonTitle: "Ok").show()
                } else {
                    self.updateSubscribeButton()
                }
            })
        }
    }
    
    override func viewDidLoad() {
        self.syncLinks()
        
        self.contextMenu = GHContextMenuView()
        self.contextMenu.delegate = self
        self.contextMenu.dataSource = self
        
        var long = UILongPressGestureRecognizer(target: self.contextMenu, action: "longPressDetected:")
        self.view.gestureRecognizers = [long]
    }
    
    override func viewWillAppear(animated: Bool) {
        self.updateSubscribeButton()
    }
    
    private func updateSubscribeButton() {
        if front {
            self.subscribeButton.title = ""
        } else {
            if self.subreddit.subscriber.boolValue {
                self.subscribeButton.title = "Unsubscribe"
                self.subscribeButton.tintColor = MyRedditDownvoteColor
            } else {
                self.subscribeButton.title = "Subscribe"
                self.subscribeButton.tintColor = MyRedditUpvoteColor
            }
        }
    }
    
    func imageForItemAtIndex(index: Int) -> UIImage! {
        if index == 0 {
            return UIImage(named: "Up")
        } else {
            return UIImage(named: "Down")
        }
    }
    
    func numberOfMenuItems() -> Int {
        return 2
    }
    
    func didSelectItemAtIndex(selectedIndex: Int, forMenuAtPoint point: CGPoint) {
        
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if self.filterViewBottomConstraint.constant < 636 {
            self.filterViewCloseButtonPressed(scrollView)
        }
        
        var yOffset: CGFloat = scrollView.contentOffset.y
        if yOffset < -HeaderHeight {
            var f = self.headerImage.frame
            f.origin.y = yOffset
            f.size.height =  -yOffset
            self.headerImage.frame = f
        }
    }
    
    private func syncLinks() {
        
        var title = front ? "Front" : "/r/\(subreddit.name)"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: title, style: .Plain, target: self, action: nil)
        self.navigationController?.navigationBarHidden = false
        
        self.navigationItem.title = ""
        
        self.navigationItem.leftBarButtonItem!.setTitleTextAttributes([
            NSFontAttributeName: MyRedditTitleBigFont],
            forState: UIControlState.Normal)
        
        self.tableView.reloadData()
        if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as? LoadMoreHeader {
            cell.startAnimating()
            
            self.fetchLinks({ () -> () in
                cell.stopAnimating()
            })
        }

        self.navigationItem.rightBarButtonItem?.enabled = true
    }
    
    private func fetchLinks(completion: () -> ()) {
        if front {
            DataManager.manager.syncFrontPageLinks(self.pagination, category: self.currentCategory, completion: { (pagination, results, error) -> () in
                self.pagination = pagination
                if let moreLinks = results {
                    self.links.extend(moreLinks)
                }
                
                completion()
            })
        } else {
            DataManager.manager.syncLinksSubreddit(self.subreddit, category: self.currentCategory, pagination: self.pagination, completion: { (pagination, results, error) -> () in
                self.pagination = pagination
                if let moreLinks = results {
                    self.links.extend(moreLinks)
                }
                
                completion()
            })
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return 1
        }
        
        return self.links.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
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
        
        if let link = self.links[indexPath.row] as? RKLink {
            if link.isImageLink() || link.media != nil || link.domain == "imgur.com" {
                cell = tableView.dequeueReusableCellWithIdentifier("PostImageCell") as! PostImageCell
                
                if indexPath.row == 0 {
                    cell = tableView.dequeueReusableCellWithIdentifier("TitleCell") as! TitleCell
                }
                
            } else {
                cell = tableView.dequeueReusableCellWithIdentifier("TitleCell") as! TitleCell
            }
            
            cell.link = link
        }

        cell.delegate = self
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.section == 0 {
            if let link = self.links[indexPath.row] as? RKLink {
                if link.selfPost {
                    self.performSegueWithIdentifier("CommentsSegue", sender: link)
                } else {
                    self.performSegueWithIdentifier("SubredditLink", sender: link)
                }
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SubredditImageLink" || segue.identifier == "SubredditLink" {
            if let link = sender as? RKLink {
                if let controller = segue.destinationViewController as? LinkViewController {
                    controller.link = link
                }
            }
        } else if segue.identifier == "SearchSegue" {
            if let nav = segue.destinationViewController as? UINavigationController {
                if let controller = nav.viewControllers[0] as? SearchViewController {
                    controller.delegate = self
                }
            }
        } else {
            if let link = sender as? RKLink {
                if let controller = segue.destinationViewController as? CommentsViewController {
                    controller.link = link
                }
            }
        }
    }
    
    func loadMoreHeader(header: LoadMoreHeader, didTapButton sender: AnyObject) {
        if let button = sender as? UIButton {
            button.hidden = true
            header.activityIndicator.hidden = false
            header.activityIndicator.startAnimating()
            
            if self.pagination != nil {
                self.fetchLinks({ () -> () in
                    
                })
            } else {
                self.tableView.reloadData()
            }
        }
    }
    
    func swipeCell(cell: JZSwipeCell!, triggeredSwipeWithType swipeType: JZSwipeType) {
        if swipeType.value != JZSwipeTypeNone.value {
            cell.reset()
            if NSUserDefaults.standardUserDefaults().objectForKey("purchased") == nil {
                self.performSegueWithIdentifier("PurchaseSegue", sender: self)
            } else {
                
                self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                
                if let indexPath = self.tableView.indexPathForCell(cell) {
                    if let link = self.links[indexPath.row] as? RKLink {
                        if swipeType.value == JZSwipeTypeShortLeft.value {
                            // Upvote
                            RedditSession.sharedSession.upvote(link, completion: { (error) -> () in
                                self.hud.hide(true)
                                
                                if error != nil {
                                    UIAlertView(title: "Error!",
                                        message: "Unable to upvote! Please try again!",
                                        delegate: self,
                                        cancelButtonTitle: "Ok").show()
                                } else {
                                    self.syncLinks()
                                }
                            })
                        } else if swipeType.value == JZSwipeTypeShortRight.value {
                            // Downvote
                            RedditSession.sharedSession.downvote(link, completion: { (error) -> () in
                                self.hud.hide(true)
                                
                                if error != nil {
                                    UIAlertView(title: "Error!",
                                        message: "Unable to downvote! Please try again!",
                                        delegate: self,
                                        cancelButtonTitle: "Ok").show()
                                } else {
                                    self.syncLinks()
                                }
                            })
                        }
                    }
                }
            }
        }
    }
    
    func swipeCell(cell: JZSwipeCell!, swipeTypeChangedFrom from: JZSwipeType, to: JZSwipeType) {
        
    }
    
    func searchViewController(controller: SearchViewController, didTapSubreddit subreddit: Subreddit) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.front = false
            self.links = Array<AnyObject>()
            self.subreddit = subreddit
            self.updateSubscribeButton()
            self.currentCategory = nil
            self.pagination = nil
            self.syncLinks()
        })
    }
}