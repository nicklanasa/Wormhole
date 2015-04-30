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
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentationControl: UISegmentedControl!
    
    @IBAction func segmentationControlValueChanged(sender: AnyObject) {
        self.fetchMessages()
    }
    
    lazy var messagesController: NSFetchedResultsController = {
        
        let controller = DataManager.manager.datastore.messagesController(nil,
            sortKey: "created",
            ascending: false,
            sectionNameKeyPath: nil)
        controller.delegate = self
        return controller
    }()
    
    override func viewDidAppear(animated: Bool) {
        self.fetchMessages()
    }
    
    private func fetchMessages() {
        var error: NSError?
        
        var category: RKMessageCategory!
        var predicate = NSPredicate(format: "type = %d", RKMessageType.Received.rawValue)
        
        if self.segmentationControl.selectedSegmentIndex == 0 {
            category = .Messages
        } else {
            category = .Sent
            predicate = NSPredicate(format: "type = %d", RKMessageType.Sent.rawValue)
        }
        
        self.messagesController.fetchRequest.predicate = predicate
        
        if self.messagesController.performFetch(&error) {
            self.tableView.reloadData()
            
            if let user = UserSession.sharedSession.currentUser {
                DataManager.manager.syncMessages(nil, category: category, completion: { (pagination, results, error) -> () in
                    
                })
            }
        }
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let numberOfRowsInSection = self.messagesController.sections?[section].numberOfObjects {
            return numberOfRowsInSection
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 107
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.messagesController.sections?.count ?? 0
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let message = self.messagesController.objectAtIndexPath(indexPath) as! Message
        
        var cell = tableView.dequeueReusableCellWithIdentifier("MessageCell") as! MessageCell
        cell.message = message
        return cell
    }
}