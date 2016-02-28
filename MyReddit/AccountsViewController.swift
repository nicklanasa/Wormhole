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
UITableViewDataSource,
NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var listButton: UIBarButtonItem!
    
    lazy var usersController: NSFetchedResultsController! = {
       var controller = DataManager.manager.datastore.usersController("username",
        ascending: true,
        sectionNameKeyPath: nil)
        controller.delegate = self
        return controller
    }()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        do {
            try self.usersController.performFetch()
            self.tableView.reloadData()
        } catch {}
        
        LocalyticsSession.shared().tagScreen("Accounts")
        
        if let splitViewController = self.splitViewController {
            self.listButton.action = splitViewController.displayModeButtonItem().action
        }
        self.preferredAppearance()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.setToolbarHidden(true, animated: false)
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
        let tableView = self.tableView
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
            
        case .Update, .Move: print("Move or delete called in didChangeSection")
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
        if let sectionInfo = self.usersController?.sections?[section] {
            return sectionInfo.numberOfObjects
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AccountCell") as! UserInfoCell
        
        let user = self.usersController?.objectAtIndexPath(indexPath) as! User
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
        
        let user = self.usersController?.objectAtIndexPath(indexPath) as! User
        
        if let currentUser = UserSession.sharedSession.currentUser {
            if user.username == currentUser.username {
                self.performSegueWithIdentifier("ProfileSegue", sender: user)
            } else {
                self.performSegueWithIdentifier("SavedUserLoginSegue", sender: user)
            }
        } else {
            let user = self.usersController?.objectAtIndexPath(indexPath) as! User
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
            
            let user = self.usersController?.objectAtIndexPath(indexPath) as! User
            
            if let currentUser = UserSession.sharedSession.currentUser {
                if user.username == currentUser.username {
                    UserSession.sharedSession.logout()
                }
            }
            
            DataManager.manager.datastore.deleteUser(user, completion: { (error) -> () in
                self.tableView.reloadData()
                
                LocalyticsSession.shared().tagEvent("Delete account")
            })
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
