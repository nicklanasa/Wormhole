//
//  AppDelegate.swift
//  MyReddit
//
//  Created by Nick Lanasa on 3/25/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import UIKit

let MyRedditColor = UIColor(red: 245/255, green: 133/255, blue: 100/255, alpha: 1.0)
let MyRedditUpvoteColor = UIColor(red: 150/255, green: 217/255, blue: 81/255, alpha: 1.0)
let MyRedditDownvoteColor = UIColor(red: 255/255, green: 87/255, blue: 87/255, alpha: 1.0)
let MyRedditFont = UIFont(name: "AvenirNext-Regular", size: 13)!
let MyRedditTitleFont = UIFont(name: "AvenirNext-Medium", size: 18)!
let MyRedditSelfTextFont = UIFont(name: "AvenirNext-Medium", size: 16)!
let MyRedditCommentTextFont = UIFont(name: "AvenirNext-Regular", size: 14)!
let MyRedditCommentTextBoldFont = UIFont(name: "AvenirNext-Medium", size: 14)!
let MyRedditCommentTextItalicFont = UIFont(name: "AvenirNext-Italic", size: 14)!
let MyRedditTitleBigFont = UIFont(name: "AvenirNext-Medium", size: 23)!

var MyRedditLabelColor = UIColor.blackColor()
var MyRedditBackgroundColor = UIColor.whiteColor()
var MyRedditDarkBackgroundColor = UIColor.groupTableViewBackgroundColor()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        if SettingsManager.defaultManager.valueForSetting(.NightMode) {
            UserSession.sharedSession.nightMode()
        } else {
            UserSession.sharedSession.dayMode()
        }
        
        if let username = NSUserDefaults.standardUserDefaults().objectForKey("username") as? String {
            if let password = NSUserDefaults.standardUserDefaults().objectForKey("password") as? String {
                UserSession.sharedSession.loginWithUsername(username, password: password, completion: { (error) -> () in
                })
            }
        }
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

