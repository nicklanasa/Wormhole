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
    
    func fetchPostsForMultiReddit(multiReddit: RKMultireddit, category: RKSubredditCategory?, pagination: RKPagination?, completion: PaginationCompletion) {
        if let filterCategory = category {
            RKClient.sharedClient().linksInMultireddit(multiReddit, category: filterCategory, pagination: pagination, completion: { (results, pagination, error) -> Void in
                completion(pagination: pagination, results: results, error: error)
            })
        } else {
            RKClient.sharedClient().linksInMultireddit(multiReddit, pagination: pagination, completion: { (results, pagination, error) -> Void in
                completion(pagination: pagination, results: results, error: error)
            })
        }
    }
    
    func fetchPostsForSubreddit(subreddit: RKSubreddit, category: RKSubredditCategory?, pagination: RKPagination?, completion: PaginationCompletion) {
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
    
    func fetchMultiReddits(completion: PaginationCompletion) {
        RKClient.sharedClient().multiredditsWithCompletion { (mutliReddts, error) -> Void in
            completion(pagination: nil, results: mutliReddts, error: error)
        }
    }
    
    func createMultiReddit(name: String, visibility: RKMultiredditVisibility, completion: ErrorCompletion) {
        RKClient.sharedClient().createMultiredditWithName(name, subreddits: [], visibility: visibility) { (multiReddit, error) -> Void in
            completion(error: error)
        }
    }
    
    func addSubredditToMultiReddit(multiReddit: RKMultireddit, subreddit: RKSubreddit, completion: ErrorCompletion) {
        RKClient.sharedClient().addSubreddit(subreddit, toMultireddit: multiReddit) { (error) -> Void in
            completion(error: error)
        }
    }
    
    func markLinkAsViewed(link: RKLink, completion: ErrorCompletion) {
    }
    
    func fetchMessages(pagination: RKPagination?, category: RKMessageCategory, read: Bool, completion: PaginationCompletion) {
        RKClient.sharedClient().messagesInCategory(category, pagination: pagination, markRead: read) { (results, pagination, error) -> Void in
            completion(pagination: pagination, results: results, error: error)
        }
    }
    
    func markMessagesAsRead(messages: [AnyObject], completion: ErrorCompletion) {
        RKClient.sharedClient().markMessageArrayAsRead(messages, completion: { (error) -> Void in
            completion(error: error)
        })
    }
    
    func markMessagesAsUnRead(messages: [AnyObject], completion: ErrorCompletion) {
        RKClient.sharedClient().markMessageArrayAsUnread(messages, completion: { (error) -> Void in
            completion(error: error)
        })
    }
    
    func sendMessage(message: String, subject: String, recipient: String, completion: ErrorCompletion) {
        RKClient.sharedClient().sendMessage(message, subject: subject, recipient: recipient) { (error) -> Void in
            completion(error: error)
        }
    }
    
    func fetchComments(pagination: RKPagination?, link: RKLink, completion: PaginationCompletion) {
        RKClient.sharedClient().commentsForLink(link, completion: { (comments, pagination, error) -> Void in
            completion(pagination: pagination, results: comments, error: error)
        })
    }
    
    func fetchLinkWithComment(comment: RKComment, completion: PaginationCompletion) {
        RKClient.sharedClient().linkWithFullName(comment.linkID, completion: { (link, error) -> Void in
            completion(pagination: nil, results: [link], error: error)
        })
    }
    
    func upvote(object: RKVotable, completion: ErrorCompletion) {
        if object.voted() {
            self.revokeVote(object, completion: { (error) -> () in
                completion(error: error)
            })
        } else {
            RKClient.sharedClient().upvote(object, completion: { (error) -> Void in
                completion(error: error)
            })
        }
    }
    
    func downvote(object: RKVotable, completion: ErrorCompletion) {
        if object.voted() {
            self.revokeVote(object, completion: { (error) -> () in
                completion(error: error)
            })
        } else {
            RKClient.sharedClient().downvote(object, completion: { (error) -> Void in
                completion(error: error)
            })
        }
    }
    
    func revokeVote(object: RKVotable, completion: ErrorCompletion) {
        RKClient.sharedClient().revokeVote(object, completion: { (error) -> Void in
            completion(error: error)
        })
    }
    
    func subscribe(subreddit: RKSubreddit, completion: ErrorCompletion) {
        RKClient.sharedClient().subscribeToSubredditWithFullName(subreddit.fullName, completion: { (error) -> Void in
            completion(error: error)
        })
    }
    
    func unsubscribe(subreddit: RKSubreddit, completion: ErrorCompletion) {
        RKClient.sharedClient().unsubscribeFromSubredditWithFullName(subreddit.fullName, completion: { (error) -> Void in
            completion(error: error)
        })
    }
    
    func deleteMultiReddit(multiReddit: RKMultireddit, completion: ErrorCompletion) {
        RKClient.sharedClient().deleteMultireddit(multiReddit, completion: { (error) -> Void in
            completion(error: error)
        })
    }
    
    func searchForSubredditByName(name: String, pagination: RKPagination?, completion: PaginationCompletion) {
        RKClient.sharedClient().searchForSubredditsByName(name, pagination: pagination) { (subreddit, pagination, error) -> Void in
            completion(pagination: pagination, results: [subreddit], error: error)
        }
    }
    
    func subredditWithSubredditName(name: String, completion: PaginationCompletion) {
        RKClient.sharedClient().subredditWithName(name, completion: { (subreddit, error) -> Void in
            completion(pagination: nil, results: [subreddit], error: error)
        })
    }
    
    func submitComment(commentText: String, link: RKLink?, comment: RKComment?, completion: ErrorCompletion) {
        if let commentLink = link {
            RKClient.sharedClient().submitComment(commentText, onLink: commentLink, completion: { (error) -> Void in
                completion(error: error)
            })
        } else if let replyComment = comment {
            RKClient.sharedClient().submitComment(commentText, asReplyToComment: replyComment, completion: { (error) -> Void in
                completion(error: error)
            })
        } else {
            completion(error: nil)
        }
    }
    
    func submitComment(commentText: String, onThingWithFullName: String, completion: ErrorCompletion) {
        RKClient.sharedClient().submitComment(commentText, onThingWithFullName: onThingWithFullName) { (error) -> Void in
            completion(error: error)
        }
    }
    
    func searchForLinks(searchText: String, pagination: RKPagination?, completion: PaginationCompletion) {
        RKClient.sharedClient().search(searchText, pagination: pagination) { (results, pagination, error) -> Void in
            completion(pagination: pagination, results: results, error: error)
        }
    }
    
    func searchForLinksInSubreddit(subreddit: RKSubreddit, searchText: String, pagination: RKPagination?, completion: PaginationCompletion) {
        RKClient.sharedClient().search(searchText, subreddit: subreddit, restrictSubreddit: true, pagination: pagination) { (results, pagination, error) -> Void in
            completion(pagination: pagination, results: results, error: error)
        }
    }
}