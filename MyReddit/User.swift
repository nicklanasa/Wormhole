//
//  User.swift
//  MyReddit
//
//  Created by Nickolas Lanasa on 3/25/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation
import CoreData

@objc(User)
class User: NSManagedObject {

    @NSManaged var commentKarma: NSNumber
    @NSManaged var friend: NSNumber
    @NSManaged var gold: NSNumber
    @NSManaged var hasMail: NSNumber
    @NSManaged var hasModeratorMail: NSNumber
    @NSManaged var hasVerifiedEmailAddress: NSNumber
    @NSManaged var linkKarma: NSNumber
    @NSManaged var mod: NSNumber
    @NSManaged var modHash: String
    @NSManaged var over18: NSNumber
    @NSManaged var username: String
    @NSManaged var created: NSDate

}
