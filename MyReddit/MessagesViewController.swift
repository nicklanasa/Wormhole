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

class MessagesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    
    var category: RKMessageCategory!
    var pagination: RKPagination?
    
    var messages: Array<AnyObject>? {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidAppear(animated: Bool) {
        self.fetchMessages()
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
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
            self.messages = results
        }
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages?.count ?? 0
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 107
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let message = self.messages?[indexPath.row] as! RKMessage
        
        var cell = tableView.dequeueReusableCellWithIdentifier("MessageCell") as! MessageCell
        cell.message = message
        return cell
    }
}