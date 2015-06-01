//
//  LoginViewController.swift
//  MyReddit
//
//  Created by Nickolas Lanasa on 3/25/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation
import UIKit

class LoginViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, EmailCellDelegate, PasswordCellDelegate {

    @IBOutlet weak var loginButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    var hud: MBProgressHUD! {
        didSet {
            hud.labelFont = MyRedditSelfTextFont
            hud.mode = .Indeterminate
            hud.labelText = "Loading"
        }
    }
    
    var user: User?

    @IBAction func loginButtonPressed(sender: AnyObject) {
        var emailCell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! EmailCell
        var passwordCell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as! PasswordCell
        
        self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        if count(emailCell.usernameTextField.text) > 0 && count(passwordCell.passwordTextField.text) > 0 {
            UserSession.sharedSession.loginWithUsername(emailCell.usernameTextField.text,
                password: passwordCell.passwordTextField.text) { (error) -> () in
                    if error != nil {
                        self.hud.hide(true)
                        UIAlertView(title: "Error!",
                            message: "Unable to login. Please try again.",
                            delegate: self,
                            cancelButtonTitle: "Ok").show()
                        
                        LocalyticsSession.shared().tagEvent("Login failed")
                    } else {
                        
                        LocalyticsSession.shared().tagEvent("Login success")
                        
                        if let splitViewController = self.splitViewController {
                            NSNotificationCenter.defaultCenter().postNotificationName("RefreshSubreddits", object: nil)
                        }
                        
                        self.hud.hide(true)
                        self.cancelButtonPressed(sender)
                    }
            }
        } else {
            self.hud.hide(true)
            UIAlertView(title: "Error!",
                message: "You must supply a username and password!",
                delegate: self,
                cancelButtonTitle: "Ok").show()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        self.tableView.reloadData()
        var emailCell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! EmailCell
        emailCell.usernameTextField.becomeFirstResponder()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        LocalyticsSession.shared().tagScreen("Login")
        
        self.tableView.backgroundColor = MyRedditDarkBackgroundColor
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        if let splitViewController = self.splitViewController {
            self.navigationController?.popViewControllerAnimated(true)
        } else {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            var cell = tableView.dequeueReusableCellWithIdentifier("EmailCell") as! EmailCell
            cell.delegate = self
            
            if let currentUser = self.user {
                cell.user = currentUser
            }
            
            return cell
        } else {
            var cell = tableView.dequeueReusableCellWithIdentifier("PasswordCell") as! PasswordCell
            cell.delegate = self
            
            if let currentUser = self.user {
                cell.user = currentUser
            }
            
            return cell
        }
    }
    
    func emailCell(cell: EmailCell, didTapReturnButton sender: AnyObject) {
        var passwordCell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as! PasswordCell
        passwordCell.passwordTextField.becomeFirstResponder()
    }
    
    func passwordCell(cell: PasswordCell, didTapReturnButton sender: AnyObject) {
        self.loginButtonPressed(sender)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if let emailCell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as? EmailCell {
            emailCell.usernameTextField.resignFirstResponder()
        }

        if let  passwordCell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as? PasswordCell {
            passwordCell.passwordTextField.resignFirstResponder()
        }
    }
}