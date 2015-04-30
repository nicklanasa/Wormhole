//
//  Link.swift
//  MyReddit
//
//  Created by Nick Lanasa on 3/28/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation
import CoreData

@objc(Link)
class Link: NSManagedObject {

    @NSManaged var approvedBy: String
    @NSManaged var author: String
    @NSManaged var authorFlairClass: String
    @NSManaged var authorFlairText: String
    @NSManaged var bannedBy: String
    @NSManaged var distinguished: String
    @NSManaged var domain: String
    @NSManaged var downs: NSNumber
    @NSManaged var downvoted: NSNumber
    @NSManaged var edited: NSDate
    @NSManaged var gilded: NSNumber
    @NSManaged var hidden: NSNumber
    @NSManaged var identifier: String
    @NSManaged var isImageLink: NSNumber
    @NSManaged var linkFlairClass: String
    @NSManaged var linkFlairText: String
    @NSManaged var nsfw: NSNumber
    @NSManaged var permalink: String
    @NSManaged var saved: NSNumber
    @NSManaged var score: NSNumber
    @NSManaged var selfPost: NSNumber
    @NSManaged var selfText: String
    @NSManaged var selfTextHTML: String
    @NSManaged var stickied: NSNumber
    @NSManaged var thumbnailURL: String
    @NSManaged var title: String
    @NSManaged var totalComments: NSNumber
    @NSManaged var totalReports: NSNumber
    @NSManaged var ups: NSNumber
    @NSManaged var upvoted: NSNumber
    @NSManaged var upvoteRatio: NSNumber
    @NSManaged var url: String
    @NSManaged var visited: NSNumber
    @NSManaged var voted: NSNumber
    @NSManaged var subredditName: String
    @NSManaged var comments: NSSet
    @NSManaged var media: Media
    @NSManaged var subreddit: Subreddit

}
