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
    
    var subreddit: RKSubreddit!
    var multiReddit: RKMultireddit!
    var front = true
    var pagination: RKPagination?
    var selectedLink: RKLink!
    var pageIndex: Int!
    var currentCategory: RKSubredditCategory?
    var contextMenu: GHContextMenuView!
    var optionsController: LinkShareOptionsViewController!
    
    var expandButton: OCExpandableButton!
    
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
    
    var refreshControl: UIRefreshControl! {
        get {
            var control = UIRefreshControl()
            control.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes: [NSFontAttributeName : MyRedditCommentTextBoldFont, NSForegroundColorAttributeName : MyRedditLabelColor])
            control.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
            return control
        }
    }
    
    var links = Array<AnyObject>() {
        didSet {
            
            if !SettingsManager.defaultManager.valueForSetting(.NSFW) {
                self.links.filter({ (obj) -> Bool in
                    if let link = obj as? RKLink {
                        return !link.NSFW
                    }
                    
                    return true
                })
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
                    self.tableView.addSubview(self.refreshControl)
                    self.displayHeader(false)
                }
            }
            
            if self.links.count == 25 || self.links.count == 0 {
                self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
            } else {
                self.tableView.reloadData()
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
                
                var tap = UITapGestureRecognizer(target: self, action: "headerImageTapped:")
                tap.numberOfTapsRequired = 1
                self.headerImage.gestureRecognizers = [tap]
            }
        })
    }
    
    func headerImageTapped(gesture: UIGestureRecognizer) {
        self.tableView(self.tableView,
            didSelectRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
        
        LocalyticsSession.shared().tagEvent("Subreddit Header image tapped")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        LocalyticsSession.shared().tagScreen("Subreddit")
        
        self.updateSubscribeButton()
        
        if self.links.count > 0 {
            self.tableView.reloadData()
        }
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
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
        
        self.fetchUnread()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.syncLinks()
        
        self.contextMenu = GHContextMenuView()
        self.contextMenu.delegate = self
        self.contextMenu.dataSource = self
        
        var long = UILongPressGestureRecognizer(target: self.contextMenu,
            action: "longPressDetected:")
        self.view.gestureRecognizers = [long]
        
        var rightBarButtons = self.navigationItem.rightBarButtonItems
        var postBarButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "")
        rightBarButtons?.append(postBarButton)
        
        self.tableView.tableFooterView = UIView()
    }
    
    func setupExpandButton() {
//        var list = UIImageView(frame: CGRectMake(5, 5, 30, 30))
//        list.image = UIImage(named: "List")
//        list.contentMode = UIViewContentMode.ScaleAspectFit
//        var listView = UIView(frame: CGRectMake(0, 0, 45, 45))
//        listView.backgroundColor = UIColor.clearColor()
//        listView.addSubview(list)
//        var search = UIImageView(image: UIImage(named: "Search"))
//        var messages = UIImageView(image: UIImage(named: "Messages"))
//        var filter = UIImageView(image: UIImage(named: "Filter"))
//        var add = UIImageView(image: UIImage(named: "Add"))

//        self.expandButton = OCExpandableButton(frame: CGRect(x: UIScreen.mainScreen().bounds.size.width - 100,
//            y: UIScreen.mainScreen().bounds.size.height - 200,
//            width: 45,
//            height: 45),
//            subviews: [listView, listView])
//        self.expandButton.alignment = OCExpandableButtonAlignmentRight
//        self.view.addSubview(self.expandButton)
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
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func filterLinks(filterSwtichType: FilterSwitchType) {
        
        LocalyticsSession.shared().tagEvent("Filtered subreddit")
        
        self.pagination = nil
        self.links = Array<AnyObject>()
        self.currentCategory = RKSubredditCategory(rawValue: UInt(filterSwtichType.rawValue))
        self.syncLinks()
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
    
    @IBAction func subscribeButtonTapped(sender: AnyObject) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if self.subscribeButton.title != "" {
                if self.subreddit.subscriber.boolValue {
                    RedditSession.sharedSession.unsubscribe(self.subreddit, completion: { (error) -> () in
                        print(error)
                        if error != nil {
                            UIAlertView(title: "Error!",
                                message: "Unable to unsubscribe to Subreddit. Please make sure you are connected to the internets.",
                                delegate: self,
                                cancelButtonTitle: "Ok").show()
                        } else {
                            self.links = Array<AnyObject>()
                            self.pagination = nil
                            self.front = true
                            self.currentCategory = nil
                            self.syncLinks()
                            self.updateSubscribeButton()
                        }
                    })
                } else {
                    RedditSession.sharedSession.subscribe(self.subreddit, completion: { (error) -> () in
                        print(error)
                        if error != nil {
                            UIAlertView(title: "Error!", message: "Unable to subscribe to Subreddit. Please make sure you are connected to the internets.", delegate: self, cancelButtonTitle: "Ok").show()
                        } else {
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                RedditSession.sharedSession.subredditWithSubredditName(self.subreddit.name, completion: { (pagination, results, error) -> () in
                                    if let subreddit = results?.first as? RKSubreddit {
                                        self.subreddit = subreddit
                                        self.updateSubscribeButton()
                                    }
                                })
                            })
                        }
                    })
                }
            }
        })
    }
    
    private func updateSubscribeButton() {
        if self.multiReddit == nil {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if self.front {
                    self.subscribeButton.title = ""
                } else {
                    if self.subreddit.subscriber.boolValue {
                        self.subscribeButton.title = "Unsubscribe"
                        self.subscribeButton.setTitleTextAttributes([NSForegroundColorAttributeName: MyRedditDownvoteColor], forState: .Normal)
                    } else {
                        self.subscribeButton.title = "Subscribe"
                        self.subscribeButton.setTitleTextAttributes([NSForegroundColorAttributeName: MyRedditUpvoteColor], forState: .Normal)
                    }
                }
            })
        } else {
            self.subscribeButton.title = ""
            self.subscribeButton.action = nil
            self.subscribeButton.target = self
        }
    }
    
    func imageForItemAtIndex(index: Int) -> UIImage! {
        if index == 0 {
            return UIImage(named: "SavedMenuItem")
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
        var yOffset: CGFloat = scrollView.contentOffset.y
        if yOffset < -HeaderHeight {
            var f = self.headerImage.frame
            f.origin.y = yOffset
            f.size.height =  -yOffset
            self.headerImage.frame = f
            
            if yOffset <= -400 {
                self.refresh(nil)
            }
        }
    }
    
    func refresh(sender: AnyObject?) {
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        self.headerImage.removeFromSuperview()
        self.links = Array<AnyObject>()
        self.pagination = nil
        self.syncLinks()
    }
    
    private func syncLinks() {
        
        var title: String!
        
        if let multiReddit = self.multiReddit {
            title = multiReddit.name
        } else {
            title = front ? "front" : "/r/\(subreddit.name.lowercaseString)"
        }
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: title,
            style: .Plain,
            target: self,
            action: nil)
        
        self.navigationController?.navigationBarHidden = false
        
        self.navigationItem.title = ""
        
        self.tableView.reloadData()
        if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as? LoadMoreHeader {
            cell.startAnimating()
            
            self.fetchLinks({ () -> () in
                cell.stopAnimating()
            })
        }
    }
    
    private func fetchLinks(completion: () -> ()) {
        
        LocalyticsSession.shared().tagEvent("Fetched links")
        
        if front {
            RedditSession.sharedSession.fetchFrontPagePosts(self.pagination,
                category: self.currentCategory, completion: { (pagination, results, error) -> () in
                self.pagination = pagination
                if let moreLinks = results {
                    self.links.extend(moreLinks)
                }
                
                completion()
            })
        } else {
            if let subreddit = self.subreddit {
                RedditSession.sharedSession.fetchPostsForSubreddit(self.subreddit,
                    category: self.currentCategory, pagination: self.pagination, completion: { (pagination, results, error) -> () in
                        self.pagination = pagination
                        if let moreLinks = results {
                            self.links.extend(moreLinks)
                        }
                        
                        completion()
                })
            } else {
                RedditSession.sharedSession.fetchPostsForMultiReddit(self.multiReddit, category: self.currentCategory, pagination: self.pagination, completion: { (pagination, results, error) -> () in
                    self.pagination = pagination
                    if let moreLinks = results {
                        self.links.extend(moreLinks)
                    }
                    
                    completion()
                })
            }
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
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == self.links.count - 1 && self.links.count != 0 {
                if SettingsManager.defaultManager.valueForSetting(.InfiniteScrolling) {
                    self.fetchLinks({ () -> () in
                        
                    })
                }
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
            if let link = sender as? RKLink {
                if let controller = segue.destinationViewController as? LinkViewController {
                    controller.link = link
                }
            }
        } else if segue.identifier == "SearchSegue" {
            if let nav = segue.destinationViewController as? UINavigationController {
                if let controller = nav.viewControllers[0] as? SearchViewController {
                    controller.delegate = self
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
        } else {
            if let link = sender as? RKLink {
                if let nav = segue.destinationViewController as? UINavigationController {
                    if let controller = nav.viewControllers[0] as? CommentsViewController {
                        controller.link = link
                    }
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
                                        message: "Unable to upvote! Please try again!",
                                        delegate: self,
                                        cancelButtonTitle: "Ok").show()
                                } else {
                                    self.syncLinks()
                                }
                            })
                        } else if swipeType.value == JZSwipeTypeShortRight.value {
                            LocalyticsSession.shared().tagEvent("Swipe downvote")
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
                                    
                                    self.links.removeAtIndex(indexPath.row)
                                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                        self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
                                    })
                                })
                            }))
                            
                            alertController.addAction(UIAlertAction(title: "see comments", style: .Default, handler: { (action) -> Void in
                                self.performSegueWithIdentifier("CommentsSegue", sender: link)
                            }))
                            
                            alertController.addAction(UIAlertAction(title: "cancel", style: .Cancel, handler: nil))
                            alertController.present(animated: true, completion: nil)
                            
                        } else {
                            LocalyticsSession.shared().tagEvent("Swipe share")
                            // Share
                            self.hud.hide(true)
                            self.optionsController = LinkShareOptionsViewController(link: link)
                            self.optionsController.showInView(self.view)
                        }
                    }
                }
            }
        }
    }
    
    func swipeCell(cell: JZSwipeCell!, swipeTypeChangedFrom from: JZSwipeType, to: JZSwipeType) {
        
    }
    
    func searchViewController(controller: SearchViewController, didTapSubreddit subreddit: RKSubreddit) {
        LocalyticsSession.shared().tagEvent("Search subreddit loaded")
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.front = false
            self.subreddit = subreddit
            self.links = Array<AnyObject>()
            self.updateSubscribeButton()
            self.currentCategory = nil
            self.pagination = nil
            self.syncLinks()
        })
    }
}