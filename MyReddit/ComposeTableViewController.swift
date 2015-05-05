//
//  ComposeTableViewController.swift
//  MyReddit
//
//  Created by Nick Lanasa on 5/4/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation
import UIKit

class ComposeTableViewController: UITableViewController, UITextViewDelegate {
    
    @IBOutlet weak var toTextField: UITextField!
    @IBOutlet weak var subjectTextField: UITextField!
    @IBOutlet weak var messageCell: UITableViewCell!
    @IBOutlet weak var textView: UITextView!
    
    var hud: MBProgressHUD! {
        didSet {
            hud.labelFont = MyRedditSelfTextFont
            hud.mode = .Indeterminate
            hud.labelText = "Loading"
        }
    }
    
    override func viewDidLoad() {
        self.tableView.backgroundColor = MyRedditBackgroundColor
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 2 {
            return self.tableView.frame.size.height - (88)
        } else {
            return 44
        }
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func sendButtonTapped(sender: AnyObject) {
        
        if count(self.textView.text) > 0 &&
            count(self.toTextField.text) > 0 &&
            count(self.subjectTextField.text) > 0 {
            self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            RedditSession.sharedSession.sendMessage(self.textView.text,
                subject: self.subjectTextField.text,
                recipient: self.toTextField.text,
                completion: { (error) -> () in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        if error != nil {
                            UIAlertView(title: "Error!",
                                message: error!.localizedDescription,
                                delegate: self,
                                cancelButtonTitle: "Ok").show()
                            self.hud.hide(true)
                        } else {
                            self.hud.hide(true)
                            self.dismissViewControllerAnimated(true, completion: nil)
                        }
                    })
            })
        }
    }

    func dismiss() {
        self.textView.resignFirstResponder()
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        
        self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 2,
            inSection: 0),
            atScrollPosition: .Top,
            animated: true)
        
        if textView.text == "enter message..." {
            textView.text = ""
            textView.textColor = MyRedditLabelColor
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if count(textView.text) == 0 {
            textView.text = "enter message..."
            textView.textColor = UIColor.lightGrayColor()
        }
    }
}