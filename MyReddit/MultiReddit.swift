//
//  MultiReddit.swift
//  MyReddit
//
//  Created by Nick Lanasa on 3/25/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation
import CoreData

@objc(MultiReddit)
class MultiReddit: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var created: NSDate
    @NSManaged var editable: NSNumber
    @NSManaged var path: String
    @NSManaged var visibility: NSNumber
    @NSManaged var bodyHTML: String
    @NSManaged var bodyMarkdown: String
    @NSManaged var subreddits: NSSet

}
