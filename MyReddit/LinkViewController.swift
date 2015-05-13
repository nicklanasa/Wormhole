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
    var optionsController: LinkShareOptionsViewController!
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var upvoteButton: UIBarButtonItem!
    @IBOutlet weak var downvoteButton: UIBarButtonItem!
    @IBOutlet weak var postTitleView: UIView!
    @IBOutlet weak var postTitleLabel: UILabel!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var seeMoreButton: UIButton!
    @IBOutlet weak var seeLessButton: UIButton!
    
    @IBAction func seeMoreButtonTapped(sender: AnyObject) {
        
        LocalyticsSession.shared().tagEvent("See more button toggled")
        
        var newOrigin: CGFloat!
        var newHeight: CGFloat!
        var newLabelHeight: CGFloat!
        var frame = self.postTitleView.frame
        var offsetToolBarHeight = self.toolbar.frame.height - 10
        
        if self.postTitleView.frame.size.height > 35 {
            offsetToolBarHeight = -(offsetToolBarHeight)
            newHeight = -self.postTitleLabel.frame.height
            newLabelHeight = 35
            newOrigin = -(self.postTitleLabel.frame.height - 35)
            self.seeMoreButton.hidden = false
            self.seeLessButton.hidden = true
        } else {
            newHeight = self.postTitleLabel.heightText()
            newLabelHeight = newHeight
            newOrigin = (newHeight - frame.height)
            
            self.seeMoreButton.hidden = true
            self.seeLessButton.hidden = false
        }
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.postTitleLabel.alpha = 0.0
            frame.origin.y -= newOrigin
            frame.size.height += (newHeight - offsetToolBarHeight)
            self.postTitleView.frame = frame
            
            print(frame)
            
            }) { (s) -> Void in
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    self.postTitleLabel.alpha = 1.0
                    var labelFrame = self.postTitleLabel.frame
                    labelFrame.size.height = newLabelHeight
                    self.postTitleLabel.frame = labelFrame
                    
                    }, completion: { (s) -> Void in
                })
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        LocalyticsSession.shared().tagScreen("Link")
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if self.postTitleView.frame.size.height > 35 {
            self.seeMoreButtonTapped(self)
        }
    }
    
    override func viewDidLoad() {
        
        self.seeMoreButton.hidden = false
        self.seeLessButton.hidden = true
        
        if let link = self.link {
            let request = NSURLRequest(URL: link.URL)
            self.webView.loadRequest(request)
            self.webView.backgroundColor = MyRedditDarkBackgroundColor
            self.webView.hidden = false
            
            self.updateVoteButtons()
            
            self.navigationController?.navigationBar.tintColor = MyRedditLabelColor
            
            RedditSession.sharedSession.markLinkAsViewed(self.link, completion: { (error) -> () in
                
            })
            
            NSUserDefaults.standardUserDefaults().setObject(true, forKey: self.link.identifier)
            
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Saved"), style: .Plain, target: self, action: "saveLink")
            
            if self.link.saved {
                self.navigationItem.rightBarButtonItem?.tintColor = MyRedditColor
            }
            
            self.configureNav()
        }
    }
    
    private func configureNav() {
        var infoString = NSMutableAttributedString(string:"\(self.link.title)\nby \(self.link.author) on /r/\(self.link.subreddit)")
        var attrs = [NSFontAttributeName : MyRedditSelfTextFont]
        var subAttrs = [NSFontAttributeName : MyRedditSelfTextFont, NSForegroundColorAttributeName : MyRedditColor]
        infoString.addAttributes(attrs, range: NSMakeRange(count("\(self.link.title)\nby "), count(link.author)))
        infoString.addAttributes(subAttrs, range: NSMakeRange(count("\(self.link.title)\nby \(self.link.author) on "), count("/r/\(link.subreddit)")))
        
        self.postTitleLabel.attributedText = infoString
        
        self.view.backgroundColor = MyRedditBackgroundColor
        
        var score = self.link.score.abbreviateNumber()
        var comments = Int(self.link.totalComments).abbreviateNumber()
        
        var titleString = NSMutableAttributedString(string: "\(score) | \(comments) comments")
        var fontAttrs = [NSFontAttributeName : MyRedditTitleFont]
        var scoreAttrs = [NSForegroundColorAttributeName : MyRedditUpvoteColor]
        var commentsAttr = [NSForegroundColorAttributeName : MyRedditColor]
        titleString.addAttributes(fontAttrs, range: NSMakeRange(0, count(titleString.string)))
        titleString.addAttributes(scoreAttrs, range: NSMakeRange(0, count(score)))
        titleString.addAttributes(commentsAttr, range: NSMakeRange(count("\(score) | "), count(comments)))
        
        var navLabel = UILabel(frame: CGRectZero)
        navLabel.attributedText = titleString
        navLabel.textAlignment = .Center
        navLabel.sizeToFit()
        self.navigationItem.titleView = navLabel
    }
    
    func saveLink() {
        RedditSession.sharedSession.saveLink(self.link, completion: { (error) -> () in
            if error != nil {
                UIAlertView(title: "Error!",
                    message: error!.localizedDescription,
                    delegate: self,
                    cancelButtonTitle: "Ok").show()
                
                LocalyticsSession.shared().tagEvent("Save failed")
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
                
                LocalyticsSession.shared().tagEvent("Unsave failed")
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
        if self.postTitleView.frame.size.height > 35 {
            self.seeMoreButtonTapped(self)
        }
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
        self.optionsController = LinkShareOptionsViewController(link: self.link)
        self.optionsController.showInView(self.view)
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