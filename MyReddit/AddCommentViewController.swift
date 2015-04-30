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
    
    var textView: RFMarkdownTextView! {
        didSet {
            self.textView.delegate = self
            self.textViewContainerView.addSubview(self.textView)
            
            self.textView.font = MyRedditFont
            
            self.textView.becomeFirstResponder()
        }
    }
    
    override func viewDidLoad() {
        self.textView = RFMarkdownTextView(frame: CGRectMake(0, 0, self.textViewContainerView.frame.size.width, self.textViewContainerView.frame.size.height))
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
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