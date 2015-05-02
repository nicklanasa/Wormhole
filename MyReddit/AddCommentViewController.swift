//
//  AddCommentViewController.swift
//  MyReddit
//
//  Created by Nick Lanasa on 4/29/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation
import UIKit

class AddCommentViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var textViewContainerView: UIView!
    
    var comment: RKComment?
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
            self.textView.font = MyRedditFont
        }
    }
    
    override func viewDidLoad() {
        self.textView = RFMarkdownTextView(frame: CGRectMake(0, 0, self.textViewContainerView.frame.size.width, self.textViewContainerView.frame.size.height))
        
        self.textView.becomeFirstResponder()
    }
    
    @IBAction func doneButtonTapped(sender: AnyObject) {
        textView.resignFirstResponder()
        var alert = UIAlertController(title: "Submit", message: "Are you sure you want to submit this comment?", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
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
                            self.cancelButtonTapped(self)
                        }
                })
            })
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.dismiss()
    }
    
    func dismiss() {
        self.textView.resignFirstResponder()
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}