//
//  EditMultiRedditTableViewController.swift
//  MyReddit
//
//  Created by Nickolas Lanasa on 7/31/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import UIKit

class EditMultiRedditTableViewController: RootTableViewController, EditMultiredditNameCellDelegate {
    
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    
    var multireddit: RKMultireddit! {
        didSet {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "edit",
            style: .Plain,
            target: self,
            action: "edit")
        self.deleteButton.setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.redColor(), NSFontAttributeName : MyRedditTitleFont], forState: .Normal)
    }
    
    @IBAction func deleteButtonPressed(sender: AnyObject) {
        
        let alert = UIAlertController(title: "Delete", message: "Are you sure you want to delete this multireddit?", preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action) -> Void in
            RedditSession.sharedSession.deleteMultiReddit(self.multireddit, completion: { (error) -> () in
                if error != nil {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.presentViewController(UIAlertController.errorAlertControllerWithMessage(error!.localizedDescription), animated: true, completion: nil)
                    })
                } else {
                    self.navigationController?.popViewControllerAnimated(true)
                }
            })
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func edit() {
        self.tableView.setEditing(true, animated: true)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "done",
            style: .Plain,
            target: self,
            action: "done")
    }
    
    func done() {
        self.tableView.setEditing(false, animated: true)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "edit",
            style: .Plain,
            target: self,
            action: "edit")
    }
    
    func reload() {
        if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as? EditMultiredditNameCell {
            RedditSession.sharedSession.multiredditWithName(cell.nameTextField.text!, completion: { (pagination, results, error) -> () in
                if error != nil {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.presentViewController(UIAlertController.errorAlertControllerWithMessage(error!.localizedDescription), animated: true, completion: nil)
                    })
                } else {
                    if let multireddit = results?.first as? RKMultireddit {
                        self.multireddit = multireddit
                    }
                }
            })
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        
        return self.multireddit.subreddits.count + 1
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 1 && indexPath.row != 0 {
            return 55
        }
        
        return 44
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier("AddSubredditCell")
                return cell!
            }
            let cell = tableView.dequeueReusableCellWithIdentifier("SubredditCell") as! SubredditCell
            let subreddit = self.multireddit.subreddits?[indexPath.row - 1] as! String
            cell.nameLabel.text = subreddit
            return cell
        } else {
            let editMultiredditNameCell = tableView.dequeueReusableCellWithIdentifier("EditMultiredditNameCell") as! EditMultiredditNameCell
            editMultiredditNameCell.nameTextField.text = self.multireddit.name
            editMultiredditNameCell.delegate = self
            return editMultiredditNameCell
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)

        if indexPath.section == 1 && indexPath.row == 0 {
            self.showAddNewSubredditToMultiredditDialog()
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "multireddit name"
        }
        
        return "subreddits"
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.section == 0 || (indexPath.section == 1 && indexPath.row == 0) {
            return false
        }
        
        return true
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        if indexPath.section == 0 || (indexPath.section == 1 && indexPath.row == 0) {
            return .None
        }
        
        return .Delete
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        if indexPath.section == 0 || (indexPath.section == 1 && indexPath.row == 0) {
            return nil
        }
        
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "delete", handler: { (action, indexPath) -> Void in
            let subredditName = self.multireddit.subreddits?[indexPath.row - 1] as! String
            RedditSession.sharedSession.searchForSubredditByName(subredditName, pagination: nil) { (pagination, results, error) -> () in
                if let subreddits = results as? [RKSubreddit] {
                    
                    var foundSubreddit: RKSubreddit?
                    
                    for subreddit in subreddits {
                        if subreddit.name.lowercaseString == subredditName.lowercaseString {
                            foundSubreddit = subreddit
                            break
                        }
                    }
                    
                    if foundSubreddit == nil {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.presentViewController(UIAlertController.errorAlertControllerWithMessage("Unable to find subreddit."), animated: true, completion: nil)
                        })
                    } else {
                        // Remove from Multireddit
                        RedditSession.sharedSession.removeSubredditFromMultireddit(self.multireddit, subreddit: foundSubreddit!, completion: { (error) -> () in
                            self.reload()
                        })
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.presentViewController(UIAlertController.errorAlertControllerWithMessage("Unable to find subreddit"), animated: true, completion: nil)
                    })
                }
            }
        })
        
        return [deleteAction]
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

    }
    
    func showAddNewSubredditToMultiredditDialog() {
        let alert = UIAlertController(title: "Find Subreddit",
            message: "Please enter the subreddit name.",
            preferredStyle: .Alert)
        
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in })
        
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action) -> Void in
            if let textfield = alert.textFields?.first {
                
                let subredditName = textfield.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                
                if subredditName.characters.count == 0 {
                    self.presentViewController(UIAlertController.errorAlertControllerWithMessage("You must enter in a subreddit name."), animated: true, completion: nil)
                } else {
                    RedditSession.sharedSession.searchForSubredditByName(subredditName, pagination: nil) { (pagination, results, error) -> () in
                        if let subreddits = results as? [RKSubreddit] {
                            
                            var foundSubreddit: RKSubreddit?
                            
                            for subreddit in subreddits {
                                if subreddit.name.lowercaseString == subredditName.lowercaseString {
                                    foundSubreddit = subreddit
                                    break
                                }
                            }
                            
                            if foundSubreddit == nil {
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    self.presentViewController(UIAlertController.errorAlertControllerWithMessage("Unable to find subreddit"), animated: true, completion: nil)
                                })
                            } else {
                                // Add to Multireddit
                                RedditSession.sharedSession.addSubredditToMultiReddit(self.multireddit, subreddit: foundSubreddit!, completion: { (error) -> () in
                                    self.reload()
                                })
                            }
                        } else {
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.presentViewController(UIAlertController.errorAlertControllerWithMessage("Unable to find subreddit."), animated: true, completion: nil)
                            })
                        }
                    }
                }
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func editMultiredditCell(cell: EditMultiredditNameCell, didTapReturnButton sender: AnyObject) {
        // Update Multireddit name
        if cell.nameTextField.text?.characters.count == 0 || cell.nameTextField.text?.characters.count <= 3 || cell.nameTextField.text?.componentsSeparatedByString(" ").count > 1 {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.presentViewController(UIAlertController.errorAlertControllerWithMessage("You must enter in a valid multireddit name! Make sure it doesn't have any spaces in it and that it's greater than 3 characters."), animated: true, completion: nil)
            })
        } else {
            let name = cell.nameTextField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: " "))
            RedditSession.sharedSession.renameMultiredditWithName(name, multiReddit: self.multireddit, completion: { (error) -> () in
                if error != nil {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.presentViewController(UIAlertController.errorAlertControllerWithMessage(error!.localizedDescription), animated: true, completion: nil)
                    })
                } else {
                    self.reload()
                }
            })
        }
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as? EditMultiredditNameCell {
            cell.nameTextField.resignFirstResponder()
        }
    }
}