//
//  DownloadSessionDelegate.swift
//  MyReddit
//
//  Created by Nickolas Lanasa on 3/5/16.
//  Copyright © 2016 Nytek Production. All rights reserved.
//

import Foundation

typealias CompleteHandlerBlock = () -> ()
class DownloadSessionDelegate : NSObject, NSURLSessionDelegate, NSURLSessionDownloadDelegate {
    
    var handlerQueue: [String : CompleteHandlerBlock]!
    class var sharedInstance: DownloadSessionDelegate {
        struct Static {
            static var instance : DownloadSessionDelegate?
            static var token : dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = DownloadSessionDelegate()
            Static.instance!.handlerQueue = [String :
                CompleteHandlerBlock]()
        }
        
        return Static.instance!
    }
    
    //MARK: session delegate
    func URLSession(session: NSURLSession, didBecomeInvalidWithError
        error: NSError?) {
            print("session error: \(error?.localizedDescription).")
    }
    
    func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        completionHandler(
            NSURLSessionAuthChallengeDisposition.UseCredential,
            NSURLCredential(forTrust:
                challenge.protectionSpace.serverTrust!))
    }
    
    func URLSession(session: NSURLSession,
        downloadTask:NSURLSessionDownloadTask,
        didFinishDownloadingToURL location: NSURL) {
            print("session \(session) has finished the download task \(downloadTask) of URL \(location).")
    }
    
    func URLSessionDidFinishEventsForBackgroundURLSession(session:
        NSURLSession) {
            print("background session \(session) finished events.")
            
            if !session.configuration.identifier!.isEmpty {
                callCompletionHandlerForSession(
                    session.configuration.identifier)
            }
    }
    
    //MARK: completion handler
    func addCompletionHandler(handler: CompleteHandlerBlock,
        identifier: String) {
            handlerQueue[identifier] = handler
    }
    
    func callCompletionHandlerForSession(identifier: String!) {
        let handler : CompleteHandlerBlock =
        handlerQueue[identifier]!
        handlerQueue!.removeValueForKey(identifier)
        handler()
    }
}

