//
//  Link+Helpers.swift
//  MyReddit
//
//  Created by Nick Lanasa on 3/25/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation

extension Link {
    func parseLink(link: AnyObject) {
        if let rkLink = link as? RKLink {
            self.nsfw = rkLink.NSFW
            
            if let url = rkLink.URL {
                if let absoluteString = url.absoluteString {
                    self.url = absoluteString
                }
            }
            
            if let approvedBy = rkLink.approvedBy {
                self.approvedBy = approvedBy
            }
            
            if let author = rkLink.author {
                self.author = author
            }
            
            if let authorFlairClass = rkLink.authorFlairClass {
                self.authorFlairClass = authorFlairClass
            }
            
            if let bannedBy = rkLink.bannedBy {
                self.bannedBy = bannedBy
            }
            
            if let distinguished = rkLink.distinguished {
                self.distinguished = distinguished
            }
            
            if let domain = rkLink.domain {
                self.domain = domain
            }
            
            if let edited = rkLink.edited {
                self.edited = edited
            }
            
            self.gilded = rkLink.gilded
            self.hidden = rkLink.hidden
            self.saved = rkLink.saved
            self.selfPost = rkLink.selfPost
            self.stickied = rkLink.stickied
            
            self.totalComments = rkLink.totalComments
            self.totalReports = rkLink.totalReports
            self.upvoteRatio = rkLink.upvoteRatio
            self.visited = rkLink.visited
            
            if let linkFlairText = rkLink.linkFlairText {
                self.linkFlairText = linkFlairText
            }
            
            if let permalink = rkLink.permalink {
                if let absoluteString = permalink.absoluteString {
                    self.permalink = absoluteString
                }
            }
            
            if let authorFlairText = rkLink.authorFlairText {
                self.authorFlairText = authorFlairText
            }
            
            if let selfText = rkLink.selfText {
                self.selfText = selfText
            }
            
            if let selfTextHTML = rkLink.selfTextHTML {
                self.selfTextHTML = selfTextHTML
            }
            
            if let thumbnailURL = rkLink.thumbnailURL {
                if let absoluteString = thumbnailURL.absoluteString {
                    self.thumbnailURL = absoluteString
                }
            }
            
            if let title = rkLink.title {
                self.title = title
            }
            
            if let subreddit = rkLink.subreddit {
                self.subredditName = subreddit
            }
            
            self.identifier = rkLink.identifier
            
            self.isImageLink = rkLink.isImageLink()
            
            self.voted = rkLink.voted()
            
            self.ups = rkLink.upvotes
            
            self.downs = rkLink.downvotes
            
            self.score = rkLink.score
            
            self.upvoted = rkLink.upvoted()
            
            self.downvoted = rkLink.downvoted()
        }
    }

}