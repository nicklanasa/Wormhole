//
//  Subreddit+Helper.swift
//  MyReddit
//
//  Created by Nickolas Lanasa on 3/25/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation

extension Subreddit {
    func parseSubreddit(subreddit: AnyObject) {
        if let rkSubreddit = subreddit as? RKSubreddit {
            
            self.identifier = rkSubreddit.fullName
            
            self.accountsActive = rkSubreddit.accountsActive

            self.commentScoreHiddenDuration = rkSubreddit.commentScoreHiddenDuration
            
            self.name = rkSubreddit.name.capitalizedString
                        
            if let subredditDescription = rkSubreddit.subredditDescription {
                self.subredditDescription = subredditDescription
            }
            
            if let subredditDescriptionHTML = rkSubreddit.subredditDescriptionHTML {
                self.subredditDescriptionHTML = subredditDescriptionHTML
            }
            
            if let publicDescription = rkSubreddit.publicDescription {
                self.publicDescription = publicDescription
            }
            
            if let headerImageURL = rkSubreddit.headerImageURL {
                if let absoluteString = headerImageURL.absoluteString {
                    self.headerImageURL = absoluteString
                }
            }
            
            if let headerTitle = rkSubreddit.headerTitle {
                self.headerTitle = headerTitle
            }
            
            self.url = rkSubreddit.URL
            
            self.over18 = rkSubreddit.over18
            
            self.contributor = rkSubreddit.contributor
            
            self.moderator = rkSubreddit.moderator
            
            self.subscriber = rkSubreddit.subscriber
            
            self.banned = rkSubreddit.banned
            
            self.totalSubscribers = rkSubreddit.totalSubscribers
            
            self.acceptedSubmissionsType = rkSubreddit.acceptedSubmissionsType.rawValue
            
            self.subredditType = rkSubreddit.subredditType.rawValue
            
            self.commentSpamFilterStrength = rkSubreddit.commentSpamFilterStrength.rawValue
            
            self.selfPostSpamFilterStrength = rkSubreddit.selfPostSpamFilterStrength.rawValue
            
            if let submitLinkPostLabel = rkSubreddit.submitLinkPostLabel {
                self.submitLinkPostLabel = submitLinkPostLabel
            }
            
            if let submitTextPostLabel = rkSubreddit.submitTextPostLabel {
                self.submitTextPostLabel = submitTextPostLabel
            }
            
            if let submitText = rkSubreddit.submitText {
                self.submitText = submitText
            }
            
            if let submitTextHTML = rkSubreddit.submitTextHTML {
                self.submitTextHTML = submitTextHTML
            }
            
            self.trafficPagePubliclyAccessible = rkSubreddit.trafficPagePubliclyAccessible
        }
        
        if let link = subreddit as? RKLink {
            if let name = link.subreddit {
                self.name = name
            }
            
            if let identifier = link.subredditFullName {
                self.identifier = identifier
            }
        }
        
        if let subredditData = subreddit as? [String : AnyObject] {
            if let name = subreddit["display_name"] as? String {
                self.name = name
            }
            
            if let subredditDescription = subreddit["description"] as? String {
                self.subredditDescription = subredditDescription
            }
            
            if let over18 = subreddit["over18"] as? NSNumber {
                self.over18 = over18
            }
            
            if let subscribers = subreddit["subscribers"] as? NSNumber {
                self.totalSubscribers = subscribers
            }
            
            if let headerIMG = subreddit["header_img"] as? String {
                self.headerImageURL = headerIMG
            }
            
            if let fullName = subreddit["id"] as? String {
                self.identifier = fullName
            }
        }
    }
}