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
    @IBOutlet weak var titleTextView: SNTextView!
    
    override func viewDidLoad() {
        let request = NSURLRequest(URL: link.URL)
        self.webView.loadRequest(request)
        self.webView.backgroundColor = MyRedditDarkBackgroundColor
        self.webView.hidden = false
        
        var navLabel = UILabel(frame: CGRectZero)
        navLabel.text = self.link.URL.absoluteString
        navLabel.font = MyRedditTitleFont
        navLabel.minimumScaleFactor = 0.7
        navLabel.adjustsFontSizeToFitWidth = true
        navLabel.numberOfLines = 2
        navLabel.textColor = MyRedditLabelColor
        navLabel.textAlignment = .Left
        navLabel.sizeToFit()
        self.navigationItem.titleView = navLabel
        
        //self.titleTextView.expandable = true
        //self.titleTextView.addSeeMoreForText(self.link.title, maxHeight: 80)
        
        self.updateVoteButtons()
        
        self.navigationController?.navigationBar.tintColor = MyRedditLabelColor
        
        RedditSession.sharedSession.markLinkAsViewed(self.link, completion: { (error) -> () in
            
        })
        
        NSUserDefaults.standardUserDefaults().setObject(true, forKey: self.link.identifier)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Saved"), style: .Plain, target: self, action: "saveLink")
        
        if self.link.saved {
            self.navigationItem.rightBarButtonItem?.tintColor = MyRedditColor
        }
    }
    
    func saveLink() {
        RedditSession.sharedSession.saveLink(self.link, completion: { (error) -> () in
            if error != nil {
                UIAlertView(title: "Error!",
                    message: error!.localizedDescription,
                    delegate: self,
                    cancelButtonTitle: "Ok").show()
            } else {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Saved"), style: .Plain, target: self, action: "unSaveLink")
                self.navigationItem.rightBarButtonItem?.tintColor = MyRedditColor
            }
        })
    }
    
    func unSaveLink() {
        // unsave
        RedditSession.sharedSession.unSaveLink(self.link, completion: { (error) -> () in
            if error != nil {
                UIAlertView(title: "Error!",
                    message: error!.localizedDescription,
                    delegate: self,
                    cancelButtonTitle: "Ok").show()
            } else {
                 self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Saved"), style: .Plain, target: self, action: "saveLink")
                self.navigationItem.rightBarButtonItem?.tintColor = MyRedditLabelColor
            }
        })
    }
    
    func refreshLink() {
        RedditSession.sharedSession.linkWithFullName(self.link, completion: { (pagination, results, error) -> () in
            if let link = results?.first as? RKLink {
                self.link = link
                self.updateVoteButtons()
            }
        })
    }
    
    private func updateVoteButtons() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if self.link.upvoted() {
                self.upvoteButton.tintColor = MyRedditUpvoteColor
                self.downvoteButton.tintColor = MyRedditLabelColor
            } else if self.link.downvoted() {
                self.upvoteButton.tintColor = MyRedditLabelColor
                self.downvoteButton.tintColor = MyRedditDownvoteColor
            } else {
                self.upvoteButton.tintColor = MyRedditLabelColor
                self.downvoteButton.tintColor = MyRedditLabelColor
            }
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "CommentsSegue" {
            if let nav = segue.destinationViewController as? UINavigationController {
                if let controller = nav.viewControllers[0] as? CommentsViewController {
                    controller.link = link
                }
            }
        }
    }
    
    @IBAction func shareButtonTapped(sender: AnyObject) {
        let objectsToShare = [self.link.title, self.link.URL]
 
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        
        self.presentViewController(activityVC, animated: true, completion: nil)
    }
    
    @IBAction func downvoteButtonTapped(sender: AnyObject) {
        if !SettingsManager.defaultManager.purchased {
            self.performSegueWithIdentifier("PurchaseSegue", sender: self)
        } else {
            RedditSession.sharedSession.downvote(self.link, completion: { (error) -> () in
                self.refreshLink()
            })
        }
    }
    
    @IBAction func upvoteButtonTapped(sender: AnyObject) {
        if !SettingsManager.defaultManager.purchased {
            self.performSegueWithIdentifier("PurchaseSegue", sender: self)
        } else {
            RedditSession.sharedSession.upvote(self.link, completion: { (error) -> () in
                self.refreshLink()
            })
        }
    }
}