//
//  UserSession.swift
//  MyReddit
//
//  Created by Nickolas Lanasa on 3/25/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation

let _sharedUserSession = UserSession()

let MyRedditAppearanceDidChangeNotification = "MyRedditAppearanceDidChangeNotification"

class UserSession {
    
    typealias PaginationCompletion = (pagination: RKPagination?, results: [AnyObject]?, error: NSError?) -> ()
    typealias ErrorCompletion = (error: NSError?) -> ()
    
    init() {
        self.users = self.getUsers()
    }
    
    class var sharedSession : UserSession {
        return _sharedUserSession
    }
    
    var isSignedIn: Bool {
        get {
            return RKClient.sharedClient().isSignedIn()
        }
    }
    
    var currentUser: RKUser? {
        didSet {
            if let user = self.currentUser {
                self.addUser(user)
            }
        }
    }

    var users: [RKUser]? {
        didSet {
            if let users = self.users {
                let data = NSKeyedArchiver.archivedDataWithRootObject(users)
                NSUserDefaults.standardUserDefaults().setObject(data, forKey: "users")
            } else {
                NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "users")
            }
        }
    }
    
    func deleteUser(user: RKUser) {
        if let index = self.users?.indexOf(user) {
            self.users?.removeAtIndex(index)
        }
    }
    
    func addUser(user: RKUser) {
        if self.users == nil {
            self.users = [user]
        } else {
            if self.users?.indexOf(user) == nil {
                self.users?.append(user)
            }
        }
    }
    
    func getUsers() -> [RKUser]? {
        if let usersData = NSUserDefaults.standardUserDefaults().objectForKey("users") as? NSData {
            if let users = NSKeyedUnarchiver.unarchiveObjectWithData(usersData) as? [RKUser] {
                return users
            }
        }
        
        return nil
    }
    
    func logout() {
        self.currentUser = nil
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "password")
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "username")
        RKClient.sharedClient().signOut()
        
        LocalyticsSession.shared().tagEvent("Logged out")
    }
    
    func loginWithUsername(username: String, password: String, completion: ErrorCompletion) {
        LocalyticsSession.shared().tagEvent("Logged in")
                
        let c: ErrorCompletion = {
            error in
            self.currentUser = RKClient.sharedClient().currentUser
            
            // TODO: Put in keychain
            NSUserDefaults.standardUserDefaults().setObject(password, forKey: "password")
            NSUserDefaults.standardUserDefaults().setObject(username, forKey: "username")
            
            completion(error: error)
        }
        
        RKClient.sharedClient().signInWithUsername(username, password: password, completion: c)
    }
    
    func openSessionWithCompletion(completion: ErrorCompletion) {
        if !UserSession.sharedSession.isSignedIn {
            if let username = NSUserDefaults.standardUserDefaults().objectForKey("username") as? String,
                let password = NSUserDefaults.standardUserDefaults().objectForKey("password") as? String {
                    let c: ErrorCompletion = {
                        error in
                        completion(error: error)
                    }
                    self.loginWithUsername(username, password: password, completion: c)
            } else {
                completion(error: nil)
            }
        } else {
            completion(error: nil)
        }
    }
    
    func userContent(user: RKUser,
                     category: RKUserContentCategory,
                     pagination: RKPagination?,
                     completion: PaginationCompletion) {
        RKClient.sharedClient().contentForUser(user,
            category: category,
            pagination: pagination) { (results, pagination, error) -> Void in
            completion(pagination: pagination, results: results, error: error)
        }
    }
    
    let nightModeBackgroundColor = UIColor(red: 12/255,
        green: 16/255,
        blue: 33/255,
        alpha: 1.0)
    let nightModeTableViewBackgroundColor = UIColor(red: 15/255,
        green: 20/255,
        blue: 42/255,
        alpha: 1.0)
    let nightModeForegroundColor = UIColor(red: 248/255,
        green: 248/255,
        blue: 248/255,
        alpha: 1.0)
    
    func nightMode() {
        
        let backgroundColor = self.nightModeBackgroundColor
        let foregroundColor = self.nightModeForegroundColor
        
        LocalyticsSession.shared().tagEvent("Night mode toggled")
        
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
        
        MyRedditLabelColor = foregroundColor
        MyRedditSelfTextLabelColor = foregroundColor.colorWithAlphaComponent(0.8)
        MyRedditPostTitleTextLabelColor = UIColor.whiteColor()
        MyRedditBackgroundColor = backgroundColor
        MyRedditDarkBackgroundColor = self.nightModeTableViewBackgroundColor
        MyRedditCommentLinesColor = UIColor.darkGrayColor().colorWithAlphaComponent(0.2)
        MyRedditTableSeparatorColor = UIColor.whiteColor().colorWithAlphaComponent(0.2)
        
        UITextField.appearance().keyboardAppearance = .Dark
        
        self.updateAppearance()
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
        MyRedditTableSeparatorColor = UIColor.lightGrayColor()

        UITextField.appearance().keyboardAppearance = .Light
        
        self.updateAppearance()
    }
    
    func updateAppearance() {
        UIToolbar.appearance().barTintColor = MyRedditBackgroundColor
        UIToolbar.appearance().tintColor = MyRedditLabelColor
        UIToolbar.appearance().backgroundColor = MyRedditBackgroundColor
        UIToolbar.appearance().translucent = false
        
        UITabBar.appearance().translucent = false

        UIWebView.appearance().backgroundColor = MyRedditBackgroundColor
        
        UITableViewCell.appearance().backgroundColor = MyRedditBackgroundColor
        
        UITextField.appearance().font = MyRedditSelfTextFont
        UITextField.appearance().tintColor = MyRedditLabelColor
        
        UIImageView.appearance().backgroundColor = UIColor.clearColor()
        UIActivityIndicatorView.appearance().tintColor = MyRedditColor
        UIRefreshControl.appearance().tintColor = MyRedditColor
        
        UITableView.appearance().backgroundColor = MyRedditDarkBackgroundColor
        UITableView.appearance().separatorColor = MyRedditTableSeparatorColor
        UITableView.appearance().backgroundView = nil
        UITableView.appearance().sectionIndexBackgroundColor = UIColor.clearColor()
        
        UIBarButtonItem.appearance().setTitleTextAttributes([
            NSFontAttributeName: MyRedditTitleFont, NSForegroundColorAttributeName : MyRedditLabelColor],
            forState: UIControlState.Normal)
        UIBarButtonItem.appearance().tintColor = MyRedditLabelColor
        
        UINavigationBar.appearance().translucent = false
        UINavigationBar.appearance().tintColor = MyRedditLabelColor
        UINavigationBar.appearance().backgroundColor = MyRedditBackgroundColor
        UINavigationBar.appearance().barTintColor = MyRedditBackgroundColor
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: MyRedditTitleFont,
            NSForegroundColorAttributeName : MyRedditLabelColor]
        
        UISearchBar.appearance().backgroundColor = MyRedditBackgroundColor
        
        UISwitch.appearance().onTintColor = MyRedditColor

        UISegmentedControl.appearance().tintColor = MyRedditLabelColor
    }
}
