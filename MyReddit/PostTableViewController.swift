//
//  PostTableViewController.swift
//  MyReddit
//
//  Created by Nick Lanasa on 5/5/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation
import UIKit

enum PostType: Int {
    case Link
    case Text
}

class PostTableViewController: UITableViewController, PostTypeCellDelegate, PostSubredditCellDelegate, LinkCellDelegate, SearchViewControllerDelegate, UIImagePickerControllerDelegate,
UINavigationControllerDelegate {
    
    var selectedImage: UIImage? {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    var subreddit: RKSubreddit? {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    var postType: PostType! = .Link {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    var hud: MBProgressHUD! {
        didSet {
            hud.labelFont = MyRedditSelfTextFont
            hud.mode = .Indeterminate
            hud.labelText = "Loading"
        }
    }
    
    override func viewDidLoad() {
        self.tableView.backgroundColor = MyRedditBackgroundColor
        
        self.tableView.tableFooterView = UIView()
        
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        self.tableView.reloadData()
        
        if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as? PostSubredditCell {
            cell.subredditTextField.becomeFirstResponder()
        }
    }
    
    override func viewDidAppear(animated: Bool) {

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        LocalyticsSession.shared().tagScreen("Post")
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if self.postType == .Text && indexPath.row == 3 {
            var cell = tableView.dequeueReusableCellWithIdentifier("PostTextCell") as! PostTextCell
            cell.separatorInset = UIEdgeInsets(top: 0, left: self.tableView.frame.size.width, bottom: 0, right: 0)
            return cell
        } else {
            if indexPath.row == 3 {
                var cell = tableView.dequeueReusableCellWithIdentifier("LinkCell") as! LinkCell
                cell.delegate = self
                
                if let image = self.selectedImage {
                    cell.addImageButton.setBackgroundImage(image,
                        forState: .Normal)
                    cell.linkTextField.enabled = false
                } else {
                    cell.addImageButton.setBackgroundImage(UIImage(named: "Camera"),
                        forState: .Normal)
                    cell.linkTextField.enabled = true
                }
                
                return cell
            }
        }
        
        if indexPath.row == 0 {
            var cell = tableView.dequeueReusableCellWithIdentifier("PostTypeCell") as! PostTypeCell
            cell.delegate = self
            return cell
        } else if indexPath.row == 1 {
            var cell = tableView.dequeueReusableCellWithIdentifier("PostSubredditCell") as! PostSubredditCell
            if let subreddit = self.subreddit {
                cell.subredditTextField.text = subreddit.name
            }
            cell.delegate = self
            return cell
        } else {
            var cell = tableView.dequeueReusableCellWithIdentifier("PostTitleCell") as! PostTitleCell
            return cell
        }
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func sendButtonTapped(sender: AnyObject) {
        
        if let subredditCell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as? PostSubredditCell {
            if count(subredditCell.subredditTextField.text) > 0 {
                if let postTitleCell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0)) as? PostTitleCell {
                    if count(postTitleCell.titleTextField.text) > 0 {
                        if self.postType == .Text {
                            if let postTextCell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 3, inSection: 0)) as? PostTextCell {
                                if count(postTextCell.textView.text) > 0 {
                                    // Submit
                                    self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                                    RedditSession.sharedSession.submitLink(postTitleCell.titleTextField.text, subredditName: subredditCell.subredditTextField.text, text: postTextCell.textView.text, url: nil, postType: .Text, completion: { (error) -> () in
                                        if error != nil {
                                            self.hud.hide(true)
                                            UIAlertView(title: "Error!",
                                                message: error!.localizedDescription,
                                                delegate: self,
                                                cancelButtonTitle: "Ok").show()
                                            LocalyticsSession.shared().tagEvent("Unable to text")
                                        } else {
                                            LocalyticsSession.shared().tagEvent("Posted text link")
                                            self.cancelButtonTapped(self)
                                        }
                                    })
                                } else {
                                    UIAlertView(title: "Error!",
                                        message: "You must supply text!",
                                        delegate: self,
                                        cancelButtonTitle: "Ok").show()
                                }
                            }
                        } else {
                            if let urlCell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 3, inSection: 0)) as? LinkCell {
                                if count(urlCell.linkTextField.text) > 0 || self.selectedImage != nil {
                                    // Submit
                                    self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                                    if let image = self.selectedImage {
                                        var client = ImgurAnonymousAPIClient(clientID: "e97d1faf5a39e09")
                                        client.uploadImage(image, withFilename: "image.jpg", completionHandler: { (url, error) -> Void in
                                            if error != nil {
                                                self.hud.hide(true)
                                                UIAlertView(title: "Error!",
                                                    message: error.localizedDescription,
                                                    delegate: self,
                                                    cancelButtonTitle: "Ok").show()
                                                
                                                LocalyticsSession.shared().tagEvent("Unable to upload image")
                                            } else {
                                                RedditSession.sharedSession.submitLink(postTitleCell.titleTextField.text, subredditName: subredditCell.subredditTextField.text, text: nil, url: url, postType: .Link, completion: { (error) -> () in
                                                    if error != nil {
                                                        self.hud.hide(true)
                                                        UIAlertView(title: "Error!",
                                                            message: error!.localizedDescription,
                                                            delegate: self,
                                                            cancelButtonTitle: "Ok").show()
                                                        LocalyticsSession.shared().tagEvent("Unable to post link")
                                                    } else {
                                                        LocalyticsSession.shared().tagEvent("Posted link")
                                                        self.cancelButtonTapped(self)
                                                    }
                                                })
                                            }
                                        })
                                    } else {
                                        RedditSession.sharedSession.submitLink(postTitleCell.titleTextField.text, subredditName: subredditCell.subredditTextField.text, text: nil, url: NSURL(string: urlCell.linkTextField.text), postType: .Link, completion: { (error) -> () in
                                            if error != nil {
                                                self.hud.hide(true)
                                                UIAlertView(title: "Error!",
                                                    message: error!.localizedDescription,
                                                    delegate: self,
                                                    cancelButtonTitle: "Ok").show()
                                                LocalyticsSession.shared().tagEvent("Unable to post link")
                                            } else {
                                                LocalyticsSession.shared().tagEvent("Posted link")
                                                self.cancelButtonTapped(self)
                                            }
                                        })
                                    }
                                } else {
                                    UIAlertView(title: "Error!",
                                        message: "You must supply a link or an image!",
                                        delegate: self,
                                        cancelButtonTitle: "Ok").show()
                                }
                            }
                        }
                    } else {
                        UIAlertView(title: "Error!",
                            message: "You must supply a title!",
                            delegate: self,
                            cancelButtonTitle: "Ok").show()
                    }
                }
            } else {
                UIAlertView(title: "Error!",
                    message: "You must supply a subreddit!",
                    delegate: self,
                    cancelButtonTitle: "Ok").show()
            }
        }
    }
    
    func dismiss() {
        
    }
    
    func linkCell(cell: LinkCell, didTapImageButton sender: AnyObject) {
        self.selectImage()
    }
    
    func postSubredditCell(cell: PostSubredditCell, didTapAddButton sender: AnyObject) {
        LocalyticsSession.shared().tagEvent("Post search for subreddit")
        self.performSegueWithIdentifier("SearchSegue", sender: self)
    }
    
    func postTypeCell(cell: PostTypeCell, didChangeValue sender: AnyObject) {
        if let segementationControl = sender as? UISegmentedControl {
            if let postType = PostType(rawValue: segementationControl.selectedSegmentIndex) {
                self.postType = postType
            }
        }
        
        if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as? PostSubredditCell {
            cell.subredditTextField.becomeFirstResponder()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SearchSegue" {
            if let nav = segue.destinationViewController as? UINavigationController {
                if let controller = nav.viewControllers[0] as? SearchViewController {
                    controller.delegate = self
                }
            }
        }
    }
    
    func searchViewController(controller: SearchViewController, didTapSubreddit subreddit: RKSubreddit) {
        LocalyticsSession.shared().tagEvent("Added subreddit to post")
        self.subreddit = subreddit
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        LocalyticsSession.shared().tagEvent("Added image from device to post")
        self.selectedImage = image
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func selectImage() {
        var alertController = UIAlertController(title: "Select source", message: nil, preferredStyle: .ActionSheet)
        
        alertController.addAction(UIAlertAction(title: "Photo Library", style: .Default, handler: { (action) -> Void in
            if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary){
                var picker = UIImagePickerController()
                picker.delegate = self
                picker.sourceType = .PhotoLibrary
                self.presentViewController(picker, animated: true, completion: nil)
                
                LocalyticsSession.shared().tagEvent("Photo library tapped")
            }
            else{
                NSLog("No Camera.")
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "Camera", style: .Default, handler: { (action) -> Void in
            if UIImagePickerController.isSourceTypeAvailable(.Camera){
                var picker = UIImagePickerController()
                picker.delegate = self
                picker.sourceType = .Camera
                self.presentViewController(picker, animated: true, completion: nil)
                
                LocalyticsSession.shared().tagEvent("Camera tapped")
            }
            else{
                NSLog("No Camera.")
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) -> Void in
            LocalyticsSession.shared().tagEvent("Image selected cancelled")
        }))
        
        if let image = self.selectedImage {
            alertController.addAction(UIAlertAction(title: "Remove link", style: .Destructive, handler: { (action) -> Void in
                self.selectedImage = nil
                LocalyticsSession.shared().tagEvent("Removed image from post")
            }))
        }
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}