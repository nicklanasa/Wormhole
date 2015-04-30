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
}