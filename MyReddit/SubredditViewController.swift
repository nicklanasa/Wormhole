//
//  SubredditViewController.swift
//  MyReddit
//
//  Created by Nick Lanasa on 3/25/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation
import UIKit
import MBProgressHUD
import GoogleMobileAds
import SafariServices

class SubredditViewController: SubredditRootViewController,
UITableViewDataSource,
UITableViewDelegate,
UIGestureRecognizerDelegate,
PostCellDelegate {
    
    let ad = GADBannerView(adSize: kGADAdSizeFluid)
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        self.tableView.estimatedRowHeight = 80.0
        self.tableView.rowHeight = UITableViewAutomaticDimension

        UserSession.sharedSession.openSessionWithCompletion { (error) -> () in
            self.fetchLinks()
        }
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: "longPress:")
        self.view.addGestureRecognizer(longPressRecognizer)
    }
    
    func longPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        if longPressGestureRecognizer.state == UIGestureRecognizerState.Began {
            let touchPoint = longPressGestureRecognizer.locationInView(self.view)
            if let indexPath = self.tableView.indexPathForRowAtPoint(touchPoint) {
                // Long hold options
                if let link = self.links?[indexPath.row] as? RKLink {
                    let alert = UIAlertController.longHoldAlertControllerWithLink(link, completion: { (action) -> () in
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                            hud.labelFont = MyRedditSelfTextFont
                            hud.mode = .Text
                            hud.labelText = "copied!"
                            
                            hud.hide(true, afterDelay: 0.3)
                        })
                    })
                    
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    // MARK: Private
    
    override func updateUI() {
        
        super.updateUI()
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.updateSubscribeButton()
            self.filterButton.tintColor = MyRedditLabelColor
            self.listButton.tintColor = MyRedditLabelColor
            self.postButton.tintColor = MyRedditLabelColor
            self.searchButton.tintColor = MyRedditLabelColor
            self.messages.tintColor = MyRedditLabelColor
        })
        
        self.fetchUnread()
    }
    
    // MARK: IBActions
    
    @IBAction func filterButtonPressed(sender: AnyObject) {
        
        let alert = UIAlertController(title: "Select filter", message: nil, preferredStyle: .ActionSheet)
        
        alert.addAction(UIAlertAction(title: "hot", style: .Default, handler: { (action) -> Void in
            self.filterLinks(.Hot)
        }))
        
        alert.addAction(UIAlertAction(title: "new", style: .Default, handler: { (action) -> Void in
            self.filterLinks(.New)
        }))
        
        alert.addAction(UIAlertAction(title: "rising", style: .Default, handler: { (action) -> Void in
            self.filterLinks(.Rising)
        }))
        
        alert.addAction(UIAlertAction(title: "controversial", style: .Default, handler: { (action) -> Void in
            self.filterLinks(.Controversial)
        }))
        
        alert.addAction(UIAlertAction(title: "top", style: .Default, handler: { (action) -> Void in
            self.filterLinks(.Top)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.barButtonItem = self.filterButton
        }
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func messagesButtonTapped(sender: AnyObject) {
        LocalyticsSession.shared().tagEvent("Subreddit message button tapped")
        if UserSession.sharedSession.isSignedIn {
            self.performSegueWithIdentifier("MessagesSegue", sender: self)
        } else {
            self.performSegueWithIdentifier("AccountsSegue", sender: self)
        }
    }
    
    @IBAction func postButtonTapped(sender: AnyObject) {
        if UserSession.sharedSession.isSignedIn {
            self.performSegueWithIdentifier("PostSegue", sender: self)
        } else {
            self.performSegueWithIdentifier("AccountsSegue", sender: self)
        }
    }
    
    @IBAction func subscribeButtonTapped(sender: AnyObject) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if self.subscribeButton.title != "" {
                if self.subreddit.subscriber.boolValue {
                    if UserSession.sharedSession.isSignedIn {
                        RedditSession.sharedSession.unsubscribe(self.subreddit, completion: { (error) -> () in
                            print(error)
                            if error != nil {
                                UIAlertView.showUnableToUnsubscribeError()
                            } else {
                                self.fetchSubreddit()
                            }
                        })
                    } else {
                        self.performSegueWithIdentifier("LoginSegue", sender: self)
                    }
                } else {
                    if UserSession.sharedSession.isSignedIn {
                        RedditSession.sharedSession.subscribe(self.subreddit, completion: { (error) -> () in
                            if error != nil {
                                UIAlertView.showSubscribeError()
                            } else {
                                self.fetchSubreddit()
                            }
                        })
                    } else {
                        self.performSegueWithIdentifier("LoginSegue", sender: self)
                    }
                }
            }
        })
    }
    
    @IBAction func submitAPostButtonPressed(sender: AnyObject) {
        if UserSession.sharedSession.isSignedIn {
            self.performSegueWithIdentifier("PostSegue", sender: self)
        } else {
            self.performSegueWithIdentifier("AccountsSegue", sender: self)
        }
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.links == nil && !self.fetchingMore {
            return 1
        }
        return self.links?.count ?? 0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        if self.links == nil {
            return tableView.dequeueReusableCellWithIdentifier("NoDataCell") as! NoDataCell
        }
        
        var cell = tableView.dequeueReusableCellWithIdentifier("PostImageCell") as! PostCell

        if let link = self.links?[indexPath.row] as? RKLink {
            if link.hasImage() {
                
                if SettingsManager.defaultManager.valueForSetting(.FullWidthImages) {
                    cell = tableView.dequeueReusableCellWithIdentifier("TitleCell") as! TitleCell
                } else {
                    let imageCell = tableView.dequeueReusableCellWithIdentifier("PostImageCell") as! PostImageCell
                    imageCell.postCellDelegate = self
                    imageCell.link = link
                    return imageCell
                }
            } else {
                cell = tableView.dequeueReusableCellWithIdentifier("TitleCell") as! TitleCell
            }
            
            cell.link = link
        } else if let _ = self.links?[indexPath.row] as? SuggestedLink {
            let cell = tableView.dequeueReusableCellWithIdentifier("AdCell") as! AdCell
            
            cell.bannerView.rootViewController = self
            cell.bannerView.adSize = kGADAdSizeSmartBannerPortrait
            
            let priority = DISPATCH_QUEUE_PRIORITY_BACKGROUND
            
            dispatch_async(dispatch_get_global_queue(priority, 0)) {
                let request = GADRequest()
                request.testDevices = [kGADSimulatorID]
                dispatch_async(dispatch_get_main_queue()) {
                    cell.bannerView.loadRequest(request)
                }
            }
            
            return cell
        }
        
        cell.postCellDelegate = self
        
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {        
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)

        if self.links == nil {
            return
        }

        self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        if let link = self.links?[indexPath.row] as? RKLink {
            self.selectedLink = link
            if link.selfPost {
                self.performSegueWithIdentifier("CommentsSegue", sender: link)
            } else {
                if let _ = tableView.cellForRowAtIndexPath(indexPath) as? PostImageCell {
                    if (link.domain == "imgur.com") {
                        if link.isGifLink() {
                            self.performSegueWithIdentifier("SubredditLink", sender: link)
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
                                        self.performSegueWithIdentifier("GallerySegue", sender: [link.urlForLink() ?? ""])
                                    }
                                }
                            } else {
                                self.performSegueWithIdentifier("GallerySegue", sender: [link.urlForLink() ?? ""])
                            }
                        }
                    } else {
                        self.performSegueWithIdentifier("SubredditLink", sender: link)
                    }
                } else {
                    self.performSegueWithIdentifier("SubredditLink", sender: link)
                }
            }
        }
        
        if let titleCell = tableView.cellForRowAtIndexPath(indexPath) as? TitleCell {
            titleCell.titleLabel.textColor = UIColor.grayColor()
        } else if let imageCell = tableView.cellForRowAtIndexPath(indexPath) as? PostImageCell {
            imageCell.titleTextView.textColor = UIColor.grayColor()
        }
    }
    
    // MARK: PostCellDelegate

    func postCell(cell: PostCell, didTapComments link: RKLink) {
        self.performSegueWithIdentifier("CommentsSegue", sender: link)
    }
    
    func postCell(cell: PostCell, didShortLeftSwipeForLink link: RKLink) {
        // Upvote
        LocalyticsSession.shared().tagEvent("Swipe upvote")
        RedditSession.sharedSession.upvote(link, completion: { (error) -> () in            
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
        })
    }
    
    func postCell(cell: PostCell, didShortRightSwipeForLink link: RKLink) {
        LocalyticsSession.shared().tagEvent("Swipe downvote")
        // Downvote
        RedditSession.sharedSession.downvote(link, completion: { (error) -> () in
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
        })
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
                case "hide":
                    RedditSession.sharedSession.hideLink(link, completion: { (error) -> () in
                        link.saveLink()
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            if let indexPath = self.tableView.indexPathForCell(cell) {
                                self.links?.removeAtIndex(indexPath.row)
                                self.tableView.beginUpdates()
                                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                                self.tableView.endUpdates()
                                sh()
                            }
                        })
                    })
                case "unsave":
                    RedditSession.sharedSession.unSaveLink(link, completion: { (error) -> () in
                        link.unSaveLink()
                        hudTitle = "unsaved!"
                        sh()
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
            popoverController.sourceView = cell
            popoverController.sourceRect = cell.bounds
        }
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func postCell(cell: PostCell, didTapSubreddit subreddit: String?) {
        if let subredditName = subreddit {
            self.goToSubreddit(subredditName)
        }
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
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if self.links == nil {
            return
        } else {
            let endScrolling = scrollView.contentOffset.y + scrollView.frame.size.height
            if endScrolling >= scrollView.contentSize.height && !self.fetchingMore && self.pagination != nil {
                self.fetchingMore = true
                self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                self.fetchLinks()
            }
        }
    }
    
    // MARK: Segues
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if identifier == "SavedSegue" {
            if UserSession.sharedSession.isSignedIn {
                return true
            } else {
                self.performSegueWithIdentifier("LoginSegue", sender: self)
            }
            
            return false
        }
        
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        self.hud?.hide(true)
        if segue.identifier == "SubredditImageLink" || segue.identifier == "SubredditLink" {
            if let link = sender as? RKLink {
                if let controller = segue.destinationViewController as? LinkViewController {
                    controller.link = link
                }
            }
        } else if segue.identifier == "SearchSegue" {
            if let nav = segue.destinationViewController as? UINavigationController {
                if let controller = nav.viewControllers[0] as? SearchViewController {
                    controller.subreddit = self.subreddit
                }
            }
        } else if segue.identifier == "GallerySegue" {
            if let controller = segue.destinationViewController as? GalleryController {
                if let images = sender as? [AnyObject] {
                    controller.images = images
                    controller.link = self.selectedLink
                }
            }
        } else if segue.identifier == "PostSubredditSegue" {
            if let controller = segue.destinationViewController as? NavBarController {
                if let subredditViewController = controller.viewControllers[0] as? SubredditViewController {
                    if let subreddit = sender as? RKSubreddit {
                        subredditViewController.front = false
                        subredditViewController.subreddit = subreddit
                    }
                }
            }
        } else if segue.identifier == "CommentsSegue" {
            if let link = sender as? RKLink {
                if let controller = segue.destinationViewController as? CommentsTreeViewController {
                    controller.link = link
                }
            }
        }
    }
}
