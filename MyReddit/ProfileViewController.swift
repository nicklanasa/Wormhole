//
//  ProfileViewController.swift
//  MyReddit
//
//  Created by Nickolas Lanasa on 4/30/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation
import UIKit

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var userTitles = ["Overview", "Comments", "Submitted", "Liked", "Disliked", "Hidden", "Saved"]
    var karmaTitles = ["Link Karma", "Comment Karma"]
    var profileTitles = ["Username", "Created"]
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func logoutButtonTapped(sender: AnyObject) {
        UserSession.sharedSession.logout()
        self.cancelButtonTapped(sender)
    }
    
    override func viewDidLoad() {
        if let user = UserSession.sharedSession.currentUser {
            self.navigationItem.title = user.username
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 || section == 1 {
            return 2
        } else {
            return 7
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("UserInfoCell") as! UserInfoCell
        
        if let user = UserSession.sharedSession.currentUser {
            if indexPath.section == 0 {
                var title = self.profileTitles[indexPath.row] as String
                cell.titleLabel.text = title
                
                if indexPath.row == 0 {
                    cell.infoLabel.text = user.username
                } else {
                    cell.infoLabel.text = user.created.timeAgo()
                }
                
                cell.selectionStyle = .None
                
            } else if indexPath.section == 1 {
                var title = self.karmaTitles[indexPath.row] as String
                cell.titleLabel.text = title
                
                if indexPath.row == 0 {
                    cell.infoLabel.text = user.commentKarma.description
                } else {
                    cell.infoLabel.text = user.linkKarma.description
                }
                
                cell.selectionStyle = .None
            } else {
                var title = self.userTitles[indexPath.row] as String
                cell.titleLabel.text = title
                cell.infoLabel.hidden = true
                
                cell.accessoryType = .DisclosureIndicator
            }
        }
        
        return cell
    }
}