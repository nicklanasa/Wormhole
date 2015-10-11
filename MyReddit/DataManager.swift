//
//  DataManager.swift
//  SiteworxiOS
//
//  Created by Nick Lanasa on 01/8/15.
//  Copyright (c) 2015 Nickolas Lanasa. All rights reserved.
//

import Foundation
import CoreData

let _manager = DataManager()

class DataManager {
    
    typealias PaginationCompletion = (pagination: RKPagination?, results: [AnyObject]?, error: NSErrorPointer) -> ()
    typealias PaginationCompletionError = (pagination: RKPagination?, results: [AnyObject]?, error: NSError?) -> ()
    
    typealias ErrorCompletion = (error: NSErrorPointer) -> ()
    
    var datastore: Datastore!
    
    class var manager : DataManager {
        return _manager
    }
    
    init() {
        datastore = Datastore(storeName: "MyReddit")
    }
    
    func syncFrontPageLinks(pagination: RKPagination?, category: RKSubredditCategory?, completion: PaginationCompletion) {
        RedditSession.sharedSession.fetchFrontPagePosts(pagination, category: category) { (pagination, results, error) -> () in
            completion(pagination: pagination, results: results, error: nil)
        }
    }
    
    func syncLinksSubreddit(subreddit: RKSubreddit, category: RKSubredditCategory?, pagination: RKPagination?, completion: PaginationCompletion) {
        RedditSession.sharedSession.fetchPostsForSubreddit(subreddit, category: category, pagination: pagination) { (pagination, results, error) -> () in
            completion(pagination: pagination, results: results, error: nil)
        }
    }
}
