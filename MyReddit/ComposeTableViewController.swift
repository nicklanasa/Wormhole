//
//  ComposeTableViewController.swift
//  MyReddit
//
//  Created by Nick Lanasa on 5/4/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation
import UIKit
import MBProgressHUD

class ComposeTableViewController: RootTableViewController, UITextViewDelegate {
    
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
        self.textView.backgroundColor = MyRedditBackgroundColor        
        self.toTextField.attributedPlaceholder = NSAttributedString(string: "to:",
            attributes: [NSForegroundColorAttributeName : UIColor.lightGrayColor()])
        self.subjectTextField.attributedPlaceholder = NSAttributedString(string: "subject:",
            attributes: [NSForegroundColorAttributeName : UIColor.lightGrayColor()])
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        LocalyticsSession.shared().tagScreen("Compose")
    }
    
    override func viewDidAppear(animated: Bool) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.toTextField.becomeFirstResponder()
        })
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 2 {
            return self.tableView.frame.size.height - (88)
        } else {
            return 44
        }
    }
    
    @IBAction func sendButtonTapped(sender: AnyObject) {        
        if self.textView.text.characters.count > 0 &&
            self.toTextField.text!.characters.count > 0 &&
            self.subjectTextField.text!.characters.count > 0 {
            self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            RedditSession.sharedSession.sendMessage(self.textView.text,
                subject: self.subjectTextField.text!,
                recipient: self.toTextField.text!,
                completion: { (error) -> () in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        if error != nil {
                            UIAlertView(title: "Error!",
                                message: error!.localizedDescription,
                                delegate: self,
                                cancelButtonTitle: "Ok").show()
                            self.hud.hide(true)
                            
                            LocalyticsSession.shared().tagEvent("Send message failed")
                        } else {
                            LocalyticsSession.shared().tagEvent("Send message")
                            self.hud.hide(true)
                            self.navigationController?.popViewControllerAnimated(true)
                        }
                    })
            })
        }
    }

    func dismiss() {
        self.textView.resignFirstResponder()
    }
    
    func textViewDidBeginEditing(textView: UITextView) {        
        if textView.text == "enter message..." {
            textView.text = ""
            textView.textColor = MyRedditLabelColor
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.characters.count == 0 {
            textView.text = "enter message..."
            textView.textColor = UIColor.lightGrayColor()
        }
    }
}
