//
//  RKClient+Search.swift
//  MyReddit
//
//  Created by Nick Lanasa on 5/1/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation

extension RKClient {
    
    typealias ResultsCompletion = (results: [AnyObject]?, error: NSError?) -> ()
    
    func searchForSubreddit(name: String, completion: ResultsCompletion) {
        var stringURL = "http://www.reddit.com/reddits/search.json?q=\(name.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()))"
        var url = NSURL(string: stringURL)!
        var request = NSURLRequest(URL: url)
        var queue = NSOperationQueue()
        NSURLConnection.cancelPreviousPerformRequestsWithTarget(self)
        NSURLConnection.sendAsynchronousRequest(request, queue: queue) { (response, data, error) -> Void in
            if data != nil && error == nil {
                if data.length > 0 {
                    var dictError: NSError?
                    
                    if let responseDict = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: &dictError) as? [String:AnyObject] {
                        if let dataDict = responseDict["data"] as? [String:AnyObject] {
                            if let children = dataDict["children"] as? [[String:AnyObject]] {
                                
                                var results = Array<AnyObject>()
                                
                                for subreddit in children {
                                    if let subredditData = subreddit["data"] as? [String:AnyObject] {
                                        results.append(subredditData)
                                    }
                                }
                                
                                completion(results: results, error: error)
                            }
                        }
                    } else {
                        completion(results: nil, error: dictError)
                    }
                    
                } else {
                    completion(results: nil, error: error)
                }
            } else {
                completion(results: nil, error: error)
            }
        }
    }
}