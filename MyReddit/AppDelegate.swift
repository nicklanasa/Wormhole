//
//  AppDelegate.swift
//  MyReddit
//
//  Created by Nick Lanasa on 3/25/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import UIKit

let MyRedditColor = UIColor(red: 189.0/255.0, green: 102.0/255.0, blue: 68.0/255.0, alpha: 1.0)
let MyRedditUpvoteColor = UIColor(red: 155.0/255.0, green: 189.0/255.0, blue: 68.0/255.0, alpha: 1.0)
let MyRedditDownvoteColor = UIColor(red: 189.0/255.0, green: 68.0/255.0, blue: 94.0/255.0, alpha: 1.0)
let MyRedditReplyColor = UIColor(red: 68.0/255.0, green: 155.0/255.0, blue: 189.0/255.0, alpha: 1.0)
let MyRedditFont = UIFont(name: "AvenirNext-Regular", size: 13)!
let MyRedditCommentInfoFont = UIFont(name: "AvenirNext-Regular", size: 11)!
let MyRedditCommentInfoMediumFont = UIFont(name: "AvenirNext-Medium", size: 11)!
let MyRedditTitleFont = UIFont(name: "AvenirNext-Medium", size: 18)!
let MyRedditSelfTextFont = UIFont(name: "AvenirNext-Medium", size: 16)!
let MyRedditCommentTextFont = UIFont(name: "AvenirNext-Medium", size: 14)!
let MyRedditCommentTextBoldFont = UIFont(name: "AvenirNext-Medium", size: 14)!
let MyRedditCommentReplyBoldFont = UIFont(name: "AvenirNext-Medium", size: 11)!
let MyRedditCommentTextItalicFont = UIFont(name: "AvenirNext-Italic", size: 14)!
let MyRedditTitleBigFont = UIFont(name: "AvenirNext-Medium", size: 23)!

var MyRedditLabelColor = UIColor.blackColor()
var MyRedditSelfTextLabelColor = UIColor.darkGrayColor()
var MyRedditPostTitleTextLabelColor = UIColor.lightGrayColor()
var MyRedditBackgroundColor = UIColor.whiteColor()
var MyRedditDarkBackgroundColor = UIColor.groupTableViewBackgroundColor()
var MyRedditCommentLinesColor = UIColor.groupTableViewBackgroundColor().colorWithAlphaComponent(0.4)
var MyRedditTableSeparatorColor = UIColor.groupTableViewBackgroundColor()


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, IMGSessionDelegate, NSURLSessionDelegate {

    var window: UIWindow?
    var session:NSURLSession!
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
                
        IMGSession.anonymousSessionWithClientID("e97d1faf5a39e09", withDelegate: self)
                        
        if SettingsManager.defaultManager.valueForSetting(.NightMode) {
            UserSession.sharedSession.nightMode()
        } else {
            UserSession.sharedSession.dayMode()
        }
        
        LocalyticsSession.shared().integrateLocalytics("fda6cd374a0e9cec3f11237-09533afc-9cc5-11e3-974b-005cf8cbabd8",
            launchOptions: launchOptions)
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            Appirater.setAppId("995067625")
        } else {
            Appirater.setAppId("544533053")
        }
        
        Appirater.setCustomAlertTitle("Rate MyReddit")
        Appirater.setCustomAlertMessage("If you enjoy using MyReddit, would you mind taking a moment to rate it? It won't take more than a minute. Thanks for your support!")
        Appirater.setCustomAlertRateButtonTitle("Rate MyReddit")
        Appirater.setDaysUntilPrompt(2)
        Appirater.setUsesUntilPrompt(5)
        Appirater.appLaunched(true)
        
        SDWebImageDownloader.sharedDownloader().shouldDecompressImages = false
        
        application.setMinimumBackgroundFetchInterval(
            UIApplicationBackgroundFetchIntervalMinimum)
        
        return true
    }
    
    func application(application: UIApplication,
        performFetchWithCompletionHandler completionHandler:
        ((UIBackgroundFetchResult) -> Void)){
        print("running in backgrounddddd!!!!!")
        RedditSession.sharedSession.fetchMessages(nil, category: .Unread, read: false) { (pagination, results, error) -> () in
            if results?.count > 0 {
                let notification = UILocalNotification()
                notification.alertBody = "New messages"
                notification.fireDate = NSDate()
                notification.soundName = UILocalNotificationDefaultSoundName
                UIApplication.sharedApplication().scheduleLocalNotification(notification)
                UIApplication.sharedApplication().applicationIconBadgeNumber = results!.count
            }
            
            completionHandler(.NewData)
        }
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
    
    func applicationDidReceiveMemoryWarning(application: UIApplication) {
        SDImageCache.sharedImageCache().clearMemory()
        SDImageCache.sharedImageCache().cleanDisk()
        SDImageCache.sharedImageCache().clearDisk()
        SDImageCache.sharedImageCache().setValue(nil, forKey: "memCache")
    }
}