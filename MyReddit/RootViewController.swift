//
//  RootViewController.swift
//  MyReddit
//
//  Created by Nickolas Lanasa on 8/1/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.updateAppearance()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateAppearance()
    }
    
    private func updateAppearance() {
        self.navigationController?.navigationBar.tintColor = MyRedditLabelColor
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: MyRedditLabelColor,
            NSFontAttributeName : MyRedditTitleFont]
        
        if SettingsManager.defaultManager.valueForSetting(.NightMode) {
            UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
        } else {
            UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        SDImageCache.sharedImageCache().clearMemory()
        SDImageCache.sharedImageCache().cleanDisk()
        SDImageCache.sharedImageCache().clearDisk()
        SDImageCache.sharedImageCache().setValue(nil, forKey: "memCache")
    }
}
