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
    
    lazy var subredditsController: NSFetchedResultsController = {
        let controller = DataManager.manager.datastore.subredditsController(nil,
            sortKey: "name",
            ascending: true,
            sectionNameKeyPath: nil)
        controller.delegate = self
        return controller
    }()
    
    override func viewWillAppear(animated: Bool) {
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
        }
    }
    
    func syncSubreddits(pagination: RKPagination?) {
        if UserSession.sharedSession.isSignedIn {
            DataManager.manager.syncSubcribedSubreddits(pagination, completion: { (pagination, results, error) -> () in
                if pagination != nil {
                    self.syncSubreddits(pagination)
                }
            })
        } else {
            DataManager.manager.syncPopularSubreddits(pagination, completion: { (pagination, results, error) -> () in
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
    
    @IBAction func messagesButtonTapped(sender: AnyObject) {
        if NSUserDefaults.standardUserDefaults().objectForKey("purchased") == nil {
            self.performSegueWithIdentifier("PurchaseSegue", sender: self)
        } else {
            self.performSegueWithIdentifier("MessagesSegue", sender: self)
        }
    }
    
    @IBAction func loginButtonTapped(sender: AnyObject) {
        /*
        if NSUserDefaults.standardUserDefaults().objectForKey("purchased") == nil {
            self.performSegueWithIdentifier("PurchaseSegue", sender: self)
        } else {
*/
            if UserSession.sharedSession.isSignedIn {
                self.performSegueWithIdentifier("ProfileSegue", sender: self)
            } else {
                self.performSegueWithIdentifier("LoginSegue", sender: self)
            }
        //}
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