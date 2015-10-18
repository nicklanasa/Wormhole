//
//  InboxesTableViewController.swift
//  MyReddit
//
//  Created by Nick Lanasa on 5/3/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation
import UIKit

class InboxesTableViewController: RootTableViewController {
    
    @IBOutlet weak var inboxCell: UserInfoCell!
    @IBOutlet weak var unreadCell: UserInfoCell!
    @IBOutlet weak var messagesCell: UserInfoCell!
    @IBOutlet weak var sentCell: UserInfoCell!
    @IBOutlet weak var commentRepliesCell: UserInfoCell!
    @IBOutlet weak var postRepliesCell: UserInfoCell!
    @IBOutlet weak var mentionsCell: UserInfoCell!
    @IBOutlet weak var moderatorCell: UserInfoCell!
    @IBOutlet weak var listButton: UIBarButtonItem!
    
    var selectedCategory: RKMessageCategory!
    
    lazy var inboxRefreshControl: UIRefreshControl! = {
        var control = UIRefreshControl()
        control.attributedTitle = NSAttributedString(string: "", attributes: [NSFontAttributeName : MyRedditCommentTextBoldFont, NSForegroundColorAttributeName : MyRedditLabelColor])
        control.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        return control
    }()
    
    func refresh(sender: AnyObject)
    {
        fetchUnread()
    }
    
    override func viewDidLoad() {
        self.refreshControl = self.inboxRefreshControl
        
        if let splitViewController = self.splitViewController {
            self.listButton.action = splitViewController.displayModeButtonItem().action
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.fetchUnread()
        
        LocalyticsSession.shared().tagScreen("Inboxes")
    }
    
    private func fetchUnread() {
        RedditSession.sharedSession.fetchMessages(nil, category: .Unread, read: false) { (pagination, results, error) -> () in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.unreadCell.infoLabel.text = "\(results?.count ?? 0)"
                self.tableView.reloadData()
                
                self.inboxRefreshControl.endRefreshing()
            })
        }
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            self.selectedCategory = RKMessageCategory(rawValue: UInt(cell.tag))
            self.performSegueWithIdentifier("MessagesSegue", sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "MessagesSegue" {
            if let controller = segue.destinationViewController as? MessagesViewController {
                controller.category = self.selectedCategory
            }
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
        
        self.inboxCell.backgroundColor = MyRedditBackgroundColor
        self.unreadCell.backgroundColor = MyRedditBackgroundColor
        self.messagesCell.backgroundColor = MyRedditBackgroundColor
        self.sentCell.backgroundColor = MyRedditBackgroundColor
        self.commentRepliesCell.backgroundColor = MyRedditBackgroundColor
        self.postRepliesCell.backgroundColor = MyRedditBackgroundColor
        self.mentionsCell.backgroundColor = MyRedditBackgroundColor
        self.moderatorCell.backgroundColor = MyRedditBackgroundColor
        
        self.inboxCell.titleLabel.textColor = MyRedditLabelColor
        self.unreadCell.titleLabel.textColor = MyRedditLabelColor
        self.messagesCell.titleLabel.textColor = MyRedditLabelColor
        self.sentCell.titleLabel.textColor = MyRedditLabelColor
        self.commentRepliesCell.titleLabel.textColor = MyRedditLabelColor
        self.postRepliesCell.titleLabel.textColor = MyRedditLabelColor
        self.mentionsCell.titleLabel.textColor = MyRedditLabelColor
        self.moderatorCell.titleLabel.textColor = MyRedditLabelColor

        self.tableView.reloadData()
    }
}