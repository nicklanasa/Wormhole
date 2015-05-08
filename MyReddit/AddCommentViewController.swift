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
    
    @IBOutlet weak var textViewContainerView: UIView!
    
    var delegate: AddCommentViewControllerDelegate?
    
    var comment: RKComment?
    var message: RKMessage?
    var link: RKLink?
    
    var hud: MBProgressHUD! {
        didSet {
            hud.labelFont = MyRedditSelfTextFont
            hud.mode = .Indeterminate
            hud.labelText = "Loading"
        }
    }
    
    var textView: RFMarkdownTextView! {
        didSet {
            self.textView.delegate = self
            self.textViewContainerView.addSubview(self.textView)
            self.textView.font = MyRedditSelfTextFont
        }
    }
    
    override func viewDidLoad() {
        self.textView = RFMarkdownTextView(frame: CGRectMake(0, 0, self.textViewContainerView.frame.size.width, self.textViewContainerView.frame.size.height))
        
        if let replyMessage = self.message {
            if replyMessage.commentReply {
                self.navigationItem.title = "new comment"
            } else {
                self.navigationItem.title = "messasge reply"
            }
        } else {
            self.navigationItem.title = "new comment"
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
    }
    
    @IBAction func doneButtonTapped(sender: AnyObject) {
        textView.resignFirstResponder()
        
        if count(self.textView.text) > 0 {
            if let replyMessage = self.message {
                self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                
                RedditSession.sharedSession.submitComment(self.textView.text, onThingWithFullName: replyMessage.fullName, completion: { (error) -> () in
                    if error != nil {
                        self.hud.hide(true)
                        UIAlertView(title: "Error!",
                            message: "Unable to submit reply!",
                            delegate: self,
                            cancelButtonTitle: "Ok").show()
                    } else {
                        self.hud.hide(true)
                        self.dismissViewControllerAnimated(true, completion: { () -> Void in
                            self.delegate?.addCommentViewController(self, didAddComment: true)
                        })
                    }
                })
            } else {
                self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                
                RedditSession.sharedSession.submitComment(self.textView.text,
                    link: self.link, comment: self.comment, completion: { (error) -> () in
                        if error != nil {
                            self.hud.hide(true)
                            UIAlertView(title: "Error!",
                                message: "Unable to submit comment!",
                                delegate: self,
                                cancelButtonTitle: "Ok").show()
                        } else {
                            self.hud.hide(true)
                            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                                self.delegate?.addCommentViewController(self, didAddComment: true)
                            })
                        }
                })
            }
        } else {
            UIAlertView(title: "Error!",
                message: "Reply cannot be empty!",
                delegate: self,
                cancelButtonTitle: "Ok").show()
        }
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}