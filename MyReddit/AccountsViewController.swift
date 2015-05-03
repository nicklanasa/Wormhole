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

class AccountsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    lazy var usersController: NSFetchedResultsController! = {
       var controller = DataManager.manager.datastore.usersController("username",
        ascending: true,
        sectionNameKeyPath: nil)
        
        return controller
    }()
    
    override func viewWillAppear(animated: Bool) {
        var error: NSError?
        
        if self.usersController.performFetch(&error) {
            self.tableView.reloadData()
        }
        
        self.tableView.backgroundColor = MyRedditDarkBackgroundColor
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sectionInfo = self.usersController?.sections?[section] as? NSFetchedResultsSectionInfo {
            return sectionInfo.numberOfObjects
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("AccountCell") as! UserInfoCell
        
        var user = self.usersController?.objectAtIndexPath(indexPath) as! User
        cell.titleLabel.text = user.username
        cell.accessoryType = .DisclosureIndicator
        
        if let currentUser = UserSession.sharedSession.currentUser {
            if user.username == currentUser.username {
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
        
        var user = self.usersController?.objectAtIndexPath(indexPath) as! User
        
        if let currentUser = UserSession.sharedSession.currentUser {
            if user.username == currentUser.username {
                self.performSegueWithIdentifier("ProfileSegue", sender: user)
            } else {
                self.performSegueWithIdentifier("SavedUserLoginSegue", sender: user)
            }
        } else {
            var user = self.usersController?.objectAtIndexPath(indexPath) as! User
            self.performSegueWithIdentifier("SavedUserLoginSegue", sender: user)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SavedUserLoginSegue" {
            if let controller = segue.destinationViewController as? LoginViewController {
                if let user = sender as? User {
                    controller.user = user
                }
            }
        }
    }
}