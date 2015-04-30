//
//  Subreddit.swift
//  MyReddit
//
//  Created by Nick Lanasa on 3/25/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation
import CoreData

@objc(Subreddit)
class Subreddit: NSManagedObject {

    @NSManaged var acceptedSubmissionsType: NSNumber
    @NSManaged var accountsActive: NSNumber
    @NSManaged var banned: NSNumber
    @NSManaged var commentScoreHiddenDuration: NSNumber
    @NSManaged var commentSpamFilterStrength: NSNumber
    @NSManaged var contributor: NSNumber
    @NSManaged var headerImageURL: String?
    @NSManaged var headerTitle: String
    @NSManaged var identifier: String
    @NSManaged var linkSpamFilterStrength: NSNumber
    @NSManaged var moderator: NSNumber
    @NSManaged var name: String
    @NSManaged var over18: NSNumber
    @NSManaged var publicDescription: String
    @NSManaged var selfPostSpamFilterStrength: NSNumber
    @NSManaged var submitLinkPostLabel: String
    @NSManaged var submitText: String
    @NSManaged var submitTextHTML: String
    @NSManaged var submitTextPostLabel: String
    @NSManaged var subredditDescription: String
    @NSManaged var subredditDescriptionHTML: String
    @NSManaged var subredditType: NSNumber
    @NSManaged var subscriber: NSNumber
    @NSManaged var title: String
    @NSManaged var totalSubscribers: NSNumber
    @NSManaged var trafficPagePubliclyAccessible: NSNumber
    @NSManaged var url: String
    @NSManaged var modifiedDate: NSDate
    @NSManaged var links: NSSet
    @NSManaged var multiReddit: MultiReddit

}
