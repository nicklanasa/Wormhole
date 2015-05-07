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
        self.currentUser = nil
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "password")
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "username")
        RKClient.sharedClient().signOut()
    }
    
    func loginWithUsername(username: String, password: String, completion: ErrorCompletion) {
        
        self.logout()
        
        RKClient.sharedClient().signInWithUsername(username, password: password) { (error) -> Void in
            if error != nil {
                completion(error: error)
            } else {
                var redditUser = RKClient.sharedClient().currentUser
                DataManager.manager.datastore.addUser(redditUser, password: password, completion: { (user, error) -> () in
                    self.currentUser = user
                    
                    NSUserDefaults.standardUserDefaults().setObject(password, forKey: "password")
                    NSUserDefaults.standardUserDefaults().setObject(username, forKey: "username")
                    
                    completion(error: error)
                })
            }
        }
    }
    
    func userContent(user: RKUser, category: RKUserContentCategory, pagination: RKPagination?, completion: PaginationCompletion) {
        RKClient.sharedClient().contentForUser(user,
            category: category,
            pagination: pagination) { (results, pagination, error) -> Void in
            completion(pagination: pagination, results: results, error: error)
        }
    }
    
    func nightMode() {
        
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
        
        MyRedditLabelColor = UIColor.whiteColor()
        MyRedditBackgroundColor = UIColor.blackColor()
        MyRedditDarkBackgroundColor = UIColor.blackColor()
        
        UISwitch.appearance().onTintColor = MyRedditColor
        
        UINavigationBar.appearance().tintColor = MyRedditLabelColor
        UINavigationBar.appearance().backgroundColor = MyRedditBackgroundColor
        UINavigationBar.appearance().barTintColor = MyRedditBackgroundColor
        
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: MyRedditTitleFont]
        
        UISearchBar.appearance().backgroundColor = MyRedditBackgroundColor
        
        UIToolbar.appearance().barTintColor = MyRedditBackgroundColor
        UIToolbar.appearance().tintColor = MyRedditLabelColor
        UIToolbar.appearance().backgroundColor = MyRedditBackgroundColor
        UIToolbar.appearance().translucent = false
        
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffset(horizontal: -9999, vertical: 0), forBarMetrics: .Default)
        UIBarButtonItem.appearance().setTitleTextAttributes([
            NSFontAttributeName: MyRedditTitleFont, NSForegroundColorAttributeName : MyRedditLabelColor],
            forState: UIControlState.Normal)
        UIBarButtonItem.appearance().tintColor = MyRedditLabelColor
        
        UITableView.appearance().backgroundColor = MyRedditDarkBackgroundColor
        UITableView.appearance().separatorColor = UIColor.darkGrayColor()
        UITableView.appearance().backgroundView = nil
        UITableView.appearance().sectionIndexBackgroundColor = UIColor.clearColor()
        
        UITableViewCell.appearance().backgroundColor = MyRedditBackgroundColor
        
        UIImageView.appearance().backgroundColor = UIColor.clearColor()
        
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : MyRedditLabelColor]
        
        UIWebView.appearance().backgroundColor = MyRedditBackgroundColor
        
        UITextField.appearance().font = MyRedditSelfTextFont
        
        UIRefreshControl.appearance().tintColor = MyRedditColor
        
        UISegmentedControl.appearance().setTitleTextAttributes([NSFontAttributeName: MyRedditSelfTextFont, NSForegroundColorAttributeName : MyRedditLabelColor], forState: .Normal)
        }
    
    func dayMode() {
        
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
        
        MyRedditLabelColor = UIColor.blackColor()
        MyRedditBackgroundColor = UIColor.whiteColor()
        MyRedditDarkBackgroundColor = UIColor.groupTableViewBackgroundColor()
        
        UIBarButtonItem.appearance().setTitleTextAttributes([
            NSFontAttributeName: MyRedditTitleFont, NSForegroundColorAttributeName : MyRedditLabelColor],
            forState: UIControlState.Normal)
        
        UISwitch.appearance().onTintColor = MyRedditColor
        
        UINavigationBar.appearance().tintColor = MyRedditLabelColor
        UINavigationBar.appearance().backgroundColor = MyRedditBackgroundColor
        UINavigationBar.appearance().barTintColor = MyRedditBackgroundColor
        
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: MyRedditTitleFont]
        
        UISearchBar.appearance().backgroundColor = MyRedditBackgroundColor
        
        UIToolbar.appearance().barTintColor = MyRedditBackgroundColor
        UIToolbar.appearance().tintColor = MyRedditLabelColor
        UIToolbar.appearance().backgroundColor = MyRedditBackgroundColor
        UITabBar.appearance().translucent = false
        
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffset(horizontal: -9999, vertical: 0), forBarMetrics: .Default)
        UIBarButtonItem.appearance().tintColor = MyRedditLabelColor
        
        UITableView.appearance().backgroundColor = MyRedditDarkBackgroundColor
        UITableView.appearance().separatorColor = UIColor.lightGrayColor()
        UITableView.appearance().backgroundView = nil
        UITableView.appearance().sectionIndexBackgroundColor = UIColor.clearColor()
        
        UIImageView.appearance().backgroundColor = UIColor.clearColor()
        
        UITableViewCell.appearance().backgroundColor = MyRedditBackgroundColor
        
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : MyRedditLabelColor]
        
        UIWebView.appearance().backgroundColor = MyRedditBackgroundColor
        
        UITextField.appearance().font = MyRedditSelfTextFont
        
        UIRefreshControl.appearance().tintColor = MyRedditColor
        UISegmentedControl.appearance().setTitleTextAttributes([NSFontAttributeName: MyRedditSelfTextFont, NSForegroundColorAttributeName : MyRedditLabelColor], forState: .Normal)
        }
}