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
        let stringURL = "http://www.reddit.com/reddits/search.json?q=\(name.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()))"
        let url = NSURL(string: stringURL)!
        let request = NSURLRequest(URL: url)
        let queue = NSOperationQueue()
        NSURLConnection.cancelPreviousPerformRequestsWithTarget(self)
        NSURLConnection.sendAsynchronousRequest(request, queue: queue) { (response, data, error) -> Void in
            if data != nil && error == nil {
                if data!.length > 0 {
                    do {
                        let responseDict = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
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
                    } catch {
                        completion(results: nil, error: nil)
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