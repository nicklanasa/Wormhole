//
//  InboxesTableViewController.swift
//  MyReddit
//
//  Created by Nick Lanasa on 5/3/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation
import UIKit

class InboxesTableViewController: UITableViewController {
    
    @IBOutlet weak var inboxCell: UserInfoCell!
    @IBOutlet weak var unreadCell: UserInfoCell!
    @IBOutlet weak var messagesCell: UserInfoCell!
    @IBOutlet weak var sentCell: UserInfoCell!
    @IBOutlet weak var commentRepliesCell: UserInfoCell!
    @IBOutlet weak var postRepliesCell: UserInfoCell!
    @IBOutlet weak var mentionsCell: UserInfoCell!
    
    var selectedCategory: RKMessageCategory!
    
    override func viewDidLoad() {
        self.tableView.backgroundColor = MyRedditDarkBackgroundColor
        
        RedditSession.sharedSession.fetchMessages(nil, category: .All, read: false) { (pagination, results, error) -> () in
            print(results)
        }
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selectedCategory = RKMessageCategory(rawValue: UInt(indexPath.row))
        self.performSegueWithIdentifier("MessagesSegue", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "MessagesSegue" {
            if let controller = segue.destinationViewController as? MessagesViewController {
                controller.category = self.selectedCategory
            }
        }
    }
}