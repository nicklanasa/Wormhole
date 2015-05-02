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
    
    func userContent(category: RKUserContentCategory, pagination: RKPagination?, completion: PaginationCompletion) {
        var user = RKClient.sharedClient().currentUser
        RKClient.sharedClient().contentForUser(user, category: category, pagination: pagination) { (results, pagination, error) -> Void in
            completion(pagination: pagination, results: results, error: error)
        }
    }
    
    func nightMode() {
        
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
        
        MyRedditLabelColor = UIColor.whiteColor()
        
        UISwitch.appearance().onTintColor = MyRedditColor
        UITabBar.appearance().translucent = false
        
        UINavigationBar.appearance().tintColor = MyRedditLabelColor
        UINavigationBar.appearance().backgroundColor = UIColor.blackColor()
        UINavigationBar.appearance().barTintColor = UIColor.blackColor()
        
        UISearchBar.appearance().backgroundColor = UIColor.blackColor()
        
        UIToolbar.appearance().barTintColor = UIColor.blackColor()
        UIToolbar.appearance().tintColor = UIColor.whiteColor()
        UIToolbar.appearance().backgroundColor = UIColor.blackColor()
        
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffset(horizontal: -9999, vertical: 0), forBarMetrics: .Default)
        UITabBarItem.appearance().setTitleTextAttributes([NSFontAttributeName: MyRedditFont], forState: UIControlState.Normal)
        UIBarButtonItem.appearance().setTitleTextAttributes([
            NSFontAttributeName: MyRedditTitleFont, NSForegroundColorAttributeName : MyRedditLabelColor],
            forState: UIControlState.Normal)
        UIBarButtonItem.appearance().tintColor = MyRedditLabelColor
        //UIView.appearance().backgroundColor = UIColor.blackColor()
        
        UITableView.appearance().backgroundColor = UIColor.darkGrayColor()
        UITableViewCell.appearance().backgroundColor = UIColor.blackColor()
    }
    
    func dayMode() {
        
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
        
        MyRedditLabelColor = UIColor.blackColor()
        
        UITabBarItem.appearance().setTitleTextAttributes([NSFontAttributeName: MyRedditFont], forState: UIControlState.Normal)
        UIBarButtonItem.appearance().setTitleTextAttributes([
            NSFontAttributeName: MyRedditTitleFont, NSForegroundColorAttributeName : MyRedditLabelColor],
            forState: UIControlState.Normal)
        
        UISwitch.appearance().onTintColor = MyRedditColor
        
        UINavigationBar.appearance().barTintColor = UIColor.whiteColor()
        UINavigationBar.appearance().tintColor = MyRedditLabelColor
        UINavigationBar.appearance().backgroundColor = UIColor.whiteColor()
        
        UISearchBar.appearance().backgroundColor = UIColor.whiteColor()
        
        UIToolbar.appearance().barTintColor = UIColor.whiteColor()
        UIToolbar.appearance().tintColor = MyRedditLabelColor
        UIToolbar.appearance().backgroundColor = UIColor.whiteColor()
        UITabBar.appearance().translucent = false
        
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffset(horizontal: -9999, vertical: 0), forBarMetrics: .Default)
        UIBarButtonItem.appearance().tintColor = MyRedditLabelColor
        //UIView.appearance().backgroundColor = UIColor.whiteColor()
        UITableView.appearance().backgroundColor = UIColor.groupTableViewBackgroundColor()
        UITableViewCell.appearance().backgroundColor = UIColor.whiteColor()
    }
}