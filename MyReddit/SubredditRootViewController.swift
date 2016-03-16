//
//  SubredditRootViewController.swift
//  MyReddit
//
//  Created by Nickolas Lanasa on 2/20/16.
//  Copyright © 2016 Nytek Production. All rights reserved.
//

import UIKit
import MBProgressHUD
import AMScrollingNavbar
import Kingfisher

enum FilterSwitchType: Int {
    case Hot
    case New
    case Rising
    case Controversial
    case Top
}

class SubredditRootViewController: RootViewController,
UISplitViewControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var subscribeButton: UIBarButtonItem!
    @IBOutlet weak var filterButton: UIBarButtonItem!
    @IBOutlet weak var listButton: UIBarButtonItem!
    @IBOutlet weak var postButton: UIBarButtonItem!
    @IBOutlet weak var searchButton: UIBarButtonItem!
    @IBOutlet weak var messages: UIBarButtonItem!
    
    var links: [AnyObject]? {
        didSet {
            if !SettingsManager.defaultManager.valueForSetting(.NSFW) {
                self.links = self.links?.filter({ (obj) -> Bool in
                    if let link = obj as? RKLink {
                        if link.NSFW {
                            return false
                        }
                    }
                    
                    return true
                })
            }
        }
    }
    
    var hud: MBProgressHUD! {
        didSet {
            hud.labelFont = MyRedditSelfTextFont
            hud.mode = .Indeterminate
            hud.labelText = "Loading"
        }
    }
    
    var fetchingMore = true
    var front = true
    var all = false
    
    var subreddit: RKSubreddit!
    var multiReddit: RKMultireddit!
    var pagination: RKPagination?
    var selectedLink: RKLink!
    var currentCategory: RKSubredditCategory?
    
    var refreshControl: UIRefreshControl!
    var resources = [String : Resource]()
    
    override func viewWillAppear(animated: Bool) {
        self.showAd = !SettingsManager.defaultManager.purchased ? true : false
        LocalyticsSession.shared().tagScreen("Subreddit")
        self.tableView.hidden = true
        super.viewWillAppear(animated)
        self.tableView.reloadData()
        self.preferredAppearance()
        self.tableView.hidden = false
        self.navigationController?.setToolbarHidden(false, animated: false)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        if let navigationController = self.navigationController as? ScrollingNavigationController {
            navigationController.stopFollowingScrollView()
        }
        
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self,
            action: "refresh:",
            forControlEvents: .ValueChanged)
        self.tableView.addSubview(self.refreshControl)
        
        self.tableView.tableFooterView = UIView()        
        
//        switch UIDevice.currentDevice().userInterfaceIdiom {
//        case .Pad:
//            self.preferredContentSize = CGSizeMake(500, 350)
//            self.listButton.action = self.splitViewController!.displayModeButtonItem().action
//            self.splitViewController?.presentsWithGesture = false
//            self.splitViewController?.delegate = self
//        case .Phone: break
//        default: break
//        }
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "preferredAppearance",
            name: MyRedditAppearanceDidChangeNotification,
            object: nil)
    }

    // MARK: Fetching
    
    func fetchUnread() {
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
    
    func reload() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.refreshControl.endRefreshing()
            self.hud?.hide(true)
            self.updateUI()
            
            if self.links?.count == 25 || self.links?.count == 0 {
                self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
            } else {
                self.tableView.reloadData()
            }
        })
    }
    
    func fetchLinks() {
        self.fetchingMore = true
        let c: PaginationCompletion = {
            pagination,
            results,
            error in
            self.pagination = pagination
            self.fetchingMore = false

            if let moreLinks = results {
                if self.links == nil {
                    self.links = []
                }
                self.links?.appendContentsOf(moreLinks)
                
                // Prefetch urls
                var urls = Array<NSURL>()
                
                for link in moreLinks as! [RKLink] {
                    if link.hasImage() {
                        if let urlStr = link.urlForLink() {
                            if let url = NSURL(string: urlStr) {
                                urls.append(url)
                            }
                        }
                    }
                }
                
                let prefetcher = ImagePrefetcher(urls: urls, optionsInfo: nil, progressBlock: nil, completionHandler: {
                    (skippedResources, failedResources, completedResources) -> () in
                    for resource in completedResources {
                        self.resources[resource.downloadURL.absoluteString] = resource
                    }
                    self.reload()
                })
                prefetcher.start()
            } else {
                self.reload()
            }
        }
        
        if self.front {
            RedditSession.sharedSession.fetchFrontPagePosts(self.pagination,
                category: self.currentCategory, completion: c)
        } else if all {
            RedditSession.sharedSession.fetchAllPosts(self.pagination,
                category: self.currentCategory, completion: c)
        } else {
            if let _ = self.subreddit {
                RedditSession.sharedSession.fetchPostsForSubreddit(self.subreddit,
                    category: self.currentCategory,
                    pagination: self.pagination,
                    completion: c)
            } else {
                RedditSession.sharedSession.fetchPostsForMultiReddit(self.multiReddit,
                    category: self.currentCategory,
                    pagination: self.pagination,
                    completion: c)
            }
        }
    }
    
    func fetchSubreddit() {
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
    
    // MARK: Refresh
    
    func refresh(sender: AnyObject?) {
        self.links = nil
        self.pagination = nil
        self.fetchLinks()
    }
    
    // MARK: Filtering
    
    func filterLinks(category: RKSubredditCategory) {
        LocalyticsSession.shared().tagEvent("Filtered subreddit")
        self.pagination = nil
        self.links = nil
        self.currentCategory = category
        self.fetchLinks()
    }
    
    // MARK: Updating UI
    
    func updateSubscribeButton() {
        if self.multiReddit == nil {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if self.front {
                    self.subscribeButton.title = ""
                } else if self.all {
                    self.subscribeButton.title = ""
                } else {
                    if self.subreddit.subscriber.boolValue {
                        self.subscribeButton.title = "unsubscribe"
                        self.subscribeButton.setTitleTextAttributes([NSForegroundColorAttributeName: MyRedditDownvoteColor,
                            NSFontAttributeName: MyRedditTitleFont],
                            forState: .Normal)
                    } else {
                        self.subscribeButton.title = "subscribe"
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
    
    func updateUI() {
        var title: String!
        
        if let multiReddit = self.multiReddit {
            title = multiReddit.name
        } else {
            if all {
                title = "all"
            } else {
                title = front ? "front" : "\(subreddit.name.lowercaseString)"
            }
        }
        
        self.navigationItem.title = title
    }

    var lastOffsetY: CGFloat = 0
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView){
        lastOffsetY = scrollView.contentOffset.y
    }

    func scrollViewWillBeginDecelerating(scrollView: UIScrollView){
        let hide = scrollView.contentOffset.y > self.lastOffsetY
        
        if let navigationController = self.navigationController as? ScrollingNavigationController {
            if hide {
                navigationController.followScrollView(self.tableView, delay: 50.0)
            } else {
                navigationController.stopFollowingScrollView()
            }
        }
        
        //self.navigationController?.setToolbarHidden(hide, animated: true)
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        super.willRotateToInterfaceOrientation(toInterfaceOrientation, duration: duration)
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        super.didRotateFromInterfaceOrientation(fromInterfaceOrientation)
    }
    
    override func preferredAppearance() {

        self.navigationController?.navigationBar.barTintColor = MyRedditBackgroundColor
        self.navigationController?.navigationBar.backgroundColor = MyRedditBackgroundColor
        self.navigationController?.navigationBar.tintColor = MyRedditLabelColor
        self.navigationItem.leftBarButtonItem?.tintColor = MyRedditLabelColor
        
        self.navigationController?.toolbar?.tintColor = MyRedditLabelColor
        self.navigationController?.toolbar?.backgroundColor = MyRedditBackgroundColor
        self.navigationController?.toolbar?.barTintColor = MyRedditBackgroundColor
        
        self.tableView?.backgroundColor = MyRedditDarkBackgroundColor
        
        self.updateUI()
    }
}
