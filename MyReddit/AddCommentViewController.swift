//
//  AddCommentViewController.swift
//  MyReddit
//
//  Created by Nick Lanasa on 4/29/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation
import UIKit

protocol AddCommentViewControllerDelegate {
    func addCommentViewController(controller: AddCommentViewController, didAddComment success: Bool)
}

class AddCommentViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var verticalSpaceConstraint: NSLayoutConstraint!
    
    var delegate: AddCommentViewControllerDelegate?
    
    var comment: RKComment?
    var edit = false
    var message: RKMessage?
    var link: RKLink?
    
    var hud: MBProgressHUD! {
        didSet {
            hud.labelFont = MyRedditSelfTextFont
            hud.mode = .Indeterminate
            hud.labelText = "Loading"
        }
    }
    
    override func viewDidLoad() {
        self.textView.font = MyRedditSelfTextFont
        
        if let replyMessage = self.message {
            if replyMessage.commentReply {
                self.navigationItem.title = "new comment"
            } else {
                self.navigationItem.title = "messasge reply"
            }
        } else if let editLink = self.link {
            if self.edit {
                self.navigationItem.title = "edit post"
                self.textView.text = self.link?.selfText
            }
        } else {
            if self.edit {
                self.navigationItem.title = "edit comment"
                self.textView.text = self.comment?.body
            } else {
                if let replyComment = self.comment {
                    self.navigationItem.title = "reply"
                } else {
                    self.navigationItem.title = "new comment"
                }
            }
        }
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            if UIDevice.currentDevice().orientation == .LandscapeLeft || UIDevice.currentDevice().orientation == .LandscapeRight {
                self.verticalSpaceConstraint.constant = 390
            } else {
                self.verticalSpaceConstraint.constant = 300
            }
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.view.layoutIfNeeded()
            })
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.textView.becomeFirstResponder()
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        LocalyticsSession.shared().tagScreen("AddComment")
        
        self.view.backgroundColor = MyRedditBackgroundColor
        self.textView.backgroundColor = MyRedditBackgroundColor
        self.textView.textColor = MyRedditLabelColor
    }
    
    @IBAction func doneButtonTapped(sender: AnyObject) {
        textView.resignFirstResponder()
        
        if count(self.textView.text) > 0 {
            if let replyMessage = self.message {
                self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                
                RedditSession.sharedSession.submitComment(self.textView.text,
                    onThingWithFullName: replyMessage.fullName, completion: { (error) -> () in
                    self.hud.hide(true)
                    if error != nil {
                        UIAlertView(title: "Error!",
                            message: error?.localizedDescription,
                            delegate: self,
                            cancelButtonTitle: "Ok").show()
                    } else {
                        self.dismissViewControllerAnimated(true, completion: { () -> Void in
                            self.delegate?.addCommentViewController(self, didAddComment: true)
                        })
                    }
                })
            } else if let editLink = self.link {
                self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                
                if self.edit {
                    RedditSession.sharedSession.editLink(editLink,
                        newText: self.textView.text,
                        completion: { (error) -> () in
                        if error != nil {
                            UIAlertView(title: "Error!",
                                message: error?.localizedDescription,
                                delegate: self,
                                cancelButtonTitle: "Ok").show()
                        } else {
                            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                                self.delegate?.addCommentViewController(self, didAddComment: true)
                            })
                        }
                    })
                }
            } else {
                self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                
                if self.edit {
                    if let editComment = self.comment {
                        RedditSession.sharedSession.editComment(editComment,
                            newText: self.textView.text,
                            completion: { (error) -> () in
                            if error != nil {
                                UIAlertView(title: "Error!",
                                    message: error?.localizedDescription,
                                    delegate: self,
                                    cancelButtonTitle: "Ok").show()
                            } else {
                                self.dismissViewControllerAnimated(true, completion: { () -> Void in
                                    self.delegate?.addCommentViewController(self, didAddComment: true)
                                })
                            }
                        })
                    }
                } else {
                    RedditSession.sharedSession.submitComment(self.textView.text,
                        link: self.link, comment: self.comment, completion: { (error) -> () in
                            self.hud.hide(true)
                            if error != nil {
                                UIAlertView(title: "Error!",
                                    message: error?.localizedDescription,
                                    delegate: self,
                                    cancelButtonTitle: "Ok").show()
                            } else {
                                self.dismissViewControllerAnimated(true, completion: { () -> Void in
                                    self.delegate?.addCommentViewController(self, didAddComment: true)
                                })
                            }
                    })
                }
            }
        } else {
            UIAlertView(title: "Error!",
                message: "Text cannot be empty!",
                delegate: self,
                cancelButtonTitle: "Ok").show()
        }
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        if fromInterfaceOrientation == .Portrait || fromInterfaceOrientation == .PortraitUpsideDown {
            if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
                self.verticalSpaceConstraint.constant = 390
            } else {
                self.verticalSpaceConstraint.constant = 200
            }
        } else {
            if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
                self.verticalSpaceConstraint.constant = 300
            } else {
                self.verticalSpaceConstraint.constant = 272
            }
        }
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
}