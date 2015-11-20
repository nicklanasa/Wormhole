//
//  SubredditSearchViewController.swift
//  MyReddit
//
//  Created by Nick Lanasa on 5/1/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation
import UIKit
import MBProgressHUD

class SearchViewController: RootViewController,
UITableViewDelegate,
UITableViewDataSource,
UISearchDisplayDelegate,
UISearchBarDelegate,
UISearchControllerDelegate,
JZSwipeCellDelegate,
PostImageCellDelegate,
PostCellDelegate {
    
    var pagination: RKPagination? {
        didSet {
            self.fetchingMore = false
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                self.hud?.hide(true)
            }
        }
    }
    
    var optionsController: LinkShareOptionsViewController!
    var subreddit: RKSubreddit!
    var selectedSubreddit: RKSubreddit!
    var fetchingMore = false
    
    @IBOutlet weak var filterControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var restrictToSubredditSwitch: UIBarButtonItem!
    @IBOutlet weak var restrictSubreddit: UISwitch!
    @IBOutlet weak var listButton: UIBarButtonItem!
    @IBOutlet weak var filterButton: UIBarButtonItem!
    @IBOutlet weak var bottomNavigationBar: UINavigationBar!
    
    var heightsCache = [String : AnyObject]()
    
    var links = Array<AnyObject>() {
        didSet {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
            })
        }
    }
    
    var subreddits = Array<AnyObject>() {
        didSet {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
            })
        }
    }
    
    var hud: MBProgressHUD? {
        didSet {
            hud?.labelFont = MyRedditSelfTextFont
            hud?.mode = .Indeterminate
            hud?.labelText = "Loading"
        }
    }
    
    lazy var searchController: UISearchController = {
        var controller = UISearchController(searchResultsController: nil)
        controller.dimsBackgroundDuringPresentation = false
        controller.searchBar.delegate = self
        controller.delegate = self
        controller.searchBar.setShowsCancelButton(false, animated: false)
        controller.hidesNavigationBarDuringPresentation = false
        controller.searchBar.searchBarStyle = .Minimal
        controller.searchBar.returnKeyType = .Done
        controller.searchBar.placeholder = "Search subreddits or posts..."
        controller.searchBar.sizeToFit()
        
        for v in controller.searchBar.subviews {
            if let textField = v as? UITextField {
                textField.clearButtonMode = .Always
                break;
            }
        }
        
        return controller
    }()
    
    @IBAction func filterButtonPressed(sender: AnyObject) {
        let actionSheet = UIAlertController(title: "Select sort", message: nil, preferredStyle: .ActionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "newest", style: .Default, handler: { (action) -> Void in
            self.links.sortInPlace({ (l0, l1) -> Bool in
                if let link0 = l0 as? RKLink, link1 = l1 as? RKLink {
                    return link0.created.timeIntervalSinceNow > link1.created.timeIntervalSinceNow
                }
                
                return false
            })
        }))
        
        actionSheet.addAction(UIAlertAction(title: "oldest", style: .Default, handler: { (action) -> Void in
            self.links.sortInPlace({ (l0, l1) -> Bool in
                if let link0 = l0 as? RKLink, link1 = l1 as? RKLink {
                    return link0.created.timeIntervalSinceNow < link1.created.timeIntervalSinceNow
                }
                
                return false
            })
        }))

        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) -> Void in
        }))
        
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.barButtonItem = self.filterButton
        }
        
        actionSheet.present(animated: true, completion: nil)
    }
    
    @IBAction func filterControlValueChanged(sender: AnyObject) {
        if self.filterControl.selectedSegmentIndex == 1 {
            self.restrictSubreddit.enabled = false
            self.filterButton.enabled = false
        } else {
            self.restrictSubreddit.enabled = true
            self.filterButton.enabled = true
        }
        
        self.search()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        self.links = Array<AnyObject>()
        self.search()
    }
    
    func search() {
        let searchText = self.searchController.searchBar.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        if searchText.characters.count > 0 {
            if self.filterControl.selectedSegmentIndex == 1 {
                self.searchSubs(searchText)
            } else {
                self.searchLinks(searchText)
            }
        } else {
            self.links = Array<AnyObject>()
            self.subreddits = Array<AnyObject>()
            self.tableView.reloadData()
        }
    }
    
    private func searchSubs(searchText: String) {
        RedditSession.sharedSession.searchForSubredditByName(searchText, pagination: nil) { (pagination, results, error) -> () in
            if let subreddits = results {
                self.subreddits = subreddits
            }
            
            self.fetchingMore = false
            
            self.hud?.hide(true)
        }
    }
    
    private func sortLinks() {
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
    }
    
    private func searchLinks(searchText: String) {
        if searchText.characters.count > 0 {
            if self.restrictSubreddit.on {
                if let _ = self.subreddit {
                    RedditSession.sharedSession.searchForLinksInSubreddit(self.subreddit,
                        searchText: searchController.searchBar.text!,
                        pagination: self.pagination,
                        completion: { (pagination, results, error) -> () in
                            if error == nil {
                                if let links = results {
                                    self.links.appendContentsOf(links)
                                    self.sortLinks()
                                    self.pagination = pagination
                                }
                            }
                            
                    })
                } else {
                    RedditSession.sharedSession.searchForLinks(searchText,
                        pagination: self.pagination,
                        completion: { (pagination, results, error) -> () in
                            if error == nil {
                                if let links = results {
                                    self.links.appendContentsOf(links)
                                    self.sortLinks()
                                    self.pagination = pagination
                                }
                            }
                            
                    })
                }
            } else {
                RedditSession.sharedSession.searchForLinks(searchText,
                    pagination: self.pagination,
                    completion: { (pagination, results, error) -> () in
                        if error == nil {
                            if let links = results {
                                self.links.appendContentsOf(links)
                                self.sortLinks()
                                self.pagination = pagination
                            }
                        }
                })
            }
        } else {
            self.links = Array<AnyObject>()
            self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setToolbarHidden(true, animated: true)
        
        LocalyticsSession.shared().tagScreen("Search")
        
        var restrictToSubreddit: UIBarButtonItem!
        if let subreddit = self.subreddit {
            restrictToSubreddit = UIBarButtonItem(title: "/r/\(subreddit.name)", style: .Plain, target: self, action: nil)
        } else {
            restrictToSubreddit = UIBarButtonItem(title: "front", style: .Plain, target: self, action: nil)
        }
        
        self.navigationItem.rightBarButtonItems = [restrictToSubredditSwitch, restrictToSubreddit]
        
        if let _ = self.splitViewController {
            self.listButton.action = self.splitViewController!.displayModeButtonItem().action
        }
        
        self.tableView.tableFooterView = UIView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
       
        self.preferredAppearance()
        
        if let _ = self.splitViewController {
            self.navigationItem.titleView = self.searchController.searchBar
        } else {
            self.tableView.tableHeaderView = self.searchController.searchBar
        }
    }

    @IBAction func restrictToSubredditSwitchValueChanged(sender: AnyObject) {
        
    }

    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.filterControl.selectedSegmentIndex == 1 {
            if self.subreddits.count > 0 {
                return self.subreddits.count
            }
        } else {
            if self.links.count > 0 {
                return self.links.count
            }
        }
        
        return 0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if self.filterControl.selectedSegmentIndex == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("SubredditCell") as! SubredditCell
            cell.rkSubreddit = self.subreddits[indexPath.row] as! RKSubreddit
            return cell
        }
        
        var cell = tableView.dequeueReusableCellWithIdentifier("PostImageCell") as! PostCell
        
        if let link = self.links[indexPath.row] as? RKLink {
            if link.hasImage() {
                
                if SettingsManager.defaultManager.valueForSetting(.FullWidthImages) {
                    cell = tableView.dequeueReusableCellWithIdentifier("TitleCell") as! TitleCell
                } else {
                    let imageCell = tableView.dequeueReusableCellWithIdentifier("PostImageCell") as! PostImageCell
                    imageCell.postImageDelegate = self
                    imageCell.link = link
                    imageCell.delegate = self
                    imageCell.postCellDelegate = self
                    return imageCell
                }
                
            } else {
                cell = tableView.dequeueReusableCellWithIdentifier("TitleCell") as! TitleCell
            }
            
            cell.link = link
        }
        
        cell.delegate = self
        cell.postCellDelegate = self
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.searchController.active = false
        
        if self.filterControl.selectedSegmentIndex == 0 {
            if let link = self.links[indexPath.row] as? RKLink {
                if link.selfPost {
                    self.performSegueWithIdentifier("CommentsSegue", sender: link)
                } else {
                    self.performSegueWithIdentifier("SubredditLink", sender: link)
                }
            }
        } else {
            if let subreddit = self.subreddits[indexPath.row] as? RKSubreddit {
                self.performSegueWithIdentifier("SubredditSegue", sender: subreddit)
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
        } else if segue.identifier == "SubredditSegue" {
            if let subreddit = sender as? RKSubreddit {
                if let nav = segue.destinationViewController as? UINavigationController {
                    if let controller = nav.viewControllers[0] as? SubredditViewController {
                        controller.subreddit = subreddit
                        controller.front = false
                    }
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
                if let controller = segue.destinationViewController as? CommentsTreeViewController {
                    controller.link = link
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if self.filterControl.selectedSegmentIndex == 1 {
            return 55
        }
        
        if indexPath.row == self.links.count {
            return 60
        }
        
        if let link = self.links[indexPath.row] as? RKLink {
            if link.hasImage() {
                // Image
                
                if SettingsManager.defaultManager.valueForSetting(.FullWidthImages) {
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
    
    // MARK: UIScrollViewDelegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.searchController.searchBar.resignFirstResponder()
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let endScrolling = scrollView.contentOffset.y + scrollView.frame.size.height
        if endScrolling >= scrollView.contentSize.height && !self.fetchingMore {
            self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            self.fetchingMore = true
            self.search()
        }
    }
    
    func swipeCell(cell: JZSwipeCell!, triggeredSwipeWithType swipeType: JZSwipeType) {
        if swipeType.rawValue != JZSwipeTypeNone.rawValue {
            cell.reset()
            if let indexPath = self.tableView.indexPathForCell(cell) {
                if let link = self.links[indexPath.row] as? RKLink {
                    if !SettingsManager.defaultManager.purchased {
                        if swipeType.rawValue == JZSwipeTypeLongLeft.rawValue {
                            LocalyticsSession.shared().tagEvent("Swipe comments")
                            self.performSegueWithIdentifier("CommentsSegue", sender: link)
                        } else {
                            self.performSegueWithIdentifier("PurchaseSegue", sender: self)
                        }
                    } else {
                        self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                        
                        if swipeType.rawValue == JZSwipeTypeShortLeft.rawValue {
                            // Upvote
                            LocalyticsSession.shared().tagEvent("Swipe upvote")
                            RedditSession.sharedSession.upvote(link, completion: { (error) -> () in
                                self.hud?.hide(true)
                                
                                if error != nil {
                                    UIAlertView(title: "Error!",
                                        message: "Unable to upvote! Please try again!",
                                        delegate: self,
                                        cancelButtonTitle: "Ok").show()
                                } else {
                                    self.search()
                                }
                            })
                        } else if swipeType.rawValue == JZSwipeTypeShortRight.rawValue {
                            LocalyticsSession.shared().tagEvent("Swipe downvote")
                            // Downvote
                            RedditSession.sharedSession.downvote(link, completion: { (error) -> () in
                                self.hud?.hide(true)
                                
                                if error != nil {
                                    UIAlertView(title: "Error!",
                                        message: "Unable to downvote! Please try again!",
                                        delegate: self,
                                        cancelButtonTitle: "Ok").show()
                                } else {
                                    self.search()
                                }
                            })
                        } else if swipeType.rawValue == JZSwipeTypeLongLeft.rawValue {
                            LocalyticsSession.shared().tagEvent("Swipe comments")
                            self.performSegueWithIdentifier("CommentsSegue", sender: link)
                            
                        } else {
                            LocalyticsSession.shared().tagEvent("Swipe more")
                            
                            self.hud?.hide(true)
                            let alertController = UIAlertController(title: "Select option", message: nil, preferredStyle: .ActionSheet)
                            
                            if link.saved() {
                                alertController.addAction(UIAlertAction(title: "unsave", style: .Default, handler: { (action) -> Void in
                                    RedditSession.sharedSession.unSaveLink(link, completion: { (error) -> () in
                                        self.hud?.hide(true)
                                        link.unSaveLink()
                                    })
                                }))
                            } else {
                                alertController.addAction(UIAlertAction(title: "save", style: .Default, handler: { (action) -> Void in
                                    RedditSession.sharedSession.saveLink(link, completion: { (error) -> () in
                                        self.hud?.hide(true)
                                        link.saveLink()
                                    })
                                }))
                            }
                            
                            alertController.addAction(UIAlertAction(title: "hide", style: .Default, handler: { (action) -> Void in
                                RedditSession.sharedSession.hideLink(link, completion: { (error) -> () in
                                    self.hud?.hide(true)
                                    link.hideLink()
                                    
                                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                        self.links.removeAtIndex(indexPath.row)
                                        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                                    })
                                })
                            }))
                            
                            alertController.addAction(UIAlertAction(title: "open in safari", style: .Default, handler: { (action) -> Void in
                                UIApplication.sharedApplication().openURL(link.URL)
                            }))
                            
                            alertController.addAction(UIAlertAction(title: "more options", style: .Default, handler: { (action) -> Void in
                                // Share
                                self.hud?.hide(true)
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
    
    override func preferredAppearance() {
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : MyRedditLabelColor,
            NSFontAttributeName : MyRedditTitleFont]
        
        self.navigationController?.navigationBar.backgroundColor = MyRedditBackgroundColor
        self.navigationController?.navigationBar.barTintColor = MyRedditBackgroundColor
        self.navigationController?.navigationBar.tintColor = MyRedditLabelColor
        
        self.navigationItem.titleView?.backgroundColor = MyRedditBackgroundColor
        
        self.tableView.backgroundColor = MyRedditBackgroundColor
        
        let textFieldInsideSearchBar = self.searchController.searchBar.valueForKey("searchField") as? UITextField
        
        textFieldInsideSearchBar?.textColor = MyRedditLabelColor
        
        self.view.backgroundColor = MyRedditBackgroundColor
        self.restrictToSubredditSwitch.tintColor = MyRedditLabelColor
        self.navigationItem.leftBarButtonItem?.tintColor = MyRedditLabelColor
        self.filterControl.tintColor = MyRedditLabelColor
        
        if let _ = self.splitViewController {
            self.bottomNavigationBar.backgroundColor = MyRedditBackgroundColor
            self.bottomNavigationBar.barTintColor = MyRedditBackgroundColor
            self.bottomNavigationBar.tintColor = MyRedditLabelColor
        }
        
        self.tableView.reloadData()
    }
}
