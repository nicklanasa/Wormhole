//
//  User.swift
//  
//
//  Created by Nickolas Lanasa on 5/2/15.
//
//

import Foundation
import CoreData

@objc(User)
class User: NSManagedObject {

    @NSManaged var commentKarma: NSNumber
    @NSManaged var created: NSDate
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
    @NSManaged var password: String

}
