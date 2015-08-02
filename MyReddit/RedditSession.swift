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
    typealias ReadableCompletion = (content: ReadableContent?, error: NSError?) -> ()
    typealias ErrorCompletion = (error: NSError?) -> ()
    typealias BooleanCompletion = (result: Bool, error: NSError?) -> ()
    
    init() {
    }
    
    class var sharedSession : RedditSession {
        return _sharedSession
    }
    
    func fetchFrontPagePosts(pagination: RKPagination?, category: RKSubredditCategory?, completion: PaginationCompletion) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        LocalyticsSession.shared().tagEvent("Fetched front page links")
        
        if let subredditCategory = category {
            RKClient.sharedClient().frontPageLinksWithCategory(subredditCategory, pagination: pagination, completion: { (results, pagination, error) -> Void in
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                completion(pagination: pagination, results: results, error: error)
            })
        } else {
            RKClient.sharedClient().frontPageLinksWithPagination(pagination, completion: { (results, pagination, error) -> Void in
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                completion(pagination: pagination, results: results, error: error)
            })
        }
    }
    
    func fetchAllPosts(pagination: RKPagination?, category: RKSubredditCategory?, completion: PaginationCompletion) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        LocalyticsSession.shared().tagEvent("Fetched front page links")
        
        if let subredditCategory = category {
            RKClient.sharedClient().linksInAllSubredditsWithCategory(subredditCategory, pagination: pagination, completion: { (results, pagination, error) -> Void in
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                completion(pagination: pagination, results: results, error: error)
            })
        } else {
            RKClient.sharedClient().linksInAllSubredditsWithPagination(pagination, completion: { (results, pagination, error) -> Void in
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                completion(pagination: pagination, results: results, error: error)
            })
        }
    }
    
    func fetchPostsForMultiReddit(multiReddit: RKMultireddit, category: RKSubredditCategory?, pagination: RKPagination?, completion: PaginationCompletion) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        LocalyticsSession.shared().tagEvent("Fetched multireddit links")
        
        if let filterCategory = category {
            RKClient.sharedClient().linksInMultireddit(multiReddit, category: filterCategory, pagination: pagination, completion: { (results, pagination, error) -> Void in
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                completion(pagination: pagination, results: results, error: error)
            })
        } else {
            RKClient.sharedClient().linksInMultireddit(multiReddit, pagination: pagination, completion: { (results, pagination, error) -> Void in
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                completion(pagination: pagination, results: results, error: error)
            })
        }
    }
    
    func fetchPostsForSubreddit(subreddit: RKSubreddit, category: RKSubredditCategory?, pagination: RKPagination?, completion: PaginationCompletion) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        LocalyticsSession.shared().tagEvent("Fetched subreddit links")
        
        if let filterCategory = category {
            RKClient.sharedClient().linksInSubredditWithName(subreddit.name,
                category: filterCategory,
                pagination: pagination,
                completion: { (results, pagination, error) -> Void in
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                completion(pagination: pagination, results: results, error: error)
            })
        } else {
            RKClient.sharedClient().linksInSubredditWithName(subreddit.name,
                pagination: pagination,
                completion: { (results, pagination, error) -> Void in
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                completion(pagination: pagination, results: results, error: error)
            })
        }
    }
    
    func fetchPopularSubreddits(pagination: RKPagination?, completion: PaginationCompletion) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        LocalyticsSession.shared().tagEvent("Fetched popular subreddits")
        
        RKClient.sharedClient().popularSubredditsWithPagination(pagination, completion: { (results, pagination, error) -> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            completion(pagination: pagination, results: results, error: error)
        })
    }
    
    func fetchSubscribedSubreddits(pagination: RKPagination?, category: RKSubscribedSubredditCategory, completion: PaginationCompletion) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        LocalyticsSession.shared().tagEvent("Fetched subscribe subreddits")
        
        RKClient.sharedClient().subscribedSubredditsInCategory(category, pagination: pagination, completion: { (results, pagination, error) -> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            completion(pagination: pagination, results: results, error: error)
        })
    }
    
    func fetchMultiReddits(completion: PaginationCompletion) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        LocalyticsSession.shared().tagEvent("Fetched multireddits")
        
        RKClient.sharedClient().multiredditsWithCompletion { (mutliReddts, error) -> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            completion(pagination: nil, results: mutliReddts, error: error)
        }
    }
    
    func createMultiReddit(name: String, visibility: RKMultiredditVisibility, completion: ErrorCompletion) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        LocalyticsSession.shared().tagEvent("Created multireddit")
        
        RKClient.sharedClient().createMultiredditWithName(name, subreddits: [], visibility: visibility) { (multiReddit, error) -> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            completion(error: error)
        }
    }
    
    func addSubredditToMultiReddit(multiReddit: RKMultireddit, subreddit: RKSubreddit, completion: ErrorCompletion) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        LocalyticsSession.shared().tagEvent("Added subreddit to multireddit")
        
        RKClient.sharedClient().addSubreddit(subreddit, toMultireddit: multiReddit) { (error) -> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            completion(error: error)
        }
    }
    
    func updateMultiredditWithName(multiReddit: RKMultireddit, subreddits: [AnyObject], completion: PaginationCompletion) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        LocalyticsSession.shared().tagEvent("Update multireddit subreddits")
        
        RKClient.sharedClient().updateMultiredditWithName(multiReddit.name, subreddits: subreddits, visibility: multiReddit.visibility) { (result, error) -> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            if result == nil {
                completion(pagination: nil, results: nil, error: error)
            } else {
                completion(pagination: nil, results: [result], error: error)
            }
        }
    }
    
    func renameMultiredditWithName(name: String, multiReddit: RKMultireddit, completion: ErrorCompletion) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        LocalyticsSession.shared().tagEvent("Rename multireddit")
        
        RKClient.sharedClient().renameMultireddit(multiReddit, to: name) { (error) -> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            completion(error: error)
        }
    }
    
    func multiredditWithName(name: String, completion: PaginationCompletion) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        LocalyticsSession.shared().tagEvent("Fetch multireddit")
        
        if let user = UserSession.sharedSession.currentUser {
            RKClient.sharedClient().multiredditWithName(name, user: RKClient.sharedClient().currentUser) { (result, error) -> Void in
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if result == nil {
                    completion(pagination: nil, results: nil, error: error)
                } else {
                    completion(pagination: nil, results: [result], error: error)
                }
            }
        } else {
            completion(pagination: nil, results: nil, error: NSError(domain: "Myreddit", code: -1, userInfo: nil))
        }
    }
    
    func removeSubredditFromMultireddit(multireddit: RKMultireddit, subreddit: RKSubreddit, completion: ErrorCompletion) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        LocalyticsSession.shared().tagEvent("Remove subreddit from multireddit")
        
        RKClient.sharedClient().removeSubreddit(subreddit, fromMultireddit: multireddit) { (error) -> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            completion(error: error)
        }
    }
    
    func markLinkAsViewed(link: RKLink, completion: ErrorCompletion) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        RKClient.sharedClient().storeVisitedLink(link, completion: { (error) -> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            completion(error: error)
        })
    }
    
    func fetchMessages(pagination: RKPagination?, category: RKMessageCategory, read: Bool, completion: PaginationCompletion) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        LocalyticsSession.shared().tagEvent("Fetched messages")
        
        RKClient.sharedClient().messagesInCategory(category, pagination: pagination, markRead: read) { (results, pagination, error) -> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            completion(pagination: pagination, results: results, error: error)
        }
    }
    
    func markMessagesAsRead(messages: [AnyObject], completion: ErrorCompletion) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        RKClient.sharedClient().markMessageArrayAsRead(messages, completion: { (error) -> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            completion(error: error)
        })
    }
    
    func markMessagesAsUnRead(messages: [AnyObject], completion: ErrorCompletion) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        RKClient.sharedClient().markMessageArrayAsUnread(messages, completion: { (error) -> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            completion(error: error)
        })
    }
    
    func sendMessage(message: String, subject: String, recipient: String, completion: ErrorCompletion) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        RKClient.sharedClient().sendMessage(message, subject: subject, recipient: recipient) { (error) -> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            completion(error: error)
        }
    }
    
    func fetchComments(pagination: RKPagination?, link: RKLink, completion: PaginationCompletion) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        LocalyticsSession.shared().tagEvent("Fetched comments")
        
        RKClient.sharedClient().commentsForLink(link, completion: { (comments, pagination, error) -> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            completion(pagination: pagination, results: comments, error: error)
        })
    }
    
    func fetchCommentsWithFilter(filter: RKCommentSort, pagination: RKPagination?, link: RKLink, completion: PaginationCompletion) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        LocalyticsSession.shared().tagEvent("Fetched comments")
        
        RKClient.sharedClient().commentsForLinkWithIdentifier(link.identifier, sort: filter) { (results, pagination, error) -> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            completion(pagination: pagination, results: results, error: error)
        }
    }
    
    func fetchCommentsForComment(comment: RKComment, pagination: RKPagination?, completion: PaginationCompletion) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        LocalyticsSession.shared().tagEvent("Fetched comments for comment")
        
        RKClient.sharedClient().commentsForLinkWithIdentifier(comment.fullName, completion: { (results, pagination, error) -> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            completion(pagination: pagination, results: results, error: error)
        })
    }
    
    func fetchLinkWithComment(comment: RKComment, completion: PaginationCompletion) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        LocalyticsSession.shared().tagEvent("Fetched link for comment")
        
        RKClient.sharedClient().linkWithFullName(comment.linkID, completion: { (link, error) -> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            completion(pagination: nil, results: [link], error: error)
        })
    }
    
    func upvote(object: RKVotable, completion: ErrorCompletion) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        if object.voted() {
            
            LocalyticsSession.shared().tagEvent("Revoked vote")
            
            self.revokeVote(object, completion: { (error) -> () in
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                completion(error: error)
            })
        } else {
            
            LocalyticsSession.shared().tagEvent("Upvoted")
            
            RKClient.sharedClient().upvote(object, completion: { (error) -> Void in
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                completion(error: error)
            })
        }
    }
    
    func downvote(object: RKVotable, completion: ErrorCompletion) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        if object.voted() {
            
            LocalyticsSession.shared().tagEvent("Revoked vote")
            
            self.revokeVote(object, completion: { (error) -> () in
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                completion(error: error)
            })
        } else {
            
            LocalyticsSession.shared().tagEvent("Downvoted")
            
            RKClient.sharedClient().downvote(object, completion: { (error) -> Void in
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                completion(error: error)
            })
        }
    }
    
    func revokeVote(object: RKVotable, completion: ErrorCompletion) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        RKClient.sharedClient().revokeVote(object, completion: { (error) -> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            completion(error: error)
        })
    }
    
    func subscribe(subreddit: RKSubreddit, completion: ErrorCompletion) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        LocalyticsSession.shared().tagEvent("Subscribed to subreddit")
        
        RKClient.sharedClient().subscribeToSubredditWithFullName(subreddit.fullName, completion: { (error) -> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            completion(error: error)
        })
    }
    
    func unsubscribe(subreddit: RKSubreddit, completion: ErrorCompletion) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        LocalyticsSession.shared().tagEvent("Unsubscribed to subreddit")
        
        RKClient.sharedClient().unsubscribeFromSubredditWithFullName(subreddit.fullName, completion: { (error) -> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            completion(error: error)
        })
    }
    
    func deleteMultiReddit(multiReddit: RKMultireddit, completion: ErrorCompletion) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        LocalyticsSession.shared().tagEvent("Deleted multireddit")
        
        RKClient.sharedClient().deleteMultireddit(multiReddit, completion: { (error) -> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            completion(error: error)
        })
    }
    
    func searchForSubredditByName(name: String, pagination: RKPagination?, completion: PaginationCompletion) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        RKClient.sharedClient().searchForSubredditsByName(name, pagination: pagination) { (result, pagination, error) -> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            if let subreddits = result {
                completion(pagination: pagination, results: subreddits, error: error)
            } else {
                completion(pagination: pagination, results: nil, error: error)
            }
        }
    }
    
    func subredditWithSubredditName(name: String, completion: PaginationCompletion) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        RKClient.sharedClient().subredditWithName(name, completion: { (result, error) -> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            if let subreddits = result as? [AnyObject] {
                completion(pagination: nil, results: subreddits, error: error)
            } else {
                completion(pagination: nil, results: nil, error: error)
            }
        })
    }
    
    func submitComment(commentText: String, link: RKLink?, comment: RKComment?, completion: ErrorCompletion) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        if let commentLink = link {
            LocalyticsSession.shared().tagEvent("Submitted comment on link")
            RKClient.sharedClient().submitComment(commentText, onLink: commentLink, completion: { (error) -> Void in
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                completion(error: error)
            })
        } else if let replyComment = comment {
            LocalyticsSession.shared().tagEvent("Submitted reply to comment")
            RKClient.sharedClient().submitComment(commentText, asReplyToComment: replyComment, completion: { (error) -> Void in
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                completion(error: error)
            })
        } else {
            completion(error: nil)
        }
    }
    
    func submitComment(commentText: String, onThingWithFullName: String, completion: ErrorCompletion) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        LocalyticsSession.shared().tagEvent("Submitted comment on link")
        
        RKClient.sharedClient().submitComment(commentText, onThingWithFullName: onThingWithFullName) { (error) -> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            completion(error: error)
        }
    }
    
    func searchForLinks(searchText: String, pagination: RKPagination?, completion: PaginationCompletion) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        RKClient.sharedClient().search(searchText, pagination: pagination) { (results, pagination, error) -> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            completion(pagination: pagination, results: results, error: error)
        }
    }
    
    func searchForLinksInSubreddit(subreddit: RKSubreddit, searchText: String, pagination: RKPagination?, completion: PaginationCompletion) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        RKClient.sharedClient().search(searchText, subreddit: subreddit, restrictSubreddit: true, pagination: pagination) { (results, pagination, error) -> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            completion(pagination: pagination, results: results, error: error)
        }
    }
    
    func submitLink(title: String, subredditName: String, text: String?, url: NSURL?, postType: PostType, captchaIdentifier: String?, captchaValue: String?, completion: ErrorCompletion) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        if postType == .Text {
            RKClient.sharedClient().submitSelfPostWithTitle(title, subredditName: subredditName, text: text, captchaIdentifier: captchaIdentifier, captchaValue: captchaValue, completion: { (error) -> Void in
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                completion(error: error)
            })
        } else {
            RKClient.sharedClient().submitLinkPostWithTitle(title, subredditName: subredditName, URL: url, captchaIdentifier: captchaIdentifier, captchaValue: captchaValue, completion: { (error) -> Void in
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                completion(error: error)
            })
        }
    }
    
    func newCaptchaIdWithCompletion(completion: PaginationCompletion) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        RKClient.sharedClient().newCaptchaIdentifierWithCompletion { (identifier, error) -> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            if identifier != nil {
                completion(pagination: nil, results: [identifier], error: error)
            } else {
                completion(pagination: nil, results: [], error: error)
            }
        }
    }
    
    func imageForCaptchaId(identifier: String, completion: PaginationCompletion) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        RKClient.sharedClient().imageForCaptchaIdentifier(identifier, completion: { (result, error) -> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            if result != nil {
                completion(pagination: nil, results: [result], error: error)
            } else {
                completion(pagination: nil, results: [], error: error)
            }
        })
    }
    
    func needsCaptchaWithCompletion(completion: BooleanCompletion) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        RKClient.sharedClient().needsCaptchaWithCompletion { (result, error) -> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            completion(result: result, error: error)
        }
    }
    
    func saveLink(link: RKLink, completion: ErrorCompletion) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        LocalyticsSession.shared().tagEvent("Saved link")
        
        RKClient.sharedClient().saveLink(link, completion: { (error) -> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            completion(error: error)
        })
    }
    
    func unSaveLink(link: RKLink, completion: ErrorCompletion) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        LocalyticsSession.shared().tagEvent("Unsaved link")
        
        RKClient.sharedClient().unsaveLink(link, completion: { (error) -> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            completion(error: error)
        })
    }
    
    func hideLink(link: RKLink, completion: ErrorCompletion) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        LocalyticsSession.shared().tagEvent("Hide link")
        
        RKClient.sharedClient().hideLink(link, completion: { (error) -> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            completion(error: error)
        })
    }
    
    func unHideLink(link: RKLink, completion: ErrorCompletion) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        LocalyticsSession.shared().tagEvent("Unhide link")
        
        RKClient.sharedClient().unhideLink(link, completion: { (error) -> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            completion(error: error)
        })
    }
    
    func searchForUser(username: String, completion: PaginationCompletion) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        RKClient.sharedClient().userWithUsername(username, completion: { (result, error) -> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            if let user = result as? RKUser {
                completion(pagination: nil, results: [user], error: error)
            } else {
                completion(pagination: nil, results: nil, error: error)
            }
        })
    }
    
    func linkWithFullName(link: RKLink, completion: PaginationCompletion) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        RKClient.sharedClient().linkWithFullName(link.fullName, completion: { (link, error) -> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            completion(pagination: nil, results: [link], error: error)
        })
    }
    
    func subredditsForCategory(category: String, completion: PaginationCompletion) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        RKClient.sharedClient().subredditsByTopic(category, completion: { (results, error) -> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            completion(pagination: nil, results: results, error: error)
        })
    }
    
    func readableContentWithURL(url: String, completion: ReadableCompletion) {
        var token = "86d3dcc05ff4444f692ab168d4543084911ac9d6"
        var url = "https://www.readability.com/api/content/v1/parser?url=\(url)&token=\(token)"
        var request = NSURLRequest(URL: NSURL(string: url)!)
        var queue = NSOperationQueue()
        NSURLConnection.sendAsynchronousRequest(request, queue: queue) { (response, data, error) -> Void in
            if let responseData = data {
                var jsonError: NSError?
                if let json = NSJSONSerialization.JSONObjectWithData(responseData,
                    options: nil,
                    error: &jsonError) as? [String : AnyObject] {
                    completion(content: ReadableContent(json: json), error: nil)
                }
            } else {
                completion(content: nil, error: error)
            }
        }
    }
}