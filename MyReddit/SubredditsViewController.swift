//
//  SubredditsViewController.swift
//  MyReddit
//
//  Created by Nickolas Lanasa on 3/25/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class SubredditsViewController: UIViewController, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!

    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.modalTransitionStyle = .CrossDissolve
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func editButtonTApped(sender: AnyObject) {
        self.tableView.setEditing(true, animated: true)
        
        if let barButton = sender as? UIBarButtonItem {
            barButton.action = "finishEditing:"
            barButton.title = "Done"
        }
    }
    
    func finishEditing(sender: AnyObject) {
        self.tableView.setEditing(false, animated: true)
        
        if let barButton = sender as? UIBarButtonItem {
            barButton.action = "editButtonTApped:"
            barButton.title = "Edit"
        }
    }
    
    lazy var subredditsController: NSFetchedResultsController = {
        let controller = DataManager.manager.datastore.subredditsController(nil,
            sortKey: "name",
            ascending: true,
            sectionNameKeyPath: nil)
        controller.delegate = self
        return controller
    }()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.fetchSubreddits()
    }
    
    func fetchSubreddits() {
        
        if UserSession.sharedSession.isSignedIn {
            self.subredditsController.fetchRequest.predicate = NSPredicate(format: "subscriber = %@", NSNumber(bool: true))
        } else {
            self.subredditsController.fetchRequest.predicate = nil
        }
        
        var error: NSError?
        if self.subredditsController.performFetch(&error) {
            self.syncSubreddits(nil)
            
            self.tableView.reloadData()
        }
    }
    
    func syncSubreddits(pagination: RKPagination?) {
        if UserSession.sharedSession.isSignedIn {
            DataManager.manager.syncSubcribedSubreddits(pagination, completion: { (pagination, results, error) -> () in
                if pagination != nil {
                    self.syncSubreddits(pagination)
                } else {
                    self.tableView.reloadData()
                }
            })
        } else {
            DataManager.manager.syncPopularSubreddits(pagination, completion: { (pagination, results, error) -> () in
                self.tableView.reloadData()
            })
        }
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
            tableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: .None)
            
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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let numberOfRowsInSection = self.subredditsController.sections?[section].numberOfObjects {
            return numberOfRowsInSection + 1
        } else {
            return 0
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.subredditsController.sections?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("SubredditCell") as! SubredditCell
        
        if indexPath.row == 0 {
            return tableView.dequeueReusableCellWithIdentifier("FrontCell") as! UITableViewCell
        } else {
            var modifiedIndexPath = NSIndexPath(forRow: indexPath.row - 1, inSection: 0)
            let subreddit = self.subredditsController.objectAtIndexPath(modifiedIndexPath) as! Subreddit
            
            cell.subreddit = subreddit
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return self.subredditsController.sectionForSectionIndexTitle(title, atIndex: index)
    }
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [AnyObject]! {
        return self.subredditsController.sectionIndexTitles
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.row == 0 {
            return false
        }
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            var modifiedIndexPath = NSIndexPath(forRow: indexPath.row - 1, inSection: 0)
            var subreddit = self.subredditsController.objectAtIndexPath(modifiedIndexPath) as! Subreddit
            RedditSession.sharedSession.unsubscribe(subreddit, completion: { (error) -> () in
                if error != nil {
                    UIAlertView(title: "Error!", message: "Unable to unsubscribe to Subreddit! Please make sure you're connected to the internets.", delegate: self, cancelButtonTitle: "Ok").show()
                } else {
                    
                    subreddit = self.subredditsController.objectAtIndexPath(indexPath) as! Subreddit
                    DataManager.manager.datastore.mainQueueContext.deleteObject(subreddit)
                    
                    DataManager.manager.datastore.saveDatastoreWithCompletion({ (error) -> () in
                        self.subredditsController.performFetch(nil)
                    })
                }
            })
        }
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default,
            title: "Delete",
            handler: { (action, indexPath) -> Void in
                
        })
        
        return [deleteAction]
    }
    
    @IBAction func messagesButtonTapped(sender: AnyObject) {
        if NSUserDefaults.standardUserDefaults().objectForKey("purchased") == nil {
            self.performSegueWithIdentifier("PurchaseSegue", sender: self)
        } else {
            self.performSegueWithIdentifier("MessagesSegue", sender: self)
        }
    }
    
    @IBAction func loginButtonTapped(sender: AnyObject) {
//        if NSUserDefaults.standardUserDefaults().objectForKey("purchased") == nil {
//            self.performSegueWithIdentifier("PurchaseSegue", sender: self)
//        } else {
//            if UserSession.sharedSession.isSignedIn {
//                self.performSegueWithIdentifier("ProfileSegue", sender: self)
//            } else {
//                self.performSegueWithIdentifier("LoginSegue", sender: self)
//            }
//        }
        
        if UserSession.sharedSession.isSignedIn {
            self.performSegueWithIdentifier("ProfileSegue", sender: self)
        } else {
            self.performSegueWithIdentifier("LoginSegue", sender: self)
        }

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SubredditPosts" {
            if let controller = segue.destinationViewController as? NavBarController {
                if let subredditViewController = controller.viewControllers[0] as? SubredditViewController {
                    if let cell = sender as? UITableViewCell {
                        
                        var indexPath: NSIndexPath = self.tableView.indexPathForCell(cell)!
                        
                        if indexPath.row != 0 {
                            indexPath = NSIndexPath(forRow: indexPath.row - 1, inSection: 0)
                            if let subreddit = self.subredditsController.objectAtIndexPath(indexPath) as? Subreddit {
                                subredditViewController.subreddit = subreddit
                                subredditViewController.front = false
                            }
                        }
                    }
                }
            }
        }
    }
}