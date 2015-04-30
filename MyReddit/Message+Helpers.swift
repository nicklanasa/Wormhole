//
//  Message+Helpers.swift
//  MyReddit
//
//  Created by Nickolas Lanasa on 3/26/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation
extension Message {
    func parseMessage(message: AnyObject) {
        if let rkMessage = message as? RKMessage {
            
            self.unread = rkMessage.unread.boolValue
            self.commentReply = rkMessage.commentReply.boolValue
            
            if let author = rkMessage.author {
                self.author = author
            }
            
            if let messageBody = rkMessage.messageBody {
                self.messageBody = messageBody
            }
            
            if let messageBodyHTML = rkMessage.messageBodyHTML {
                self.messageBodyHTML = messageBodyHTML
            }
            
            if let recipient = rkMessage.recipient {
                self.recipient = recipient
            }
            
            if let subject = rkMessage.subject {
                self.subject = subject
            }

            self.type = rkMessage.type.rawValue
            
            if let created = rkMessage.created {
                self.created = created
            }
            
            self.identifier = rkMessage.identifier
        }
    }
}