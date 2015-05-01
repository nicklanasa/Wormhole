//
//  LinkViewController.swift
//  MyReddit
//
//  Created by Nickolas Lanasa on 3/25/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation
import UIKit

class LinkViewController: UIViewController {
    
    var link: RKLink!
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var upvoteButton: UIBarButtonItem!
    @IBOutlet weak var downvoteButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        let request = NSURLRequest(URL: link.URL)
        self.webView.loadRequest(request)
        self.webView.backgroundColor = UIColor.whiteColor()
        self.webView.hidden = false
        self.navigationItem.title =  self.link.title
    }
    
    private func updateVoteButtons() {
        if self.link.upvoted() {
            self.upvoteButton.tintColor = MyRedditUpvoteColor
            self.downvoteButton.tintColor = UIColor.blackColor()
        } else if self.link.downvoted() {
            self.upvoteButton.tintColor = UIColor.blackColor()
            self.downvoteButton.tintColor = MyRedditDownvoteColor
        } else {
            self.upvoteButton.tintColor = UIColor.blackColor()
            self.downvoteButton.tintColor = UIColor.blackColor()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "CommentsSegue" {
            if let controller = segue.destinationViewController as? CommentsViewController {
                controller.link = link
            }
        }
    }
    
    @IBAction func shareButtonTapped(sender: AnyObject) {
        let objectsToShare = [self.link.title, self.link.URL]
 
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        
        self.presentViewController(activityVC, animated: true, completion: nil)
    }
    
    @IBAction func downvoteButtonTapped(sender: AnyObject) {
        RedditSession.sharedSession.downvote(self.link, completion: { (error) -> () in
            self.updateVoteButtons()
        })
    }
    
    @IBAction func upvoteButtonTapped(sender: AnyObject) {
        RedditSession.sharedSession.upvote(self.link, completion: { (error) -> () in
            self.updateVoteButtons()
        })
    }
}