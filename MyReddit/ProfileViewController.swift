//
//  ProfileViewController.swift
//  MyReddit
//
//  Created by Nickolas Lanasa on 4/30/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation
import UIKit

class ProfileViewController: RootViewController,
UITableViewDataSource,
UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var listButton: UIBarButtonItem!
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    
    var userTitles = ["Overview", "Comments", "Submitted", "Gilded", "Liked", "Disliked", "Hidden", "Saved"]
    var karmaTitles = ["Link Karma", "Comment Karma"]
    var profileTitles = ["Username", "Created"]
    
    var user: RKUser?
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func logoutButtonTapped(sender: AnyObject) {
        UserSession.sharedSession.logout()
        
        if let _ = self.splitViewController {
            NSNotificationCenter.defaultCenter().postNotificationName("RefreshSubreddits", object: nil)
        }
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.cancelButtonTapped(sender)
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        LocalyticsSession.shared().tagScreen("Profile")
        
        if let _ = self.user {
            self.userTitles =  ["Overview", "Comments", "Submitted", "Gilded"]
            self.logoutButton.title = ""
            self.logoutButton.action = nil
        } else {
            if let user = UserSession.sharedSession.currentUser {
                self.navigationItem.title = user.username
            }
        }
        
        if let _ = self.splitViewController {
            self.listButton.action = self.splitViewController!.displayModeButtonItem().action
        } else {
            self.navigationController?.setToolbarHidden(true, animated: true)
        }
    }
    
    override func viewDidLoad() {
        self.preferredAppearance()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 || section == 1 {
            return 2
        } else {
            return self.userTitles.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("UserInfoCell") as! UserInfoCell
        
        cell.titleLabel.textColor = MyRedditLabelColor
        cell.infoLabel.textColor = MyRedditLabelColor
        cell.backgroundColor = MyRedditBackgroundColor
        
        if let searchedUser = self.user {
            if indexPath.section == 0 {
                let title = self.profileTitles[indexPath.row] as String
                cell.titleLabel.text = title
                
                if indexPath.row == 0 {
                    cell.infoLabel.text = searchedUser.username
                } else {
                    cell.infoLabel.text = searchedUser.created.timeAgoSinceNow()
                }
                
                cell.selectionStyle = .None
                
            } else if indexPath.section == 1 {
                let title = self.karmaTitles[indexPath.row] as String
                cell.titleLabel.text = title
                
                if indexPath.row == 0 {
                    cell.infoLabel.text = searchedUser.linkKarma.description
                } else {
                    cell.infoLabel.text = searchedUser.commentKarma.description
                }
                
                cell.selectionStyle = .None
            } else {
                let title = self.userTitles[indexPath.row] as String
                cell.titleLabel.text = title
                cell.infoLabel.hidden = true
                
                cell.accessoryType = .DisclosureIndicator
            }
        } else {
            if let user = UserSession.sharedSession.currentUser {
                if indexPath.section == 0 {
                    let title = self.profileTitles[indexPath.row] as String
                    cell.titleLabel.text = title
                    
                    if indexPath.row == 0 {
                        cell.infoLabel.text = user.username
                    } else {
                        cell.infoLabel.text = user.created?.timeAgoSinceNow()
                    }
                    
                    cell.selectionStyle = .None
                    
                } else if indexPath.section == 1 {
                    let title = self.karmaTitles[indexPath.row] as String
                    cell.titleLabel.text = title
                    
                    if indexPath.row == 0 {
                        cell.infoLabel.text = user.commentKarma.description
                    } else {
                        cell.infoLabel.text = user.linkKarma.description
                    }
                    
                    cell.selectionStyle = .None
                } else {
                    let title = self.userTitles[indexPath.row] as String
                    cell.titleLabel.text = title
                    cell.infoLabel.hidden = true
                    
                    cell.accessoryType = .DisclosureIndicator
                }
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.section == 2 {
            self.performSegueWithIdentifier("UserContentSegue",
                sender: tableView.cellForRowAtIndexPath(indexPath))
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "UserContentSegue" {
            
            var contentController: UserContentViewController!
            
            if let nav = segue.destinationViewController as? UINavigationController {
                if let controller = nav.viewControllers[0] as? UserContentViewController {
                    contentController = controller
                }
            } else if let controller = segue.destinationViewController as? UserContentViewController {
                contentController = controller
            }
            
            if let cell = sender as? UITableViewCell {
                
                let indexPath: NSIndexPath = self.tableView.indexPathForCell(cell)!
                let category = RKUserContentCategory(rawValue: UInt(indexPath.row+1))
                contentController.category = category
                contentController.categoryTitle = self.userTitles[indexPath.row] as String
                
                if let searchedUser = self.user {
                    contentController.user = searchedUser
                } else {
                    contentController.user = RKClient.sharedClient().currentUser
                }
                
                LocalyticsSession.shared().tagEvent("UserContent segue")
            }
        }
    }
    
    override func preferredAppearance() {
        
        self.tableView.backgroundColor = MyRedditDarkBackgroundColor
        
        self.navigationController?.navigationBar.backgroundColor = MyRedditBackgroundColor
        self.navigationController?.navigationBar.barTintColor = MyRedditBackgroundColor
        self.navigationController?.navigationBar.tintColor = MyRedditLabelColor
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : MyRedditLabelColor]
        
        self.toolbar.barTintColor = MyRedditBackgroundColor
        self.toolbar.backgroundColor = MyRedditBackgroundColor
        self.toolbar.tintColor = MyRedditLabelColor
        self.toolbar.translucent = false
        
        if let logoutButton = self.logoutButton {
            logoutButton.tintColor = MyRedditLabelColor
        }
                    
        self.tableView.reloadData()
    }
}
