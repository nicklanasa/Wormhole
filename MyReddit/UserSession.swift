//
//  UserSession.swift
//  MyReddit
//
//  Created by Nickolas Lanasa on 3/25/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation

let _sharedUserSession = UserSession()

class UserSession {
    
    typealias PaginationCompletion = (pagination: RKPagination?, results: [AnyObject]?, error: NSError?) -> ()
    typealias ErrorCompletion = (error: NSError?) -> ()
    
    init() {
        
    }
    
    class var sharedSession : UserSession {
        return _sharedUserSession
    }
    
    var isSignedIn: Bool {
        get {
            return RKClient.sharedClient().isSignedIn()
        }
    }
    
    var currentUser: User?
    
    func logout() {
        RKClient.sharedClient().signOut()
    }
    
    func loginWithUsername(username: String, password: String, completion: ErrorCompletion) {
        RKClient.sharedClient().signInWithUsername(username, password: password) { (error) -> Void in
            if error != nil {
                completion(error: error)
            } else {
                var redditUser = RKClient.sharedClient().currentUser
                DataManager.manager.datastore.addUser(redditUser, completion: { (user, error) -> () in
                    self.currentUser = user
                    
                    NSUserDefaults.standardUserDefaults().setObject(password, forKey: "password")
                    NSUserDefaults.standardUserDefaults().setObject(username, forKey: "username")
                    
                    completion(error: error)
                })
            }
        }
    }
    
    func overview(pagination: RKPagination?, completion: PaginationCompletion) {
        var user = RKClient.sharedClient().currentUser
        RKClient.sharedClient().contentForUser(user, category: .Overview, pagination: pagination) { (results, pagination, error) -> Void in
            completion(pagination: pagination, results: results, error: error)
        }
    }
    
    func comments(pagination: RKPagination?, completion: PaginationCompletion) {
        var user = RKClient.sharedClient().currentUser
        RKClient.sharedClient().contentForUser(user, category: .Comments, pagination: pagination) { (results, pagination, error) -> Void in
            completion(pagination: pagination, results: results, error: error)
        }
    }
    
    func liked(pagination: RKPagination?, completion: PaginationCompletion) {
        var user = RKClient.sharedClient().currentUser
        RKClient.sharedClient().contentForUser(user, category: .Liked, pagination: pagination) { (results, pagination, error) -> Void in
            completion(pagination: pagination, results: results, error: error)
        }
    }
    
    func disliked(pagination: RKPagination?, completion: PaginationCompletion) {
        var user = RKClient.sharedClient().currentUser
        RKClient.sharedClient().contentForUser(user, category: .Disliked, pagination: pagination) { (results, pagination, error) -> Void in
            completion(pagination: pagination, results: results, error: error)
        }
    }
    
    func submitted(pagination: RKPagination?, completion: PaginationCompletion) {
        var user = RKClient.sharedClient().currentUser
        RKClient.sharedClient().contentForUser(user, category: .Submissions, pagination: pagination) { (results, pagination, error) -> Void in
            completion(pagination: pagination, results: results, error: error)
        }
    }
    
    func saved(pagination: RKPagination?, completion: PaginationCompletion) {
        var user = RKClient.sharedClient().currentUser
        RKClient.sharedClient().contentForUser(user, category: .Saved, pagination: pagination) { (results, pagination, error) -> Void in
            completion(pagination: pagination, results: results, error: error)
        }
    }
    
    func hidden(pagination: RKPagination?, completion: PaginationCompletion) {
        var user = RKClient.sharedClient().currentUser
        RKClient.sharedClient().contentForUser(user, category: .Hidden, pagination: pagination) { (results, pagination, error) -> Void in
            completion(pagination: pagination, results: results, error: error)
        }
    }
}