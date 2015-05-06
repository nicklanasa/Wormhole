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

class AccountsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    lazy var usersController: NSFetchedResultsController! = {
       var controller = DataManager.manager.datastore.usersController("username",
        ascending: true,
        sectionNameKeyPath: nil)
        controller.delegate = self
        return controller
    }()
    
    override func viewWillAppear(animated: Bool) {
        var error: NSError?
        
        if self.usersController.performFetch(&error) {
            self.tableView.reloadData()
        }
        
        self.tableView.backgroundColor = MyRedditDarkBackgroundColor
    }
    
    // MARK: Sectors NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(controller: NSFetchedResultsController)
    {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController,
        didChangeObject anObject: AnyObject,
        atIndexPath indexPath: NSIndexPath?,
        forChangeType type: NSFetchedResultsChangeType,
        newIndexPath: NSIndexPath?)
    {
        var tableView = self.tableView
        var indexPaths:[NSIndexPath] = [NSIndexPath]()
        switch type {
            
        case .Insert:
            indexPaths.append(newIndexPath!)
            tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
            
        case .Delete:
            indexPaths.append(indexPath!)
            tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
            
        case .Update:
            indexPaths.append(indexPath!)
            tableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
            
        case .Move:
            indexPaths.append(indexPath!)
            tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
            indexPaths.removeAtIndex(0)
            indexPaths.append(newIndexPath!)
            tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
        }
    }
    
    func controller(controller: NSFetchedResultsController,
        didChangeSection sectionInfo: NSFetchedResultsSectionInfo,
        atIndex sectionIndex: Int,
        forChangeType type: NSFetchedResultsChangeType)
    {
        switch type {
            
        case .Insert:
            self.tableView.insertSections(NSIndexSet(index: sectionIndex),
                withRowAnimation: .Fade)
            
        case .Delete:
            self.tableView.deleteSections(NSIndexSet(index: sectionIndex),
                withRowAnimation: .Fade)
            
        case .Update, .Move: println("Move or delete called in didChangeSection")
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController)
    {
        self.tableView.endUpdates()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func editButtonTapped(sender: AnyObject) {
        self.tableView.setEditing(true, animated: true)
        self.editButton.action = "finishEditing"
        self.editButton.title = "done"
    }
    
    func finishEditing() {
        self.tableView.setEditing(false, animated: true)
        self.editButton.action = "editButtonTapped:"
        self.editButton.title = "edit"
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
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .Delete
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete", handler: { (action, indexPath) -> Void in
            
            var user = self.usersController?.objectAtIndexPath(indexPath) as! User
            
            if let currentUser = UserSession.sharedSession.currentUser {
                if user.username == currentUser.username {
                    UserSession.sharedSession.logout()
                }
            }
            
            DataManager.manager.datastore.deleteUser(user, completion: { (error) -> () in
                self.tableView.reloadData()
            })
        })
        
        return [deleteAction]
    }
}