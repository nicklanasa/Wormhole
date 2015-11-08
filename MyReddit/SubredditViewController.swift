//
//  SubredditViewController.swift
//  MyReddit
//
//  Created by Nick Lanasa on 3/25/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation
import UIKit

enum FilterSwitchType: Int {
    case Hot
    case New
    case Rising
    case Controversial
    case Top
}

class SubredditViewController: RootViewController,
UITableViewDataSource,
UITableViewDelegate,
NSFetchedResultsControllerDelegate,
UIGestureRecognizerDelegate,
JZSwipeCellDelegate,
UISplitViewControllerDelegate,
PostImageCellDelegate,
PostCellDelegate {
    
    var hud: MBProgressHUD! {
        didSet {
            hud.labelFont = MyRedditSelfTextFont
            hud.mode = .Indeterminate
            hud.labelText = "Loading"
        }
    }
    
    var links = Array<AnyObject>()
    
    var subreddit: RKSubreddit!
    var multiReddit: RKMultireddit!
    
    var fetchingMore = false
    var front = true
    var all = false
    var pagination: RKPagination?
    var selectedLink: RKLink!
    var currentCategory: RKSubredditCategory?
    var optionsController: LinkShareOptionsViewController!
    var refreshControl: UIRefreshControl!
    var heightsCache = [String : AnyObject]()
    
    @IBOutlet weak var noPostsLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noPostsView: UIView!
    @IBOutlet weak var toolBar: UIToolbar!
    
    @IBOutlet var headerImage: UIImageView! {
        didSet {
            self.headerImage.autoresizingMask = .FlexibleWidth
        }
    }
    
    @IBOutlet weak var subscribeButton: UIBarButtonItem!
    @IBOutlet weak var filterButton: UIBarButtonItem!
    @IBOutlet weak var listButton: UIBarButtonItem!
    @IBOutlet weak var postButton: UIBarButtonItem!
    @IBOutlet weak var searchButton: UIBarButtonItem!
    @IBOutlet weak var messages: UIBarButtonItem!
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
        self.updateUI()
        self.fetchUnread()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self,
            action: "refresh:",
            forControlEvents: .ValueChanged)
        self.tableView.addSubview(self.refreshControl)

        if let username = NSUserDefaults.standardUserDefaults().objectForKey("username") as? String {
            if let password = NSUserDefaults.standardUserDefaults().objectForKey("password") as? String {
                UserSession.sharedSession.loginWithUsername(username, password: password, completion: { (error) -> () in
                    self.updateAndFetch()
                })
            } else {
                self.updateAndFetch()
            }
        } else {
            self.updateAndFetch()
        }
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "front",
            style: .Plain,
            target: self,
            action: nil)
        
        self.tableView.tableFooterView = UIView()
     
        switch UIDevice.currentDevice().userInterfaceIdiom {
        case .Pad:
            configureForPad()
        case .Phone: break
        default: break
        }
    }

    // MARK: Filtering
    
    func filterLinks(filterSwtichType: FilterSwitchType) {
        LocalyticsSession.shared().tagEvent("Filtered subreddit")
        self.pagination = nil
        self.links = Array<AnyObject>()
        self.currentCategory = RKSubredditCategory(rawValue: UInt(filterSwtichType.rawValue))
        self.fetchLinks()
    }
    
    // MARK: Refresh
    
    func refresh(sender: AnyObject?) {
        self.links = Array<AnyObject>()
        self.pagination = nil
        self.fetchLinks()
    }
    
    // Private
    
    private func configureForPad() {
        let width: CGFloat = 500
        let height: CGFloat = 350
        
        preferredContentSize = CGSizeMake(width, height)
        self.splitViewController?.presentsWithGesture = false
        self.listButton.action = self.splitViewController!.displayModeButtonItem().action
        
        self.splitViewController?.delegate = self
    }
    
    private func checkIfNoContent() {
        if self.links.count == 0 {
            self.tableView.hidden = true
            self.noPostsView.hidden = false
        } else {
            self.tableView.hidden = false
            self.noPostsView.hidden = true
        }
    }

    private func fetchUnread() {
        RedditSession.sharedSession.fetchMessages(nil, category: .Unread, read: false) { (pagination, results, error) -> () in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if results?.count > 0 {
                    self.messages.image = UIImage(named: "MessagesSelected")
                } else {
                    self.messages.image = UIImage(named: "Messages")
                }
            })
        }
    }
    
    private func updateSubscribeButton() {
        if self.multiReddit == nil {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if self.front {
                    self.subscribeButton.title = ""
                } else if self.all {
                    self.subscribeButton.title = ""
                } else {
                    if self.subreddit.subscriber.boolValue {
                        self.subscribeButton.title = "Unsubscribe"
                        self.subscribeButton.setTitleTextAttributes([NSForegroundColorAttributeName: MyRedditDownvoteColor,
                            NSFontAttributeName: MyRedditTitleFont],
                            forState: .Normal)
                    } else {
                        self.subscribeButton.title = "Subscribe"
                        self.subscribeButton.setTitleTextAttributes([NSForegroundColorAttributeName: MyRedditUpvoteColor,
                            NSFontAttributeName: MyRedditTitleFont],
                            forState: .Normal)
                    }
                }
            })
        } else {
            self.subscribeButton.title = ""
            self.subscribeButton.action = nil
            self.subscribeButton.target = self
        }
    }
    
    // MARK: Private Fetching
    
    private func fetchFrontPagePosts(completion: () -> ()) {
        RedditSession.sharedSession.fetchFrontPagePosts(self.pagination,
            category: self.currentCategory, completion: { (pagination, results, error) -> () in
                self.pagination = pagination
                if let moreLinks = results {
                    self.links.appendContentsOf(moreLinks)
                }
                
                completion()
        })
    }
    
    private func fetchAllPosts(completion: () -> ()) {
        RedditSession.sharedSession.fetchAllPosts(self.pagination,
            category: self.currentCategory, completion: { (pagination, results, error) -> () in
                self.pagination = pagination
                if let moreLinks = results {
                    self.links.appendContentsOf(moreLinks)
                }
                
                completion()
        })
    }
    
    private func fetchPostsForSubreddit(completion: () -> ()) {
        RedditSession.sharedSession.fetchPostsForSubreddit(self.subreddit,
            category: self.currentCategory,
            pagination: self.pagination,
            completion: { (pagination, results, error) -> () in
                self.pagination = pagination
                if let moreLinks = results {
                    self.links.appendContentsOf(moreLinks)
                }
                
                completion()
        })
    }
    
    private func fetchPostsForMultiReddit(completion: () -> ()) {
        RedditSession.sharedSession.fetchPostsForMultiReddit(self.multiReddit,
            category: self.currentCategory,
            pagination: self.pagination,
            completion: { (pagination, results, error) -> () in
                self.pagination = pagination
                if let moreLinks = results {
                    self.links.appendContentsOf(moreLinks)
                }
                
                completion()
        })
    }
    
    private func fetchLinks() {
        
        LocalyticsSession.shared().tagEvent("Fetched links")
        
        self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        if self.front {
            self.fetchFrontPagePosts({ () -> () in
                self.endRefreshing()
            })
        } else if all {
            self.fetchAllPosts({ () -> () in
                self.endRefreshing()
            })
        } else {
            if let _ = self.subreddit {
                self.fetchPostsForSubreddit({ () -> () in
                    self.endRefreshing()
                })
            } else {
                self.fetchPostsForMultiReddit({ () -> () in
                    self.endRefreshing()
                })
            }
        }
    }
    
    // MARK: Private Updating
    
    private func reload() {
        if !SettingsManager.defaultManager.valueForSetting(.NSFW) {
            self.links = self.links.filter({ (obj) -> Bool in
                if let link = obj as? RKLink {
                    if link.NSFW {
                        return false
                    }
                }
                
                return true
            })
        }
        
        if self.links.count == 25 || self.links.count == 0 {
            self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
        } else {
            self.tableView.reloadData()
        }
    }
    
    private func reset() {
        self.links = Array<AnyObject>()
        self.pagination = nil
        self.front = true
        self.currentCategory = nil
    }
    
    private func updateAndFetch() {
        LocalyticsSession.shared().tagScreen("Subreddit")
        self.updateUI()
        self.fetchUnread()
        self.refresh(nil)
        self.updateSubscribeButton()
    }
    
    private func updateUI() {
        
        var title: String!
        
        if let multiReddit = self.multiReddit {
            title = multiReddit.name
        } else {
            if all {
                title = "/r/all"
            } else {
                title = front ? "front" : "/r/\(subreddit.name.lowercaseString)"
            }
        }
        
        self.navigationItem.leftBarButtonItem?.title = title
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.updateSubscribeButton()
            self.filterButton.tintColor = MyRedditLabelColor
            self.listButton.tintColor = MyRedditLabelColor
            self.postButton.tintColor = MyRedditLabelColor
            self.searchButton.tintColor = MyRedditLabelColor
            self.messages.tintColor = MyRedditLabelColor
            self.noPostsView.backgroundColor = MyRedditBackgroundColor
            self.noPostsLabel.textColor = MyRedditLabelColor
            
            self.navigationItem.leftBarButtonItem!.setTitleTextAttributes([
                NSFontAttributeName: MyRedditTitleBigFont, NSForegroundColorAttributeName : MyRedditLabelColor],
                forState: UIControlState.Normal)
        })
        
        self.navigationController?.setToolbarHidden(true, animated: true)
    }
    
    private func endRefreshing() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.reload()
            self.fetchingMore = false
            self.checkIfNoContent()
            
            self.hud.hide(true)
            self.refreshControl.endRefreshing()
        }
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
        
        if !SettingsManager.defaultManager.purchased {
            self.performSegueWithIdentifier("PurchaseSegue", sender: self)
        } else {
            if UserSession.sharedSession.isSignedIn {
                self.performSegueWithIdentifier("MessagesSegue", sender: self)
            } else {
                self.performSegueWithIdentifier("AccountsSegue", sender: self)
            }
        }
    }
    
    @IBAction func postButtonTapped(sender: AnyObject) {
        if !SettingsManager.defaultManager.purchased {
            self.performSegueWithIdentifier("PurchaseSegue", sender: self)
        } else {
            if UserSession.sharedSession.isSignedIn {
                self.performSegueWithIdentifier("PostSegue", sender: self)
            } else {
                self.performSegueWithIdentifier("AccountsSegue", sender: self)
            }
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
                                self.reset()
                                self.updateAndFetch()
                            }
                        })
                    } else {
                        if !SettingsManager.defaultManager.purchased {
                            self.performSegueWithIdentifier("PurchaseSegue", sender: self)
                        } else {
                            self.performSegueWithIdentifier("LoginSegue", sender: self)
                        }
                    }
                } else {
                    if UserSession.sharedSession.isSignedIn {
                        RedditSession.sharedSession.subscribe(self.subreddit, completion: { (error) -> () in
                            if error != nil {
                                UIAlertView.showSubscribeError()
                            } else {
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    RedditSession.sharedSession.searchForSubredditByName(self.subreddit.name,
                                        pagination: nil) { (pagination, results, error) -> () in
                                        if let subreddits = results as? [RKSubreddit] {
                                            var foundSubreddit: RKSubreddit?
                                            for subreddit in subreddits {
                                                if subreddit.name.lowercaseString == self.subreddit.name.lowercaseString {
                                                    foundSubreddit = subreddit
                                                    break
                                                }
                                            }
                                            
                                            if foundSubreddit == nil {
                                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                                    UIAlertView(title: "Error!",
                                                        message: "Unable to subscribe to subreddit.",
                                                        delegate: self,
                                                        cancelButtonTitle: "OK").show()
                                                })
                                            } else {
                                                self.subreddit = foundSubreddit
                                                self.updateSubscribeButton()
                                            }
                                        } else {
                                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                                UIAlertView(title: "Error!",
                                                    message: "Unable to find subreddit by that name.",
                                                    delegate: self,
                                                    cancelButtonTitle: "OK").show()
                                            })
                                        }
                                    }
                                })
                            }
                        })
                    } else {
                        if !SettingsManager.defaultManager.purchased {
                            self.performSegueWithIdentifier("PurchaseSegue", sender: self)
                        } else {
                            self.performSegueWithIdentifier("LoginSegue", sender: self)
                        }
                    }
                }
            }
        })
    }
    
    @IBAction func submitAPostButtonPressed(sender: AnyObject) {
        if !SettingsManager.defaultManager.purchased {
            self.performSegueWithIdentifier("PurchaseSegue", sender: self)
        } else {
            if UserSession.sharedSession.isSignedIn {
                self.performSegueWithIdentifier("PostSegue", sender: self)
            } else {
                self.performSegueWithIdentifier("AccountsSegue", sender: self)
            }
        }
    }
    
    @IBAction func tryAgainButtonPressed(sender: AnyObject) {
        self.updateAndFetch()
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.links.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        var cell = tableView.dequeueReusableCellWithIdentifier("PostImageCell") as! PostCell
        
        if indexPath.row < self.links.count {
            if let link = self.links[indexPath.row] as? RKLink {
                if link.hasImage() {
                    
                    if SettingsManager.defaultManager.valueForSetting(.FullWidthImages) {
                        cell = tableView.dequeueReusableCellWithIdentifier("TitleCell") as! TitleCell
                    } else {
                        let imageCell = tableView.dequeueReusableCellWithIdentifier("PostImageCell") as! PostImageCell
                        imageCell.postImageDelegate = self
                        imageCell.postCellDelegate = self
                        imageCell.link = link
                        imageCell.delegate = self
                        return imageCell
                    }
                } else {
                    cell = tableView.dequeueReusableCellWithIdentifier("TitleCell") as! TitleCell
                }
                
                cell.link = link
            }
        }
        
        cell.postCellDelegate = self
        cell.delegate = self
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row < self.links.count {
            if let link = self.links[indexPath.row] as? RKLink {
                if link.hasImage() {
                    // Image
                    
                    if SettingsManager.defaultManager.valueForSetting(.FullWidthImages) {
                        // regular
                        return self.heightForTitlePost(link)
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
                    return self.heightForTitlePost(link)
                }
            }
        }
        
        return 0
    }
    
    func heightForTitlePost(link: RKLink) -> CGFloat {
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        if let link = self.links[indexPath.row] as? RKLink {
            self.selectedLink = link
            if link.selfPost {
                self.performSegueWithIdentifier("CommentsSegue", sender: link)
            } else {
                if (link.domain == "imgur.com" || link.isImageOrGifLink()) {
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
        }
        
        if let titleCell = tableView.cellForRowAtIndexPath(indexPath) as? TitleCell {
            titleCell.titleLabel.textColor = UIColor.grayColor()
        } else if let imageCell = tableView.cellForRowAtIndexPath(indexPath) as? PostImageCell {
            imageCell.titleLabel.textColor = UIColor.grayColor()
        }
    }
    
    // MARK: JZSwipeCellDelegate
    
    func swipeCell(cell: JZSwipeCell!, triggeredSwipeWithType swipeType: JZSwipeType) {
        if swipeType.rawValue != JZSwipeTypeNone.rawValue {
            cell.reset()
            cell.layoutSubviews()
            if !SettingsManager.defaultManager.purchased {
                self.performSegueWithIdentifier("PurchaseSegue", sender: self)
            } else {
                
                self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                
                if let indexPath = self.tableView.indexPathForCell(cell) {
                    if let link = self.links[indexPath.row] as? RKLink {
                        if swipeType.rawValue == JZSwipeTypeShortLeft.rawValue {
                            // Upvote
                            LocalyticsSession.shared().tagEvent("Swipe upvote")
                            RedditSession.sharedSession.upvote(link, completion: { (error) -> () in
                                self.hud.hide(true)
                                
                                if error != nil {
                                    UIAlertView(title: "Error!",
                                        message: error!.localizedDescription,
                                        delegate: self,
                                        cancelButtonTitle: "Ok").show()
                                } else {
                                    self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                                }
                            })
                        } else if swipeType.rawValue == JZSwipeTypeShortRight.rawValue {
                            LocalyticsSession.shared().tagEvent("Swipe downvote")
                            // Downvote
                            RedditSession.sharedSession.downvote(link, completion: { (error) -> () in
                                self.hud.hide(true)
                                
                                if error != nil {
                                    UIAlertView(title: "Error!",
                                        message: error!.localizedDescription,
                                        delegate: self,
                                        cancelButtonTitle: "Ok").show()
                                } else {
                                    self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                                }
                            })
                        } else if swipeType.rawValue == JZSwipeTypeLongLeft.rawValue {
                            LocalyticsSession.shared().tagEvent("Swipe comments")
                            self.performSegueWithIdentifier("CommentsSegue", sender: link)

                        } else {
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
                                    RedditSession.sharedSession.saveLink(link, completion: { (error) -> () in
                                        self.hud.hide(true)
                                        link.saveLink()
                                    })
                                }))
                            }
                            
                            alertController.addAction(UIAlertAction(title: "hide", style: .Default, handler: { (action) -> Void in
                                RedditSession.sharedSession.hideLink(link, completion: { (error) -> () in
                                    self.hud.hide(true)
                                    link.saveLink()
                                    
                                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                        self.links.removeAtIndex(indexPath.row)
                                        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                                    })
                                })
                            }))
                            
                            alertController.addAction(UIAlertAction(title: "open in safari", style: .Default, handler: { (action) -> Void in
                                UIApplication.sharedApplication().openURL(link.URL)
                            }))
                            
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
                    }
                }
            }
        }
    }
    
    func swipeCell(cell: JZSwipeCell!, swipeTypeChangedFrom from: JZSwipeType, to: JZSwipeType) {
        
    }
    
    // MARK: PostImageCellDelegate
    
    func postImageCell(cell: PostImageCell, didDownloadImageWithHeight height: CGFloat, url: NSURL) {
        if let _ = self.tableView.indexPathForCell(cell) {
            self.heightsCache[url.description] = NSNumber(float: Float(height))
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
    }
    
    // MARK: PostCellDelegate
    
    func postCell(cell: PostCell, didTapSubreddit subreddit: String?) {
        if let subredditName = subreddit {
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
                        self.performSegueWithIdentifier("PostSubredditSegue",
                            sender: foundSubreddit)
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
    }
    
    func postImageCell(cell: PostImageCell, didLongHoldOnImage image: UIImage?) {
        if let selectedImage = image {
            self.presentViewController(UIAlertController.saveImageAlertController(selectedImage),
                animated: true,
                completion: nil)
        }
    }
    
    // MARK: Segues
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if identifier == "SavedSegue" {
            if UserSession.sharedSession.isSignedIn {
                return true
            } else {
                if !SettingsManager.defaultManager.purchased {
                    self.performSegueWithIdentifier("PurchaseSegue", sender: self)
                } else {
                    self.performSegueWithIdentifier("LoginSegue", sender: self)
                }
            }
            
            return false
        }
        
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SubredditImageLink" || segue.identifier == "SubredditLink" {
            self.hud.hide(true)
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
            self.hud.hide(true)
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
        } else {
            if let link = sender as? RKLink {
                self.hud.hide(true)
                if let controller = segue.destinationViewController as? CommentsViewController {
                    controller.link = link
                }
            }
        }
    }
    
    // MARK: UIScrollViewDelegate
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let endScrolling = scrollView.contentOffset.y + scrollView.frame.size.height
        if endScrolling >= scrollView.contentSize.height && !self.fetchingMore {
            self.fetchingMore = true
            self.fetchLinks()
        }
    }
    
    override func preferredAppearance() {
        self.navigationController?.navigationBar.barTintColor = MyRedditBackgroundColor
        self.navigationController?.navigationBar.backgroundColor = MyRedditBackgroundColor
        self.navigationController?.navigationBar.tintColor = MyRedditLabelColor
        self.navigationItem.leftBarButtonItem?.tintColor = MyRedditLabelColor
        self.toolBar.tintColor = MyRedditLabelColor
        self.toolBar.backgroundColor = MyRedditBackgroundColor
        self.toolBar.barTintColor = MyRedditBackgroundColor
        self.tableView.backgroundColor = MyRedditBackgroundColor
        
        self.updateUI()
        self.tableView.reloadData()
    }
}