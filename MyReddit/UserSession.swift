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
        
        LocalyticsSession.shared().tagEvent("Logged out")
    }
    
    func loginWithUsername(username: String, password: String, completion: ErrorCompletion) {
        
        LocalyticsSession.shared().tagEvent("Logged in")
        
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
        
        var backgroundColor = UIColor(red: 12/255,
            green: 16/255,
            blue: 33/255,
            alpha: 1.0)
        var foregroundColor = UIColor(red: 248/255,
            green: 248/255,
            blue: 248/255,
            alpha: 1.0)
        
        LocalyticsSession.shared().tagEvent("Night mode toggled")
        
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
        
        MyRedditLabelColor = foregroundColor
        MyRedditSelfTextLabelColor = foregroundColor.colorWithAlphaComponent(0.8)
        MyRedditPostTitleTextLabelColor = UIColor.whiteColor()
        MyRedditBackgroundColor = backgroundColor
        MyRedditDarkBackgroundColor = backgroundColor
        MyRedditCommentLinesColor = UIColor.darkGrayColor().colorWithAlphaComponent(0.2)
        
        UISwitch.appearance().onTintColor = MyRedditColor
        
        UINavigationBar.appearance().translucent = false
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
        
        var backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.7)
        UITableViewCell.appearance().selectedBackgroundView = backgroundView
        
        UITableViewCell.appearance().backgroundColor = MyRedditBackgroundColor
        
        UIImageView.appearance().backgroundColor = UIColor.clearColor()
        
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: MyRedditTitleFont,
            NSForegroundColorAttributeName : MyRedditLabelColor]
        
        UIWebView.appearance().backgroundColor = MyRedditBackgroundColor
        
        UITextField.appearance().font = MyRedditSelfTextFont
        
        UIRefreshControl.appearance().tintColor = MyRedditColor
        
        UIActivityIndicatorView.appearance().tintColor = MyRedditColor
        
        UISegmentedControl.appearance().setTitleTextAttributes([NSFontAttributeName: MyRedditSelfTextFont, NSForegroundColorAttributeName : MyRedditLabelColor], forState: .Normal)
    }
    
    func dayMode() {
        
        LocalyticsSession.shared().tagEvent("Day mode toggled")
        
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
        
        MyRedditLabelColor = UIColor.blackColor()
        MyRedditSelfTextLabelColor = UIColor.darkGrayColor()
        MyRedditPostTitleTextLabelColor = UIColor.lightGrayColor()
        MyRedditBackgroundColor = UIColor.whiteColor()
        MyRedditDarkBackgroundColor = UIColor.groupTableViewBackgroundColor()
        MyRedditCommentLinesColor = UIColor.groupTableViewBackgroundColor().colorWithAlphaComponent(0.4)
        
        UIBarButtonItem.appearance().setTitleTextAttributes([
            NSFontAttributeName: MyRedditTitleFont, NSForegroundColorAttributeName : MyRedditLabelColor],
            forState: UIControlState.Normal)
        
        UISwitch.appearance().onTintColor = MyRedditColor
        
        UINavigationBar.appearance().translucent = false
        UINavigationBar.appearance().tintColor = MyRedditLabelColor
        UINavigationBar.appearance().backgroundColor = MyRedditBackgroundColor
        UINavigationBar.appearance().barTintColor = MyRedditBackgroundColor
        
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: MyRedditTitleFont,
            NSForegroundColorAttributeName : MyRedditLabelColor]
        
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
        
        var backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.7)
        UITableViewCell.appearance().selectedBackgroundView = backgroundView
        
        UIImageView.appearance().backgroundColor = UIColor.clearColor()
        
        UITableViewCell.appearance().backgroundColor = MyRedditBackgroundColor
        
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : MyRedditLabelColor]
        
        UIWebView.appearance().backgroundColor = MyRedditBackgroundColor
        
        UITextField.appearance().font = MyRedditSelfTextFont
        
        UIActivityIndicatorView.appearance().tintColor = MyRedditColor
        
        UIRefreshControl.appearance().tintColor = MyRedditColor
        UISegmentedControl.appearance().setTitleTextAttributes([NSFontAttributeName: MyRedditSelfTextFont, NSForegroundColorAttributeName : MyRedditLabelColor], forState: .Normal)
    }
}