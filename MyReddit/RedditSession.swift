//
//  RedditSession.swift
//  MyReddit
//
//  Created by Nick Lanasa on 3/25/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation

let _sharedSession = RedditSession()

class RedditSession {
    
    typealias PaginationCompletion = (pagination: RKPagination?, results: [AnyObject]?, error: NSError?) -> ()
    typealias ErrorCompletion = (error: NSError?) -> ()
    
    init() {
    }
    
    class var sharedSession : RedditSession {
        return _sharedSession
    }
    
    func fetchFrontPagePosts(pagination: RKPagination?, category: RKSubredditCategory?, completion: PaginationCompletion) {
        if let subredditCategory = category {
            RKClient.sharedClient().frontPageLinksWithCategory(subredditCategory, pagination: pagination, completion: { (results, pagination, error) -> Void in
                completion(pagination: pagination, results: results, error: error)
            })
        } else {
            RKClient.sharedClient().frontPageLinksWithPagination(pagination, completion: { (results, pagination, error) -> Void in
                completion(pagination: pagination, results: results, error: error)
            })
        }
    }
    
    func fetchPostsForSubreddit(subreddit: Subreddit, category: RKSubredditCategory?, pagination: RKPagination?, completion: PaginationCompletion) {
        if let filterCategory = category {
            RKClient.sharedClient().linksInSubredditWithName(subreddit.name,
                category: filterCategory,
                pagination: pagination,
                completion: { (results, pagination, error) -> Void in
                completion(pagination: pagination, results: results, error: error)
            })
        } else {
            RKClient.sharedClient().linksInSubredditWithName(subreddit.name,
                pagination: pagination,
                completion: { (results, pagination, error) -> Void in
                completion(pagination: pagination, results: results, error: error)
            })
        }
    }
    
    func fetchPopularSubreddits(pagination: RKPagination?, completion: PaginationCompletion) {
        RKClient.sharedClient().popularSubredditsWithPagination(pagination, completion: { (results, pagination, error) -> Void in
            completion(pagination: pagination, results: results, error: error)
        })
    }
    
    func fetchSubscribedSubreddits(pagination: RKPagination?, category: RKSubscribedSubredditCategory, completion: PaginationCompletion) {
        RKClient.sharedClient().subscribedSubredditsInCategory(category, pagination: pagination, completion: { (results, pagination, error) -> Void in
            completion(pagination: pagination, results: results, error: error)
        })
    }
    
    func fetchMessages(pagination: RKPagination?, category: RKMessageCategory, completion: PaginationCompletion) {
        RKClient.sharedClient().messagesInCategory(category, pagination: pagination, markRead: false) { (results, pagination, error) -> Void in
            completion(pagination: pagination, results: results, error: error)
        }
    }
    
    func fetchComments(pagination: RKPagination?, link: RKLink, completion: PaginationCompletion) {
        RKClient.sharedClient().commentsForLink(link, completion: { (comments, pagination, error) -> Void in
            completion(pagination: pagination, results: comments, error: error)
        })
    }
    
    
}