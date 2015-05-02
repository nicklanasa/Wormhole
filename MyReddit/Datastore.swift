//
//  Datastore.swift
//  SiteworxiOS
//
//  Created by Nick Lanasa on 01/8/15.
//  Copyright (c) 2015 Nickolas Lanasa. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Datastore {
    
    let storeName: String
    
    var managedObjectModel: NSManagedObjectModel!
    var saveContext: NSManagedObjectContext!
    var workerContext: NSManagedObjectContext!
    var mainQueueContext: NSManagedObjectContext!
    var persistentStoreCoordinator: NSPersistentStoreCoordinator!
    
    init(storeName: String) {
        self.storeName = storeName
        configure()
    }
    
    private func configure() {
        let modelURL = NSBundle.mainBundle().URLForResource("MyReddit", withExtension: "momd")
        self.managedObjectModel = NSManagedObjectModel(contentsOfURL: modelURL!)!
        
        let storeUrlString = NSString(format: "%@.sqlite", self.storeName)
        let paths = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask)
        if let documentsURL = paths.last as? NSURL {
            let storeURL = documentsURL.URLByAppendingPathComponent(storeUrlString as String)
            self.persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
            
            var error: NSErrorPointer = nil
            
            if self.persistentStoreCoordinator.addPersistentStoreWithType(NSSQLiteStoreType,
                configuration: nil,
                URL: storeURL,
                options: nil,
                error: error) == false {
                    assert(true, "Unable to get persistentStoreCoordinator...")
            }
            
            self.saveContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
            self.saveContext.persistentStoreCoordinator = self.persistentStoreCoordinator
            self.saveContext.undoManager = nil
            
            self.mainQueueContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
            self.mainQueueContext.undoManager = nil
            self.mainQueueContext.parentContext = self.saveContext
            
            self.workerContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
            self.workerContext.undoManager = nil
            self.workerContext.parentContext = self.mainQueueContext
            
        }
    }
 
    // MARK: Saving
    
    func addLinksForSubreddit(subreddit: Subreddit?, results: [AnyObject]?, completion: (results: [Link], error: NSErrorPointer) -> ()) {
        self.mainQueueContext.performBlock { () -> Void in
            
            var addedLinks: [Link] = []
            
            if let links = results {
                for link in links as! [RKLink] {
                    var request = NSFetchRequest(entityName: "Link")
                    print(link.identifier)
                    let predicate = NSPredicate(format: "identifier = %@", link.identifier)
                    request.fetchLimit = 1
                    request.predicate = predicate
                    
                    var error: NSError? = nil
                    let results = self.mainQueueContext.executeFetchRequest(request, error: &error)
                    
                    var managedLink: Link
                    if results?.count > 0 {
                        managedLink = results?[0] as! Link
                    } else {
                        managedLink = NSEntityDescription.insertNewObjectForEntityForName("Link",
                            inManagedObjectContext: self.mainQueueContext) as! Link
                    }
                    
                    managedLink.parseLink(link)
                    
                    // For all posts not on front.
                    if let postsSubreddit = subreddit {
                        postsSubreddit.modifiedDate = NSDate()
                        managedLink.subreddit = postsSubreddit
                    }
                    
                    addedLinks.append(managedLink)
                }
            }
            
            
            self.saveDatastoreWithCompletion({ (error) -> () in
                completion(results: addedLinks, error: error)
            })
            
        }
    }
    
    func addSubreddits(results: [AnyObject]?, completion: (results: [Subreddit], error: NSErrorPointer) -> ()) {
        self.workerContext.performBlock { () -> Void in
            
            var addedSubreddits: [Subreddit] = []
            
            if let subreddits = results {
                for subreddit in subreddits as! [RKSubreddit] {
                    var request = NSFetchRequest(entityName: "Subreddit")
                    let predicate = NSPredicate(format: "identifier = %@", subreddit.fullName)
                    request.fetchLimit = 1
                    request.predicate = predicate
                    
                    var error: NSError? = nil
                    let results = self.workerContext.executeFetchRequest(request, error: &error)
                    
                    var managedSubreddit: Subreddit
                    if results?.count > 0 {
                        managedSubreddit = results?[0] as! Subreddit
                    } else {
                        managedSubreddit = NSEntityDescription.insertNewObjectForEntityForName("Subreddit",
                            inManagedObjectContext: self.workerContext) as! Subreddit
                    }
                    
                    managedSubreddit.parseSubreddit(subreddit)
                    
                    addedSubreddits.append(managedSubreddit)
                }
            }
            
            self.saveDatastoreWithCompletion({ (error) -> () in
                completion(results: addedSubreddits, error: error)
            })
        }
    }
    
    func removeAllSubreddits(completion: (error: NSErrorPointer) -> ()) {
        self.workerContext.performBlock { () -> Void in
            var request = NSFetchRequest(entityName: "Subreddit")
            var error: NSError? = nil
            let results = self.workerContext.executeFetchRequest(request, error: &error)
            
            for subreddit in results as! [Subreddit] {
                self.workerContext.deleteObject(subreddit)
            }
            
            self.saveDatastoreWithCompletion({ (error) -> () in
                completion(error: error)
            })
        }
    }
    
    func addSubreddit(subscriber: Bool, subredditData: [String : AnyObject], completion: (results: [Subreddit], error: NSErrorPointer) -> ()) {
        var request = NSFetchRequest(entityName: "Subreddit")
        
        var addedSubreddits: [Subreddit] = []
        
        if let fullName = subredditData["id"] as? String {
            let predicate = NSPredicate(format: "identifier = %@", fullName)
            request.fetchLimit = 1
            request.predicate = predicate
            
            var error: NSError? = nil
            let results = self.workerContext.executeFetchRequest(request, error: &error)
            
            var managedSubreddit: Subreddit
            if results?.count > 0 {
                managedSubreddit = results?[0] as! Subreddit
            } else {
                managedSubreddit = NSEntityDescription.insertNewObjectForEntityForName("Subreddit",
                    inManagedObjectContext: self.workerContext) as! Subreddit
            }
            
            managedSubreddit.parseSubreddit(subredditData)
            
            addedSubreddits.append(managedSubreddit)
        }
        
        self.saveDatastoreWithCompletion({ (error) -> () in
            completion(results: addedSubreddits, error: error)
        })
    }
    
    func subscribeToSubreddit(subreddit: Subreddit, completion: (error: NSErrorPointer) -> ()) {
        subreddit.subscriber = NSNumber(bool: true)
        
        self.saveDatastoreWithCompletion({ (error) -> () in
            completion(error: error)
        })
    }
    
    func unsubscribeToSubreddit(subreddit: Subreddit, completion: (error: NSErrorPointer) -> ()) {
        subreddit.subscriber = NSNumber(bool: false)
        
        self.saveDatastoreWithCompletion({ (error) -> () in
            completion(error: error)
        })
    }
    
    func addMessages(results: [AnyObject]?, completion: (results: [Message], error: NSError?) -> ()) {
        self.workerContext.performBlock { () -> Void in
            
            var addedMessages: [Message] = []
            
            if let messages = results {
                for message in messages as! [RKMessage] {
                    var request = NSFetchRequest(entityName: "Message")
                    let predicate = NSPredicate(format: "identifier = %@", message.identifier)
                    request.fetchLimit = 1
                    request.predicate = predicate
                    
                    var error: NSError? = nil
                    let results = self.workerContext.executeFetchRequest(request, error: &error)
                    
                    var managedMessage: Message
                    if results?.count > 0 {
                        managedMessage = results?[0] as! Message
                    } else {
                        managedMessage = NSEntityDescription.insertNewObjectForEntityForName("Message",
                            inManagedObjectContext: self.workerContext) as! Message
                    }
                    
                    managedMessage.parseMessage(message)
                    addedMessages.append(managedMessage)
                }
            }
            
            self.saveDatastoreWithCompletion({ (error) -> () in
                completion(results: addedMessages, error: nil)
            })
        }
    }
    
    // MARK: User
    
    func addUser(user: AnyObject?, password: String, completion: (user: User, error: NSError?) -> ()) {
        self.workerContext.performBlock { () -> Void in
            
            var addedUser: User!
            
            if let redditUser = user as? RKUser {
                var request = NSFetchRequest(entityName: "User")
                let predicate = NSPredicate(format: "username = %@", redditUser.username)
                request.fetchLimit = 1
                request.predicate = predicate
                
                var error: NSError? = nil
                let results = self.workerContext.executeFetchRequest(request, error: &error)
                
                var managedUser: User
                if results?.count > 0 {
                    managedUser = results?[0] as! User
                } else {
                    managedUser = NSEntityDescription.insertNewObjectForEntityForName("User",
                        inManagedObjectContext: self.workerContext) as! User
                }
                
                managedUser.parseUser(redditUser, password: password)
                
                addedUser = managedUser
            }
            
            self.saveDatastoreWithCompletion({ (error) -> () in
                completion(user: addedUser, error: nil)
            })
            
        }
    }
    
    func usersController(sortKey: NSString, ascending: Bool, sectionNameKeyPath: String?) -> NSFetchedResultsController {
        var request = NSFetchRequest()
        request.entity = NSEntityDescription.entityForName("User",
            inManagedObjectContext: self.mainQueueContext)
        
        var sort = NSSortDescriptor(key: sortKey as String, ascending: ascending)
        request.sortDescriptors = [sort]
        
        var controller = NSFetchedResultsController(fetchRequest: request,
            managedObjectContext: self.mainQueueContext,
            sectionNameKeyPath: sectionNameKeyPath,
            cacheName: nil)
        
        return controller
    }
    
    func messagesController(predicate: NSPredicate?, sortKey: NSString, ascending: Bool, sectionNameKeyPath: String?) -> NSFetchedResultsController {
        
        var request = NSFetchRequest()
        request.entity = NSEntityDescription.entityForName("Message",
            inManagedObjectContext: self.mainQueueContext)
        
        if let subredditPredicate = predicate {
            request.predicate = subredditPredicate
        }
        
        var sort = NSSortDescriptor(key: sortKey as String, ascending: ascending)
        request.sortDescriptors = [sort]
        
        var controller = NSFetchedResultsController(fetchRequest: request,
            managedObjectContext: self.mainQueueContext,
            sectionNameKeyPath: sectionNameKeyPath,
            cacheName: nil)
        
        return controller
    }
    
    func subredditsController(predicate: NSPredicate?, sortKey: NSString, ascending: Bool, sectionNameKeyPath: String?) -> NSFetchedResultsController {
        
        var request = NSFetchRequest()
        request.entity = NSEntityDescription.entityForName("Subreddit",
            inManagedObjectContext: self.mainQueueContext)
        
        if let subredditPredicate = predicate {
            request.predicate = subredditPredicate
        }
        
        var sort = NSSortDescriptor(key: sortKey as String, ascending: ascending)
        request.sortDescriptors = [sort]
        
        return NSFetchedResultsController(fetchRequest: request,
            managedObjectContext: self.mainQueueContext,
            sectionNameKeyPath: sectionNameKeyPath,
            cacheName: nil)
    }
    
    func subredditLinksControllerForSubreddit(subreddit: Subreddit?, predicate: NSPredicate?) -> NSFetchedResultsController {
        
        var request = NSFetchRequest()
        request.entity = NSEntityDescription.entityForName("Link",
            inManagedObjectContext: self.mainQueueContext)
        
        if let postsSubreddit = subreddit {
            request.predicate = NSPredicate(format: "subreddit.identifier = %@", postsSubreddit.identifier)
        } else {
            request.predicate = NSPredicate(format: "subreddit.identifier = nil")
        }
        
        request.sortDescriptors = []
        
        return NSFetchedResultsController(fetchRequest: request,
            managedObjectContext: self.mainQueueContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
    }
    
    func saveDatastoreWithCompletion(completion: (error: NSErrorPointer) -> ()) {
        let totalStartTime = NSDate()
        self.workerContext.performBlock { () -> Void in
            var error = NSErrorPointer()
            var startTime = NSDate()
            self.workerContext.save(error)
            
            var endTime: NSDate!
            var executionTime: NSTimeInterval!
            
            if error == nil {
                endTime = NSDate()
                executionTime = endTime.timeIntervalSinceDate(startTime)
                NSLog("workerContext saveStore executionTime = %f", (executionTime * 1000));
                
                startTime = NSDate()
                self.mainQueueContext.performBlockAndWait({ () -> Void in
                    let success = self.mainQueueContext.save(error)
                })
                
                if error == nil {
                    endTime = NSDate()
                    executionTime = endTime.timeIntervalSinceDate(startTime)
                    
                    NSLog("mainQueueContext saveStore executionTime = %f",
                    (executionTime * 1000));
                    
                    startTime = NSDate()
                    self.saveContext.performBlockAndWait({ () -> Void in
                        let success = self.saveContext.save(error)
                    })
                }
            }
            
            endTime = NSDate()
            executionTime = endTime.timeIntervalSinceDate(startTime)
            NSLog("workerContext saveStore executionTime = %f", (executionTime * 1000));
            
            let totalEndTime = NSDate()
            executionTime = totalEndTime.timeIntervalSinceDate(totalStartTime)
            NSLog("Total Time saveStore executionTime = %f", (executionTime * 1000));

            completion(error: error)
        }
    }
    
    private func clearCache() {
        NSFetchedResultsController.deleteCacheWithName(nil)
    }
    
    private func deleteAllObjectsInStoreWithCompletion(completion: (error: NSError?) -> ()) {
        clearCache()
        
        self.mainQueueContext.lock()
        self.workerContext.lock()
        
        self.mainQueueContext.reset()
        self.workerContext.reset()
        
        var error: NSError?
        
        if let storeCoordinator = self.mainQueueContext.persistentStoreCoordinator {
            if let store = storeCoordinator.persistentStores.first as? NSPersistentStore {
                let storeURL = storeCoordinator.URLForPersistentStore(store)
                
                if storeCoordinator.removePersistentStore(store, error: &error) {
                    NSFileManager.defaultManager().removeItemAtURL(storeURL, error: &error)
                }
                
                if let newStore = persistentStoreCoordinator.addPersistentStoreWithType(NSSQLiteStoreType,
                    configuration: nil,
                    URL: storeURL,
                    options: nil,
                    error: &error) {
                    self.workerContext.unlock()
                    self.mainQueueContext.unlock()
                    completion(error: error)
                } else {
                    // TODO: Handling not being about to create new store...
                    completion(error: error)
                }
            }
        }
    }
}