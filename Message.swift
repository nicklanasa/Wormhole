//
//  Message.swift
//  MyReddit
//
//  Created by Nickolas Lanasa on 3/26/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation
import CoreData

@objc(Message)
class Message: NSManagedObject {

    @NSManaged var author: String
    @NSManaged var commentReply: NSNumber
    @NSManaged var firstMessage: String
    @NSManaged var firstMessageFullName: String
    @NSManaged var messageBody: String
    @NSManaged var messageBodyHTML: String
    @NSManaged var recipient: String
    @NSManaged var subject: String
    @NSManaged var type: NSNumber
    @NSManaged var unread: NSNumber
    @NSManaged var created: NSDate
    @NSManaged var identifier: String
    @NSManaged var replies: NSSet

}
