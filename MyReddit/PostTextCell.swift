//
//  PostTextCell.swift
//  MyReddit
//
//  Created by Nick Lanasa on 5/5/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation
import UIKit

class PostTextCell: UITableViewCell, UITextViewDelegate {
    @IBOutlet weak var textView: UITextView!
    
    
    override func awakeFromNib() {
        self.textView.delegate = self
        self.textView.font = MyRedditSelfTextFont
        self.textView.textColor = MyRedditPostTitleTextLabelColor
        self.textView.backgroundColor = MyRedditBackgroundColor
        self.textView.scrollEnabled = false
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        
        if textView.text == "enter text..." {
            textView.text = ""
            textView.textColor = MyRedditLabelColor
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {

        if textView.text.characters.count == 0 {
            textView.text = "enter text..."
            textView.textColor = UIColor(red: 187/255, green: 187/255, blue: 193/255, alpha: 1.0)
        }
    }
    
    var textString: String {
        get {
            return textView?.text ?? ""
        }
        set {
            textView?.text = newValue
            
            textViewDidChange(textView)
        }
    }
    
    func textViewDidChange(textView: UITextView) {
        
        let size = textView.bounds.size
        let newSize = textView.sizeThatFits(CGSize(width: size.width, height: CGFloat.max))
        
        // Resize the cell only when cell's size is changed
        if size.height != newSize.height {
            UIView.setAnimationsEnabled(false)
            tableView?.beginUpdates()
            tableView?.endUpdates()
            UIView.setAnimationsEnabled(true)
            
            if let thisIndexPath = tableView?.indexPathForCell(self) {
                tableView?.scrollToRowAtIndexPath(thisIndexPath, atScrollPosition: .Bottom, animated: false)
            }
        }
    }
}