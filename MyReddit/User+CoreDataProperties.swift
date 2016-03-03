//
//  User+CoreDataProperties.swift
//  MyReddit
//
//  Created by Nickolas Lanasa on 3/2/16.
//  Copyright © 2016 Nytek Production. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension User {

    @NSManaged var commentKarma: NSNumber?
    @NSManaged var created: NSDate?
    @NSManaged var friend: NSNumber?
    @NSManaged var gold: NSNumber?
    @NSManaged var hasMail: NSNumber?
    @NSManaged var hasModeratorMail: NSNumber?
    @NSManaged var hasVerifiedEmailAddress: NSNumber?
    @NSManaged var linkKarma: NSNumber?
    @NSManaged var mod: NSNumber?
    @NSManaged var modHash: String?
    @NSManaged var over18: NSNumber?
    @NSManaged var password: String?
    @NSManaged var username: String?
    @NSManaged var identifier: String?

}
