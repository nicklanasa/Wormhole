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

class PostTableViewController: RootTableViewController,
PostTypeCellDelegate,
PostSubredditCellDelegate,
LinkCellDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate {
    
    var captchaValue: String?
    var captchaIdentifier: String?
    
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
    
    @IBOutlet weak var listButton: UIBarButtonItem!
    @IBOutlet weak var postButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        
        self.preferredAppearance()
        
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as? PostSubredditCell {
            cell.subredditTextField.becomeFirstResponder()
        }
    }
    
    override func viewDidAppear(animated: Bool) {

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        LocalyticsSession.shared().tagScreen("Post")
        
        if let _ = self.splitViewController {
            self.listButton.action = self.splitViewController!.displayModeButtonItem().action
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if self.postType == .Text && indexPath.row == 3 {
            let cell = tableView.dequeueReusableCellWithIdentifier("PostTextCell") as! PostTextCell
            cell.separatorInset = UIEdgeInsets(top: 0,
                left: self.tableView.frame.size.width,
                bottom: 0,
                right: 0)
            return cell
        } else {
            if indexPath.row == 3 {
                let cell = tableView.dequeueReusableCellWithIdentifier("LinkCell") as! LinkCell
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
            let cell = tableView.dequeueReusableCellWithIdentifier("PostTypeCell") as! PostTypeCell
            cell.delegate = self
            return cell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("PostSubredditCell") as! PostSubredditCell
            if let subreddit = self.subreddit {
                cell.subredditTextField.text = subreddit.name
            }
            cell.delegate = self
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("PostTitleCell") as! PostTitleCell
            return cell
        }
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func postText(title: String, subredditName: String, text: String) {
        self.showCaptchaDialog { (result, error) -> () in
            if result {
                self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                RedditSession.sharedSession.submitLink(title,
                    subredditName: subredditName,
                    text: text,
                    url: nil,
                    postType: .Text,
                    captchaIdentifier: self.captchaIdentifier,
                    captchaValue: self.captchaValue, completion: { (error) -> () in
                        if error != nil {
                            self.hud.hide(true)
                            UIAlertView.showErrorWithError(error)
                            LocalyticsSession.shared().tagEvent("Unable to text")
                        } else {
                            LocalyticsSession.shared().tagEvent("Posted text link")
                            self.cancelButtonTapped(self)
                        }
                })
            } else {
                UIAlertView.showErrorWithError(error)
            }
        }
    }
    
    func postImage(link: String, subredditName: String) {
        self.showCaptchaDialog { (result, error) -> () in
            if result {
                let client = ImgurAnonymousAPIClient(clientID: "e97d1faf5a39e09")
                client.uploadImage(self.selectedImage!, withFilename: "image.jpg", completionHandler: { (url, error) -> Void in
                    if error != nil {
                        self.hud.hide(true)
                        UIAlertView.showErrorWithError(error)
                        LocalyticsSession.shared().tagEvent("Unable to upload image")
                    } else {
                        RedditSession.sharedSession.submitLink(link,
                            subredditName: subredditName,
                            text: nil, url: url,
                            postType: .Link,
                            captchaIdentifier: self.captchaIdentifier,
                            captchaValue: self.captchaValue, completion: { (error) -> () in
                            if error != nil {
                                self.hud.hide(true)
                                UIAlertView.showErrorWithError(error)
                                LocalyticsSession.shared().tagEvent("Unable to post link")
                            } else {
                                LocalyticsSession.shared().tagEvent("Posted link")
                                self.cancelButtonTapped(self)
                            }
                        })
                    }
                })
            } else {
                UIAlertView.showErrorWithError(error)
            }
        }
    }
    
    func postLink(link: String, subredditName: String, url: String) {
        self.showCaptchaDialog { (result, error) -> () in
            if result {
                RedditSession.sharedSession.submitLink(link,
                    subredditName: subredditName,
                    text: nil,
                    url: NSURL(string: url),
                    postType: .Link,
                    captchaIdentifier: self.captchaIdentifier,
                    captchaValue: self.captchaValue, completion: { (error) -> () in
                    if error != nil {
                        self.hud.hide(true)
                        UIAlertView.showErrorWithError(error)
                        LocalyticsSession.shared().tagEvent("Unable to post link")
                    } else {
                        LocalyticsSession.shared().tagEvent("Posted link")
                        self.cancelButtonTapped(self)
                    }
                })
            } else {
                UIAlertView.showErrorWithError(error)
            }
        }
    }
    
    func showCaptchaDialog(completion: (result: Bool, error: NSError?) -> ()) {
        
        RedditSession.sharedSession.needsCaptchaWithCompletion { (result, error) -> () in
            if error != nil {
                completion(result: false, error: error)
            } else {
                if !result {
                    completion(result: true, error: error)
                } else {
                    RedditSession.sharedSession.newCaptchaIdWithCompletion { (pagination, results, error) -> () in
                        if let identifier = results?.first as? String {
                            self.captchaIdentifier = identifier
                            RedditSession.sharedSession.imageForCaptchaId(identifier, completion: { (pagination, results, error) -> () in
                                if error != nil {
                                    completion(result: false, error: error)
                                } else {
                                    if let image = results?.first as? UIImage {
                                        let alert = UIAlertController(title: "Enter Reddit captcha",
                                            message: "                                         ",
                                            preferredStyle: .Alert)
                                        
                                        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in })
                                        
                                        let okAction = UIAlertAction(title: "Ok", style: .Default, handler: { (action) -> Void in
                                            if let textfield = alert.textFields?.first {
                                                if textfield.text!.characters.count != 0 {
                                                    self.captchaValue = textfield.text
                                                    completion(result: true, error: nil)
                                                } else {
                                                    completion(result: false, error: nil)
                                                }
                                            }
                                        })
                                        
                                        let imageView = UIImageView(frame: CGRectMake(90, 40, 80, 40))
                                        imageView.image = image
                                        imageView.contentMode = .ScaleAspectFit
                                        alert.view.addSubview(imageView)
                                        
                                        alert.addAction(okAction)
                                        
                                        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
                                        
                                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                            self.presentViewController(alert, animated: true, completion: nil)
                                        })
                                    }
                                }
                            })
                        } else {
                            completion(result: false, error: error)
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func sendButtonTapped(sender: AnyObject) {
        if let subredditCell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as? PostSubredditCell {
            if subredditCell.subredditTextField.text?.characters.count > 0 {
                if let postTitleCell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0)) as? PostTitleCell {
                    if postTitleCell.titleTextField.text?.characters.count > 0 {
                        if self.postType == .Text {
                            if let postTextCell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 3, inSection: 0)) as? PostTextCell {
                                if postTextCell.textView.text?.characters.count > 0 {
                                    // Submit text
                                    self.postText(postTitleCell.titleTextField.text!,
                                        subredditName: subredditCell.subredditTextField.text!,
                                        text: postTextCell.textView.text!)
                                } else {
                                    UIAlertView.showPostNoTextError()
                                }
                            }
                        } else {
                            if let urlCell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 3, inSection: 0)) as? LinkCell {
                                if urlCell.linkTextField.text?.characters.count > 0 || self.selectedImage != nil {
                                    // Submit image
                                    self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                                    if let _ = self.selectedImage {
                                        self.postImage(postTitleCell.titleTextField.text!,
                                            subredditName: subredditCell.subredditTextField.text!)
                                    } else {
                                        self.postLink(postTitleCell.titleTextField.text!,
                                            subredditName: subredditCell.subredditTextField.text!,
                                            url: urlCell.linkTextField.text!)
                                    }
                                } else {
                                    UIAlertView.showPostNoLinkOrImageError()
                                }
                            }
                        }
                    } else {
                        UIAlertView.showPostNoTitleError()
                    }
                }
            } else {
                UIAlertView.showPostNoSubredditError()
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
        let alertController = UIAlertController(title: "Select source", message: nil, preferredStyle: .ActionSheet)
        
        alertController.addAction(UIAlertAction(title: "Photo Library", style: .Default, handler: { (action) -> Void in
            if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary){
                let picker = UIImagePickerController()
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
                let picker = UIImagePickerController()
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
        
        if let _ = self.selectedImage {
            alertController.addAction(UIAlertAction(title: "Remove link", style: .Destructive, handler: { (action) -> Void in
                self.selectedImage = nil
                LocalyticsSession.shared().tagEvent("Removed image from post")
            }))
        }
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    override func preferredAppearance() {
        
        self.postButton.tintColor = MyRedditLabelColor
        self.tableView.backgroundColor = MyRedditBackgroundColor
        self.tableView.tableFooterView = UIView()
        self.view.backgroundColor = MyRedditBackgroundColor
        
        self.navigationController?.navigationBar.backgroundColor = MyRedditBackgroundColor
        self.navigationController?.navigationBar.barTintColor = MyRedditBackgroundColor
        self.navigationController?.navigationBar.tintColor = MyRedditLabelColor
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : MyRedditLabelColor,
            NSFontAttributeName : MyRedditTitleFont]
        
        self.tableView.reloadData()
    }
}