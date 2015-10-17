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
    
    typealias ErrorCompletion = (error: NSError?) -> ()
    
    init(storeName: String) {
        self.storeName = storeName
        configure()
    }
    
    private func configure() {
        
        let modelURL = NSBundle.mainBundle().URLForResource("MyReddit", withExtension: "momd")
        self.managedObjectModel = NSManagedObjectModel(contentsOfURL: modelURL!)!
        
        let storeUrlString = NSString(format: "%@.sqlite", self.storeName)
        let paths = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory,
            inDomains: NSSearchPathDomainMask.UserDomainMask)
        if let documentsURL = paths.last {
            let storeURL = documentsURL.URLByAppendingPathComponent(storeUrlString as String)
            self.persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
            
            do {
                try self.persistentStoreCoordinator.addPersistentStoreWithType(NSInMemoryStoreType,
                    configuration: nil,
                    URL: storeURL,
                    options: nil)
            } catch {
                print("Unable to get persistentStoreCoordinator...", terminator: "")
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
    
    // MARK: User
    
    func addUser(user: AnyObject?, password: String, completion: (user: User, error: NSError?) -> ()) {
        self.workerContext.performBlock { () -> Void in
            
            var addedUser: User!
            
            if let redditUser = user as? RKUser {
                let request = NSFetchRequest(entityName: "User")
                let predicate = NSPredicate(format: "username = %@", redditUser.username)
                request.fetchLimit = 1
                request.predicate = predicate
                
                let results: [AnyObject]?
                do {
                    results = try self.workerContext.executeFetchRequest(request)
                } catch {
                    results = nil
                }
                
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
    
    func deleteUser(user: User, completion: (error: NSError?) -> ()) {
        self.mainQueueContext.performBlock { () -> Void in
            self.mainQueueContext.deleteObject(user)
            
            self.saveDatastoreWithCompletion({ (error) -> () in
                completion(error: nil)
            })
        }
    }
    
    func usersController(sortKey: NSString, ascending: Bool, sectionNameKeyPath: String?) -> NSFetchedResultsController {
        let request = NSFetchRequest()
        request.entity = NSEntityDescription.entityForName("User",
            inManagedObjectContext: self.mainQueueContext)
        
        let sort = NSSortDescriptor(key: sortKey as String, ascending: ascending)
        request.sortDescriptors = [sort]
        
        let controller = NSFetchedResultsController(fetchRequest: request,
            managedObjectContext: self.mainQueueContext,
            sectionNameKeyPath: sectionNameKeyPath,
            cacheName: nil)
        
        return controller
    }
    
    func saveDatastoreWithCompletion(completion: (error: NSError?) -> ()) {
        
        let totalStartTime = NSDate()
        self.workerContext.performBlock { () -> Void in
            var error: NSError?
            var startTime = NSDate()
            do {
                try self.workerContext.save()
            } catch let error1 as NSError {
                error = error1
            } catch {
                fatalError()
            }
            
            var endTime: NSDate!
            var executionTime: NSTimeInterval!
            
            if error == nil {
                endTime = NSDate()
                executionTime = endTime.timeIntervalSinceDate(startTime)
                NSLog("workerContext saveStore executionTime = %f", (executionTime * 1000));
                
                startTime = NSDate()
                self.mainQueueContext.performBlockAndWait({ () -> Void in
                    do {
                        try self.mainQueueContext.save()
                    } catch let error1 as NSError {
                        error = error1
                    } catch {
                        fatalError()
                    }
                })
                
                if error == nil {
                    endTime = NSDate()
                    executionTime = endTime.timeIntervalSinceDate(startTime)
                    
                    NSLog("mainQueueContext saveStore executionTime = %f",
                        (executionTime * 1000));
                    
                    startTime = NSDate()
                    self.saveContext.performBlockAndWait({ () -> Void in
                        do {
                            try self.saveContext.save()
                        } catch let error1 as NSError {
                            error = error1
                        } catch {
                            fatalError()
                        }
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
    
    private func deleteAllObjectsInStoreWithCompletion(completion: ErrorCompletion) {
        
        clearCache()
        
        self.mainQueueContext.lock()
        self.workerContext.lock()
        
        self.mainQueueContext.reset()
        self.workerContext.reset()
        
        var error: NSError?
        
        if let storeCoordinator = self.mainQueueContext.persistentStoreCoordinator {
            if let store = storeCoordinator.persistentStores.first {
                let storeURL = storeCoordinator.URLForPersistentStore(store)
                
                do {
                    try storeCoordinator.removePersistentStore(store)
                    do {
                        try NSFileManager.defaultManager().removeItemAtURL(storeURL)
                    } catch let error1 as NSError {
                        error = error1
                    }
                } catch let error1 as NSError {
                    error = error1
                }
                
                do {
                    _ = try persistentStoreCoordinator.addPersistentStoreWithType(NSInMemoryStoreType,
                        configuration: nil,
                        URL: storeURL,
                        options: nil)
                    self.workerContext.unlock()
                    self.mainQueueContext.unlock()
                    completion(error: nil)
                } catch let error1 as NSError {
                    error = error1
                    // TODO: Handling not being about to create new store...
                    completion(error: error)
                }
            }
        }
    }
}