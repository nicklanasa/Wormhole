//
//  RootViewController.swift
//  MyReddit
//
//  Created by Nickolas Lanasa on 8/1/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import UIKit
import GoogleMobileAds

class RootViewController: UIViewController, GADBannerViewDelegate {
    
    var bannerView: GADBannerView!
    var showAd = false
    var adSize = kGADAdSizeSmartBannerPortrait
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.updateAppearance()
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "preferredAppearance",
            name: MyRedditAppearanceDidChangeNotification,
            object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.bannerView?.removeFromSuperview()
        self.navigationController?.view.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width,
            UIScreen.mainScreen().bounds.size.height)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, 
            name: MyRedditAppearanceDidChangeNotification,
            object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.showAd {
            self.setupAd()
            self.refreshAd()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateAppearance()
    }
    
    private func updateAppearance() {
        self.navigationController?.navigationBar.tintColor = MyRedditLabelColor
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: MyRedditLabelColor,
            NSFontAttributeName : MyRedditTitleFont]
        self.view.backgroundColor = MyRedditDarkBackgroundColor
        self.navigationController?.view.backgroundColor = MyRedditDarkBackgroundColor
        
        if SettingsManager.defaultManager.valueForSetting(.NightMode) {
            UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
        } else {
            UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: true)
        }
        
        self.bannerView?.backgroundColor = MyRedditBackgroundColor
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        SDImageCache.sharedImageCache().clearMemory()
        SDImageCache.sharedImageCache().cleanDisk()
        SDImageCache.sharedImageCache().clearDisk()
        SDImageCache.sharedImageCache().setValue(nil, forKey: "memCache")
    }
    
    func preferredAppearance() {
        self.updateAppearance()
    }
    
    // MARK: Ads
    
    func refreshAd() {
        let priority = DISPATCH_QUEUE_PRIORITY_BACKGROUND
        
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            let request = GADRequest()
            request.testDevices = [kGADSimulatorID]
            dispatch_async(dispatch_get_main_queue()) {
                self.bannerView.loadRequest(request)
            }
        }
    }
    
    func removeAd() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            UIView.animateWithDuration(0.3) { () -> Void in
                self.bannerView?.removeFromSuperview()
                self.navigationController?.view.frame = CGRectMake(0,
                    0,
                    UIScreen.mainScreen().bounds.size.width,
                    UIScreen.mainScreen().bounds.size.height)
            }
        }
    }
    
    func adView(bannerView: GADBannerView!, didFailToReceiveAdWithError error: GADRequestError!) {
        self.removeAd()
    }
    
    func adViewDidReceiveAd(bannerView: GADBannerView!) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                let bannerHeight = (UIDevice.currentDevice().orientation.isLandscape == true ?
                    32 : 50)
                self.bannerView.frame.origin.y = UIScreen.mainScreen().bounds.size.height - bannerView.frame.size.height
                self.navigationController?.view.frame = CGRectMake(0,
                    0,
                    UIScreen.mainScreen().bounds.size.width,
                    UIScreen.mainScreen().bounds.size.height - CGFloat(bannerHeight))
            })
        }
    }
    
    func setupAd() {
        if !SettingsManager.defaultManager.purchased {
            
            let height: CGFloat = UIDevice.currentDevice().orientation.isLandscape ? 32 : 50
            
            self.adSize = UIDevice.currentDevice().orientation.isLandscape ?
                kGADAdSizeSmartBannerLandscape : kGADAdSizeSmartBannerPortrait
            
            self.bannerView = GADBannerView(frame: CGRectMake(0, UIScreen.mainScreen().bounds.size.height,
                UIScreen.mainScreen().bounds.size.width, height))
            
            self.bannerView.adSize = self.adSize
            self.bannerView.adUnitID = "ca-app-pub-4512025392063519/5619854982"
            self.bannerView.rootViewController = self
            self.bannerView.delegate = self
            self.bannerView.backgroundColor = MyRedditBackgroundColor
            
            if self.bannerView?.superview == nil {
                UIApplication.sharedApplication().keyWindow?.insertSubview(self.bannerView,
                                                                           belowSubview: self.navigationController?.view ?? nil)
            }
        } else {
            self.removeAd()
        }
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        self.removeAd()
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        self.setupAd()
        self.refreshAd()
    }
}
