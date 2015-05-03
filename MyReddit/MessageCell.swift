//
//  MessageCell.swift
//  MyReddit
//
//  Created by Nickolas Lanasa on 3/26/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation
import UIKit

class MessageCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var readLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!

    override func awakeFromNib() {
        
    }
    
    var message: RKMessage! {
        didSet {
            
            if !message.unread.boolValue {
                self.readLabel.hidden = true
            }
            
            self.titleLabel.text = message.subject
            self.bodyLabel.text = message.messageBody
            
            var messageType = "Message"
            
            if message.commentReply.boolValue {
               messageType = "Comment Reply"
            }
            
            var infoString = NSMutableAttributedString(string:"\(message.created.description) | \(message.author) | \(messageType)")
            var attrs = [NSForegroundColorAttributeName : MyRedditColor]
            infoString.addAttributes(attrs, range: NSMakeRange(0, count(message.created.description)))
            
            self.infoLabel.attributedText = infoString
            
            self.titleLabel.textColor = MyRedditLabelColor
        }
    }
}