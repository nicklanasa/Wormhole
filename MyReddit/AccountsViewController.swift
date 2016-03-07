//
//  AccountsViewController.swift
//  MyReddit
//
//  Created by Nickolas Lanasa on 5/2/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class AccountsViewController: RootViewController,
UITableViewDelegate,
UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var listButton: UIBarButtonItem!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
        LocalyticsSession.shared().tagScreen("Accounts")
        
        self.navigationController?.setToolbarHidden(false, animated: true)
        
        self.preferredAppearance()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let splitViewController = self.splitViewController {
            self.listButton.action = splitViewController.displayModeButtonItem().action
        }
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        if let _ = self.splitViewController {
            self.navigationController?.popViewControllerAnimated(true)
        } else {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBAction func editButtonTapped(sender: AnyObject) {
        self.tableView.setEditing(true, animated: true)
        self.editButton.action = "finishEditing"
        self.editButton.title = "done"
        
        LocalyticsSession.shared().tagEvent("Edit accounts")
    }
    
    func finishEditing() {
        self.tableView.setEditing(false, animated: true)
        self.editButton.action = "editButtonTapped:"
        self.editButton.title = "edit"
        
        LocalyticsSession.shared().tagEvent("Finish editing accounts")
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UserSession.sharedSession.getUsers()?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AccountCell") as! UserInfoCell
        
        let user = UserSession.sharedSession.getUsers()![indexPath.row]
        cell.titleLabel.text = user.username
        cell.accessoryType = .DisclosureIndicator
        
        if let currentUser = UserSession.sharedSession.currentUser {
            if user.identifier == currentUser.identifier {
                cell.infoLabel.hidden = false
                cell.infoLabel.text = "Current"
            } else {
                cell.infoLabel.hidden = true
            }
        } else {
            cell.infoLabel.hidden = true
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let user = UserSession.sharedSession.getUsers()![indexPath.row]
        
        if let currentUser = UserSession.sharedSession.currentUser {
            if user.username == currentUser.username {
                self.performSegueWithIdentifier("ProfileSegue", sender: user)
            } else {
                self.performSegueWithIdentifier("SavedUserLoginSegue", sender: user)
            }
        } else {
            self.performSegueWithIdentifier("SavedUserLoginSegue", sender: user)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SavedUserLoginSegue" {
            if let controller = segue.destinationViewController as? LoginViewController {
                if let user = sender as? RKUser {
                    controller.user = user
                }
            }
        } else {
            if let controller = segue.destinationViewController as? ProfileViewController {
                controller.hidesBottomBarWhenPushed = false
            }
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .Delete
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete", handler: { (action, indexPath) -> Void in
            
            let user = UserSession.sharedSession.getUsers()![indexPath.row]
            
            if let currentUser = UserSession.sharedSession.currentUser {
                if user.username == currentUser.username {
                    UserSession.sharedSession.logout()
                }
            }
            
            UserSession.sharedSession.deleteUser(user)
            
            self.tableView.reloadData()
            
            LocalyticsSession.shared().tagEvent("Delete account")
        })
        
        return [deleteAction]
    }
    
    override func preferredAppearance() {
        self.tableView.backgroundColor = MyRedditDarkBackgroundColor
        
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
