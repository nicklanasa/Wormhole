//
//  PurchaseViewController.swift
//  MyReddit
//
//  Created by Nick Lanasa on 4/30/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation
import UIKit

class PurchaseViewController: UIViewController, BDGIAPDelegate {
    
    var hud: MBProgressHUD! {
        didSet {
            hud.labelFont = MyRedditSelfTextFont
            hud.mode = .Indeterminate
            hud.labelText = "Loading"
        }
    }

    @IBAction func restoreButtonTapped(sender: AnyObject) {
        self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        BDGInAppPurchase.sharedBDGInAppPurchase().delegate = self
        BDGInAppPurchase.sharedBDGInAppPurchase().productID = "myreddit.premium"
        BDGInAppPurchase.sharedBDGInAppPurchase().restoreIAP()
    }
    
    @IBAction func purchaseButtonTapped(sender: AnyObject) {
        self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        BDGInAppPurchase.sharedBDGInAppPurchase().delegate = self
        BDGInAppPurchase.sharedBDGInAppPurchase().productID = "myreddit.premium"
        BDGInAppPurchase.sharedBDGInAppPurchase().purchaseIAP()
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func didFailIAP() {
        self.hud.hide(true)
        UIAlertView(title: "Error!", message: "Unable to purchase! Please make sure you have an internet connection.", delegate: self, cancelButtonTitle: "Ok").show()
    }
    
    func didEndIAS() {
        self.hud.hide(true)
    }
    
    func didFailIAS() {
        self.hud.hide(true)
        UIAlertView(title: "Error!", message: "Unable to purchase! Please make sure you have an internet connection.", delegate: self, cancelButtonTitle: "Ok").show()
    }
    
    func didCancelIAP() {
        self.hud.hide(true)
    }
    
    func didPurchaseIAP() {
        self.hud.hide(true)
        NSUserDefaults.standardUserDefaults().setObject(true, forKey: "purchased")
        self.cancelButtonTapped(self)
    }
    
    func didRestoreIAP(productID: String!) {
        NSUserDefaults.standardUserDefaults().setObject(true, forKey: "purchased")
        self.cancelButtonTapped(self)
    }
    
    func dismissVC() {
        self.hud.hide(true)
    }
    
    func presentVC(viewController: UIViewController!) {
        self.hud.hide(true)
    }
}