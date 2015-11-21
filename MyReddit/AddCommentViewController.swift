//
//  AddCommentViewController.swift
//  MyReddit
//
//  Created by Nick Lanasa on 4/29/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation
import UIKit
import MBProgressHUD

protocol AddCommentViewControllerDelegate {
    func addCommentViewController(controller: AddCommentViewController, didAddComment success: Bool)
}

class AddCommentViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
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
                self.title = "new comment"
            } else {
                self.title = "message reply"
            }
        } else if let _ = self.link {
            if self.edit {
                self.title = "edit post"
                self.textView.text = self.link?.selfText
            } else {
                self.title = "add comment"
            }
        } else {
            if self.edit {
                self.title = "edit comment"
                self.textView.text = self.comment?.body
            } else {
                if let _ = self.comment {
                    self.title = "new reply"
                } else {
                    self.title = "new comment"
                }
            }
        }

        print(self.title)
        
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
        
        if self.textView.text.characters.count > 0 {
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
                        self.dismiss()
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
                            self.dismiss()
                        }
                    })
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
                                self.dismiss()
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
                                self.dismiss()
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
                                self.dismiss()
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
    
    func pop() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    private func dismiss() {
        if let _ = self.message {
            self.navigationController?.popViewControllerAnimated(true)
        } else {
            self.navigationController?.popViewControllerAnimated(true)
            self.delegate?.addCommentViewController(self, didAddComment: true)
        }
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
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
