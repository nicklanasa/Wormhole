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

class MessagesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MessageCellDelegate, LoadMoreHeaderDelegate {
    
    var category: RKMessageCategory!
    var pagination: RKPagination?
    
    var messages = Array<AnyObject>() {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    var readMessages = Array<AnyObject>()
    
    lazy var refreshControl: UIRefreshControl! = {
        var control = UIRefreshControl()
        control.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes: [NSFontAttributeName : MyRedditCommentTextBoldFont, NSForegroundColorAttributeName : MyRedditLabelColor])
        control.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        return control
    }()
    
    func refresh(sender: AnyObject)
    {
        self.fetchMessages()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.addSubview(refreshControl)
        
        self.fetchMessages()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.separatorColor = UIColor.lightGrayColor()
        self.tableView.backgroundColor = MyRedditBackgroundColor
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    
    
    private func fetchMessages() {
        
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
        
        
        RedditSession.sharedSession.fetchMessages(self.pagination, category: self.category, read: true) { (pagination, results, error) -> () in
            self.pagination = pagination
            
            if let messages = results{
                self.messages = messages
            }
            
            self.refreshControl.endRefreshing()
        }
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count + 1
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 107
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        if indexPath.row == self.messages.count {
            var header = tableView.dequeueReusableCellWithIdentifier("LoadMoreHeader") as! LoadMoreHeader
            header.delegate = self
            return header
        }
        
        var cell = tableView.dequeueReusableCellWithIdentifier("MessageCell") as! MessageCell
        
        let message = self.messages[indexPath.row] as! RKMessage
        cell.message = message
        cell.messageCellDelegate = self
    
        return cell
    }
    
    func messageCell(cell: MessageCell, didTapLink link: NSURL) {
        self.performSegueWithIdentifier("MessageLinkSegue", sender: link)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let nav = segue.destinationViewController as? UINavigationController {
            if let controller = nav.viewControllers[0] as? WebViewController {
                controller.url = sender as! NSURL
            }
        }
    }
    
    func loadMoreHeader(header: LoadMoreHeader, didTapButton sender: AnyObject) {
        header.startAnimating()
        
        RedditSession.sharedSession.fetchMessages(self.pagination, category: self.category, read: false) { (pagination, results, error) -> () in
            self.pagination = pagination
            
            if self.pagination != nil {
                if let messages = results {
                    self.messages.extend(messages)
                }
            }
            
            header.stopAnimating()
        }
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if let message = self.messages[indexPath.row] as? RKMessage {
            if message.unread {
                
                var filteredMessages = self.readMessages.filter({ (object) -> Bool in
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