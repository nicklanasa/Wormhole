//
//  ReadableContent.swift
//  MyReddit
//
//  Created by Nickolas Lanasa on 7/25/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation

class ReadableContent {
    var domain: String!
    var url: String!
    var shortURL: String!
    var author: String!
    var excerpt: String!
    var direction: String!
    var wordCount: Int!
    var totalPages: Int!
    var content: String!
    var datePublished: String!
    var dek: String!
    var title: String!
    
    init(json: [String : AnyObject]) {
        
        if let domain = json["domain"] as? String {
            self.domain = domain
        }
        
        if let url = json["url"] as? String {
            self.url = url
        }
        
        if let shortURL = json["short_url"] as? String {
            self.shortURL = shortURL
        }
        
        if let author = json["author"] as? String {
            self.author = author
        }
        
        if let excerpt = json["excerpt"] as? String {
            self.excerpt = excerpt
        }
        
        if let direction = json["direction"] as? String {
            self.direction = direction
        }
        
        if let wordCount = json["word_count"] as? Int {
            self.wordCount = wordCount
        }
        
        if let totalPages = json["total_pages"] as? Int {
            self.totalPages = totalPages
        }
        
        if let content = json["content"] as? String {
            self.content = content
        }
        
        if let datePublished = json["date_published"] as? String {
            self.datePublished = datePublished
        }
        
        if let title = json["title"] as? String {
            self.title = title
        }
    }
}