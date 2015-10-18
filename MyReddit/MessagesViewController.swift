//
//  MessagesViewController.swift
//  MyReddit
//
//  Created by Nickolas Lanasa on 3/26/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class MessagesViewController: RootViewController,
UITableViewDataSource,
UITableViewDelegate,
MessageCellDelegate,
JZSwipeCellDelegate {
    
    var category: RKMessageCategory!
    
    var pagination: RKPagination? {
        didSet {
            self.fetchingMore = false
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                self.hud?.hide(true)
            }
        }
    }
    
    var fetchingMore = false
    
    var hud: MBProgressHUD? {
        didSet {
            hud?.labelFont = MyRedditSelfTextFont
            hud?.mode = .Indeterminate
            hud?.labelText = "Loading"
        }
    }
    
    var messages = Array<AnyObject>() {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    var readMessages = Array<AnyObject>()
    
    lazy var refreshControl: UIRefreshControl! = {
        var control = UIRefreshControl()
        control.attributedTitle = NSAttributedString(string: "",
            attributes: [NSFontAttributeName : MyRedditCommentTextBoldFont, NSForegroundColorAttributeName : MyRedditLabelColor])
        control.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        return control
    }()
    
    func refresh(sender: AnyObject) {
        self.fetchMessages()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.addSubview(refreshControl)
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.tableView.tableFooterView = UIView()
        
        self.tableView.reloadData()
        self.fetchMessages()
        
        self.preferredAppearance()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        LocalyticsSession.shared().tagScreen("Messages")
    }
    
    @IBOutlet weak var tableView: UITableView!

    private func fetchMessages() {
        
        LocalyticsSession.shared().tagEvent("Fetch Messages")
        
        if let messageCategory = self.category {
            switch messageCategory {
            case .CommentReplies: self.navigationItem.title = "Comment Replies"
            case .Messages: self.navigationItem.title = "Messages"
            case .Moderator: self.navigationItem.title = "Moderator"
            case .PostReplies: self.navigationItem.title = "Post Replies"
            case .Sent: self.navigationItem.title = "Sent"
            case .Unread: self.navigationItem.title = "Unread"
            case .UsernameMentions: self.navigationItem.title = "Mentions"
            default: self.navigationItem.title = "Inbox"
            }
        }
        
        RedditSession.sharedSession.fetchMessages(self.pagination,
            category: self.category,
            read: true) { (pagination, results, error) -> () in
            self.pagination = pagination
            
            if let messages = results{
                self.messages = messages
            }
            
            self.refreshControl.endRefreshing()
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        if SettingsManager.defaultManager.valueForSetting(.NightMode) {
            return .LightContent
        } else {
            return .Default
        }
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 107
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("MessageCell") as! MessageCell
        
        let message = self.messages[indexPath.row] as! RKMessage
        cell.message = message
        cell.messageCellDelegate = self
        cell.delegate = self
    
        return cell
    }
    
    func messageCell(cell: MessageCell, didTapLink link: NSURL) {
        self.performSegueWithIdentifier("MessageLinkSegue", sender: link)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "MessageLinkSegue" {
            if let nav = segue.destinationViewController as? UINavigationController {
                if let controller = nav.viewControllers[0] as? WebViewController {
                    controller.url = sender as! NSURL
                }
            }
        } else if let controller = segue.destinationViewController as? AddCommentViewController {
            if let message = sender as? RKMessage {
                controller.message = message
            }
        }
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if self.messages.count > 0 {
            if indexPath.row != self.messages.count {
                if let message = self.messages[indexPath.row] as? RKMessage {
                    if message.unread {
                        
                        let filteredMessages = self.readMessages.filter({ (object) -> Bool in
                            if let readMessage = object as? RKMessage {
                                return readMessage.identifier == message.identifier
                            }
                            
                            return false
                        })
                        
                        if filteredMessages.count == 0 {
                            RedditSession.sharedSession.markMessagesAsRead([message], completion: { (error) -> () in
                                self.readMessages.append(message)
                            })
                        }
                    }
                }
            }
        }
    }
    
    func swipeCell(cell: JZSwipeCell!, triggeredSwipeWithType swipeType: JZSwipeType) {
        
        if let indexPath = self.tableView.indexPathForCell(cell) {
            if swipeType.rawValue != JZSwipeTypeNone.rawValue {
                cell.reset()
                
                if swipeType.rawValue == JZSwipeTypeLongLeft.rawValue || swipeType.rawValue == JZSwipeTypeShortLeft.rawValue {
                    if !SettingsManager.defaultManager.purchased {
                        self.performSegueWithIdentifier("PurchaseSegue", sender: self)
                    } else {
                        if let message = self.messages[indexPath.row] as? RKMessage {
                            self.performSegueWithIdentifier("ReplyToMessageSegue", sender: message)
                        }
                        
                        LocalyticsSession.shared().tagEvent("Reply to message")
                    }
                } else {
                    if !SettingsManager.defaultManager.purchased {
                        self.performSegueWithIdentifier("PurchaseSegue", sender: self)
                    } else {
                        LocalyticsSession.shared().tagEvent("Swipe more")
                        
                        let alertController = UIAlertController(title: "Select option", message: nil, preferredStyle: .ActionSheet)
                        
                        if self.category == .Unread {
                            alertController.addAction(UIAlertAction(title: "mark read", style: .Default, handler: { (action) -> Void in
                                
                                if let message = self.messages[indexPath.row] as? RKMessage {
                                    // Mark unread
                                    RedditSession.sharedSession.markMessagesAsRead([message], completion: { (error) -> () in
                                        self.messages.removeAtIndex(indexPath.row)
                                        self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
                                    })
                                }
                            }))
                        } else {
                            alertController.addAction(UIAlertAction(title: "mark unread", style: .Default, handler: { (action) -> Void in
                                
                                if let message = self.messages[indexPath.row] as? RKMessage {
                                    // Mark unread
                                    RedditSession.sharedSession.markMessagesAsUnRead([message], completion: { (error) -> () in
                                        self.messages.removeAtIndex(indexPath.row)
                                        self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
                                    })
                                }
                            }))
                        }
                        
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
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let endScrolling = scrollView.contentOffset.y + scrollView.frame.size.height
        if endScrolling >= scrollView.contentSize.height && !self.fetchingMore {
            self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            self.fetchingMore = true
            self.fetchMessages()
        }
    }
    
    override func preferredAppearance() {
        self.tableView.separatorColor = UIColor.lightGrayColor()
        self.tableView.backgroundColor = MyRedditBackgroundColor
        
        self.navigationController?.navigationBar.backgroundColor = MyRedditBackgroundColor
        self.navigationController?.navigationBar.barTintColor = MyRedditBackgroundColor
        self.navigationController?.navigationBar.tintColor = MyRedditLabelColor
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : MyRedditLabelColor,
            NSFontAttributeName : MyRedditTitleFont]
        
        self.navigationController?.toolbar.barTintColor = MyRedditBackgroundColor
        self.navigationController?.toolbar.backgroundColor = MyRedditBackgroundColor
        self.navigationController?.toolbar.tintColor = MyRedditLabelColor
        self.navigationController?.toolbar.translucent = false
        
        self.tableView.reloadData()
    }
}