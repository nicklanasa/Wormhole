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

let HeaderIphoneHeight: CGFloat = 300.0
let HeaderIphoneThreshold: CGFloat = -400
let HeaderIpadHeight: CGFloat = 500.0
let HeaderIpadThreshold: CGFloat = -600

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
JZSwipeCellDelegate,
UISplitViewControllerDelegate, PostImageCellDelegate {
    
    var subreddit: RKSubreddit!
    var multiReddit: RKMultireddit!
    
    var fetchingMore = false
    var front = true
    var all = false
    var pagination: RKPagination?
    var selectedLink: RKLink!
    var currentCategory: RKSubredditCategory?
    var optionsController: LinkShareOptionsViewController!
    var refreshControl = MyRedditRefreshControl(type: .SlideDown)
    var heightsCache = [String : AnyObject]()
    
    @IBOutlet weak var tableView: UITableView!
    
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
    
    var hud: MBProgressHUD! {
        didSet {
            hud.labelFont = MyRedditSelfTextFont
            hud.mode = .Indeterminate
            hud.labelText = "Loading"
        }
    }
    
    var links = Array<AnyObject>()
    
    private func displayHeader(foundImage: Bool) {
        
        var headerHeight = HeaderIphoneHeight
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            headerHeight = HeaderIpadHeight
        }
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if !foundImage {
                //self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
                self.headerImage.removeFromSuperview()
            } else {
                self.tableView.contentInset = UIEdgeInsetsMake(headerHeight, 0, 0, 0)
                self.tableView.addSubview(self.headerImage)
                self.headerImage.frame = CGRectMake(0, -headerHeight, UIScreen.mainScreen().bounds.size.width, headerHeight)
                
                if self.links.count <= 25 {
                    if self.tableView.contentOffset.y <= 0 {
                        self.tableView.setContentOffset(CGPointMake(0, -headerHeight), animated: true)
                        
                        var tap = UITapGestureRecognizer(target: self, action: "headerImageTapped:")
                        tap.numberOfTapsRequired = 1
                        self.headerImage.gestureRecognizers = [tap]
                    }
                }
            }
        })
    }
    
    func updateHeaderImage() {
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
                    self.headerImage.sd_setImageWithURL(imageURL,
                        placeholderImage: UIImage(),
                        completed: { (image, error, cacheType, url) -> Void in
                            if error != nil {
                                self.displayHeader(false)
                            } else {
                                self.displayHeader(true)
                            }
                    })
                }
            } else {
            
                self.refreshControl.addToScrollView(self.tableView, withRefreshBlock: { () -> Void in
                    self.refresh(nil)
                })
                
                self.displayHeader(false)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
        self.updateUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.updateAndFetch()
        self.tableView.tableFooterView = UIView()
     
        switch UIDevice.currentDevice().userInterfaceIdiom {
        case .Pad:
            configureForPad()
        case .Phone: break
        default: break
        }
    }
    
    private func configureForPad() {
        let width: CGFloat = 500
        let height: CGFloat = 350
        
        preferredContentSize = CGSizeMake(width, height)
        self.splitViewController?.presentsWithGesture = false
        self.listButton.action = self.splitViewController!.displayModeButtonItem().action
        
        self.splitViewController?.delegate = self
    }

    private func fetchUnread() {
        RedditSession.sharedSession.fetchMessages(nil, category: .Unread, read: false) { (pagination, results, error) -> () in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if results?.count > 0 {
                    self.messages.tintColor = MyRedditColor
                } else {
                    self.messages.tintColor = MyRedditLabelColor
                }
            })
        }
    }
    
    func headerImageTapped(gesture: UIGestureRecognizer) {
        self.tableView(self.tableView,
            didSelectRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
        
        LocalyticsSession.shared().tagEvent("Subreddit Header image tapped")
    }

    @IBAction func filterButtonPressed(sender: AnyObject) {
        
        var alert = UIAlertController(title: "Select filter", message: nil, preferredStyle: .ActionSheet)
        
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
    
    func filterLinks(filterSwtichType: FilterSwitchType) {
        LocalyticsSession.shared().tagEvent("Filtered subreddit")
        self.pagination = nil
        self.links = Array<AnyObject>()
        self.currentCategory = RKSubredditCategory(rawValue: UInt(filterSwtichType.rawValue))
        self.fetchLinks()
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
                                    RedditSession.sharedSession.searchForSubredditByName(self.subreddit.name, pagination: nil) { (pagination, results, error) -> () in
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
    
    // MARK: UIScrollViewDelegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        var headerHeight = HeaderIphoneHeight
        var threshold = HeaderIphoneThreshold
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            headerHeight = HeaderIpadHeight
            threshold = HeaderIpadThreshold
        }
        
        var yOffset: CGFloat = scrollView.contentOffset.y
        if yOffset < -headerHeight {
            var f = self.headerImage.frame
            f.origin.y = yOffset
            f.size.height =  -yOffset
            self.headerImage.frame = f
            
            if yOffset <= threshold {
                self.refresh(nil)
            }
        }
    }
    
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
        } else {
            if let link = sender as? RKLink {
                self.hud.hide(true)
                if let nav = segue.destinationViewController as? UINavigationController {
                    if let controller = nav.viewControllers[0] as? CommentsViewController {
                        controller.link = link
                    }
                }
            }
        }
    }
    
    func loadMoreHeader(header: LoadMoreHeader, didTapButton sender: AnyObject) {
        if self.pagination != nil {
            self.fetchLinks()
        } else {
            self.tableView.reloadData()
        }
    }
    
    // MARK: Fetching 
    
    private func fetchFrontPagePosts(completion: () -> ()) {
        RedditSession.sharedSession.fetchFrontPagePosts(self.pagination,
            category: self.currentCategory, completion: { (pagination, results, error) -> () in
                self.pagination = pagination
                if let moreLinks = results {
                    self.links.extend(moreLinks)
                }
                
                completion()
        })
    }
    
    private func fetchAllPosts(completion: () -> ()) {
        RedditSession.sharedSession.fetchAllPosts(self.pagination,
            category: self.currentCategory, completion: { (pagination, results, error) -> () in
                self.pagination = pagination
                if let moreLinks = results {
                    self.links.extend(moreLinks)
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
                    self.links.extend(moreLinks)
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
                    self.links.extend(moreLinks)
                }
                
                completion()
        })
    }
    
    private func fetchLinks() {
        
        self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        LocalyticsSession.shared().tagEvent("Fetched links")
 
        if self.front {
            self.fetchFrontPagePosts({ () -> () in
                self.endRefreshing()
            })
        } else if all {
            self.fetchAllPosts({ () -> () in
                self.endRefreshing()
            })
        } else {
            if let subreddit = self.subreddit {
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
    
    // MARK: Updating
    
    private func reload() {
        if !SettingsManager.defaultManager.valueForSetting(.NSFW) {
            self.links.filter({ (obj) -> Bool in
                if let link = obj as? RKLink {
                    return !link.NSFW
                }
                
                return true
            })
        }
        
        self.updateHeaderImage()
        
        if self.links.count < 25 || self.links.count == 0 {
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
        self.fetchLinks()
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
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: title,
            style: .Plain,
            target: self,
            action: nil)
        
        self.navigationController?.navigationBarHidden = false
        self.navigationItem.title = ""
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.updateSubscribeButton()
            self.filterButton.tintColor = MyRedditLabelColor
            self.listButton.tintColor = MyRedditLabelColor
            self.postButton.tintColor = MyRedditLabelColor
            self.searchButton.tintColor = MyRedditLabelColor
            self.messages.tintColor = MyRedditLabelColor
            
            self.navigationItem.leftBarButtonItem!.setTitleTextAttributes([
                NSFontAttributeName: MyRedditTitleBigFont, NSForegroundColorAttributeName : MyRedditLabelColor],
                forState: UIControlState.Normal)
            self.navigationItem.rightBarButtonItem!.setTitleTextAttributes([
                NSFontAttributeName: MyRedditTitleFont],
                forState: UIControlState.Normal)
        })
    }
    
    private func endRefreshing() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.hud.hide(true)
            self.reload()
            self.refreshControl.endRefreshing()
            self.fetchingMore = false
        })
    }
    
    func refresh(sender: AnyObject?) {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
            self.headerImage.removeFromSuperview()
            self.links = Array<AnyObject>()
            self.pagination = nil
            self.fetchLinks()
        })
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
                if link.isImageLink() || link.domain == "imgur.com" {
                    
                    if indexPath.row == 0 || SettingsManager.defaultManager.valueForSetting(.FullWidthImages) {
                        cell = tableView.dequeueReusableCellWithIdentifier("TitleCell") as! TitleCell
                    } else {
                        var imageCell = tableView.dequeueReusableCellWithIdentifier("PostImageCell") as! PostImageCell
                        imageCell.postImageDelegate = self
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
        
        cell.delegate = self
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row < self.links.count {
            if let link = self.links[indexPath.row] as? RKLink {
                if link.isImageLink() || link.domain == "imgur.com" {
                    
                    // Image
                    
                    if indexPath.row == 0 || SettingsManager.defaultManager.valueForSetting(.FullWidthImages) {
                        // regular
                        return self.heightForTitlePost(link)
                    } else {
                        
                        var url: String?
                        
                        if link.isImageLink() {
                            url = link.URL.absoluteString
                        } else if link.domain == "imgur.com" {
                            if let absoluteString = link.URL.absoluteString {
                                var stringURL = absoluteString + ".jpg"
                                url = stringURL
                            }
                        }
                        
                        if url != nil {
                            if let height = self.heightsCache[url!] as? NSNumber {
                                return CGFloat(height.floatValue)
                            }
                        }
                        
                        return 300
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
        var text = link.title
        var frame = CGRectMake(0, 0, (self.tableView.frame.size.width - 18), CGFloat.max)
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
                if link.domain == "imgur.com" || link.isImageLink() {
                    if link.domain == "imgur.com" && !link.URL.absoluteString!.hasExtension() {
                        var urlComponents = link.URL.absoluteString?.componentsSeparatedByString("/")
                        if urlComponents?.count > 4 {
                            let albumID = urlComponents?[4]
                            IMGAlbumRequest.albumWithID(albumID, success: { (album) -> Void in
                                self.performSegueWithIdentifier("GallerySegue", sender: album.images)
                                }) { (error) -> Void in
                                    LocalyticsSession.shared().tagEvent("Imgur album request failed")
                                    self.performSegueWithIdentifier("SubredditLink", sender: link)
                            }
                        } else {
                            if urlComponents?.count > 3 {
                                let imageID = urlComponents?[3]
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
    }
 
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        var endScrolling = scrollView.contentOffset.y + scrollView.frame.size.height
        if endScrolling >= scrollView.contentSize.height && !self.fetchingMore {
            self.fetchingMore = true
            self.fetchLinks()
        }
    }
    
    // MARK: JZSwipeCellDelegate
    
    func swipeCell(cell: JZSwipeCell!, triggeredSwipeWithType swipeType: JZSwipeType) {
        if swipeType.value != JZSwipeTypeNone.value {
            cell.reset()
            cell.layoutSubviews()
            if !SettingsManager.defaultManager.purchased {
                self.performSegueWithIdentifier("PurchaseSegue", sender: self)
            } else {
                
                self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                
                if let indexPath = self.tableView.indexPathForCell(cell) {
                    if let link = self.links[indexPath.row] as? RKLink {
                        if swipeType.value == JZSwipeTypeShortLeft.value {
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
                        } else if swipeType.value == JZSwipeTypeShortRight.value {
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
                        } else if swipeType.value == JZSwipeTypeLongLeft.value {
                            LocalyticsSession.shared().tagEvent("Swipe more")
                            // More
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
                            
                            alertController.addAction(UIAlertAction(title: "see comments", style: .Default, handler: { (action) -> Void in
                                self.performSegueWithIdentifier("CommentsSegue", sender: link)
                            }))
                            
                            alertController.addAction(UIAlertAction(title: "cancel", style: .Cancel, handler: nil))
                            
                            if let popoverController = alertController.popoverPresentationController {
                                popoverController.sourceView = cell
                                popoverController.sourceRect = cell.bounds
                            }
                            
                            alertController.present(animated: true, completion: nil)
                            
                        } else {
                            LocalyticsSession.shared().tagEvent("Swipe share")
                            // Share
                            self.hud.hide(true)
                            self.optionsController = LinkShareOptionsViewController(link: link)
                            self.optionsController.sourceView = cell
                            self.optionsController.showInView(self.view)
                        }
                    }
                }
            }
        }
    }
    
    func swipeCell(cell: JZSwipeCell!, swipeTypeChangedFrom from: JZSwipeType, to: JZSwipeType) {
        
    }
    
    func postImageCell(cell: PostImageCell, didDownloadImageWithHeight height: CGFloat, url: NSURL) {
        if let indexPath = self.tableView.indexPathForCell(cell) {
            self.heightsCache[url.absoluteString!] = NSNumber(float: Float(height))
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
    }
}