//
//  LinkViewController.swift
//  MyReddit
//
//  Created by Nickolas Lanasa on 3/25/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation
import UIKit

class LinkViewController: RootViewController, UITextViewDelegate {
    
    var link: RKLink!
    var optionsController: LinkShareOptionsViewController!
    
    var readerBarButtonItem: UIBarButtonItem!
    var saveButtonItem: UIBarButtonItem!
    
    var content: ReadableContent! {
        didSet {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if self.content.content == nil {
                    UIAlertView(title: "Error!",
                        message: "Unable to get readable content!",
                        delegate: self,
                        cancelButtonTitle: "OK").show()
                    self.view.insertSubview(self.textView, belowSubview: self.webView)
                    self.setupWebView()
                } else {
                    self.view.insertSubview(self.webView, belowSubview: self.textView)
                    self.webView.hidden = true
                    self.textView.hidden = false
                    
                    self.textView.attributedText = self.content!.content.html2AttributedString
                    
                    self.readerBarButtonItem = UIBarButtonItem(image: UIImage(named: "ReaderSelected"),
                        style: .Plain,
                        target: self,
                        action: "hideReader")
                    
                    self.navigationItem.rightBarButtonItems = [self.readerBarButtonItem, self.saveButtonItem]
                }
                
                self.preferredAppearance()
            })
        }
    }
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var upvoteButton: UIBarButtonItem!
    @IBOutlet weak var downvoteButton: UIBarButtonItem!
    @IBOutlet weak var postTitleView: UIView!
    @IBOutlet weak var postTitleLabel: UILabel!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var seeMoreButton: UIButton!
    @IBOutlet weak var seeLessButton: UIButton!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var textView: UITextView!
    
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
        self.navigationController?.setToolbarHidden(true, animated: true)
        
        self.preferredAppearance()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if self.postTitleView.frame.size.height > 35 {
            self.seeMoreButtonTapped(self)
        }
        
        self.navigationController?.setToolbarHidden(false, animated: true)
    }
    
    override func viewDidLoad() {
        
        self.seeMoreButton.hidden = false
        self.seeLessButton.hidden = true
        
        self.textView.delegate = self
        
        self.configureNav()
        
        if SettingsManager.defaultManager.valueForSetting(.DefaultToReaderMode) {
            self.showReader()
        } else {
            self.setupWebView()
        }
        
        RedditSession.sharedSession.markLinkAsViewed(self.link,
            completion: { (error) -> () in })
        
        self.preferredAppearance()
        
        self.readerBarButtonItem = UIBarButtonItem(image: UIImage(named: "Reader"),
            style: .Plain,
            target: self,
            action: "showReader")
        
        self.saveButtonItem = UIBarButtonItem(image: UIImage(named: "Saved"),
            style: .Plain,
            target: self,
            action: "saveLink")
        
        self.navigationItem.rightBarButtonItems = [self.readerBarButtonItem, self.saveButtonItem]
    }
    
    private func setupWebView() {
        
        self.view.insertSubview(self.textView, belowSubview: self.webView)
        self.webView.hidden = false
        self.textView.hidden = true
        
        if let link = self.link {
            let request = NSURLRequest(URL: link.URL)
            self.webView.loadRequest(request)
            self.webView.hidden = false
            
            self.updateVoteButtons()
            
            NSUserDefaults.standardUserDefaults().setObject(true,
                forKey: self.link.identifier)
        }
    }
    
    private func configureNav() {
        let infoString = NSMutableAttributedString(string:"\(self.link.title)\nby \(self.link.author) on /r/\(self.link.subreddit)")
        let attrs = [NSFontAttributeName : MyRedditSelfTextFont]
        let subAttrs = [NSFontAttributeName : MyRedditSelfTextFont, NSForegroundColorAttributeName : MyRedditColor]
        infoString.addAttributes(attrs, range: NSMakeRange("\(self.link.title)\nby ".characters.count, link.author.characters.count))
        infoString.addAttributes(subAttrs, range: NSMakeRange("\(self.link.title)\nby \(self.link.author) on ".characters.count, "/r/\(link.subreddit)".characters.count))
        
        self.postTitleLabel.attributedText = infoString
        
        let score = self.link.score.abbreviateNumber()
        let comments = self.link.totalComments
        
        let titleString = NSMutableAttributedString(string: "\(score)\n\(comments) comments")
        let fontAttrs = [NSFontAttributeName : MyRedditCommentTextFont, NSForegroundColorAttributeName : MyRedditLabelColor]
        let scoreAttrs = [NSForegroundColorAttributeName : MyRedditUpvoteColor]
        titleString.addAttributes(fontAttrs, range: NSMakeRange(0, titleString.string.characters.count))
        titleString.addAttributes(scoreAttrs, range: NSMakeRange(0, score.characters.count))
        
        let navLabel = UILabel(frame: CGRectZero)
        navLabel.attributedText = titleString
        navLabel.textAlignment = .Center
        navLabel.numberOfLines = 2
        navLabel.sizeToFit()
        self.navigationItem.titleView = navLabel
    }
    
    func showReader() {
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        RedditSession.sharedSession.readableContentWithURL(self.link.URL.absoluteString, completion: { (content, error) -> () in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                hud.hide(true)
                if error != nil {
                    UIAlertView(title: "Error!",
                        message: "Unable to get readable content!",
                        delegate: self,
                        cancelButtonTitle: "OK").show()
                    self.setupWebView()
                } else {
                    self.content = content
                }
            })
        })
    }
    
    func hideReader() {
        self.readerBarButtonItem = UIBarButtonItem(image: UIImage(named: "Reader"),
            style: .Plain,
            target: self,
            action: "showReader")
        self.navigationItem.rightBarButtonItems = [self.readerBarButtonItem, self.saveButtonItem]
        self.setupWebView()
    }
    
    func saveLink() {
        if !SettingsManager.defaultManager.purchased {
            self.performSegueWithIdentifier("PurchaseSegue", sender: self)
        } else {
            RedditSession.sharedSession.saveLink(self.link, completion: { (error) -> () in
                if error != nil {
                    UIAlertView(title: "Error!",
                        message: error!.localizedDescription,
                        delegate: self,
                        cancelButtonTitle: "Ok").show()
                    
                    LocalyticsSession.shared().tagEvent("Save failed")
                } else {
                    self.saveButtonItem = UIBarButtonItem(image: UIImage(named: "SavedSelected"),
                        style: .Plain,
                        target: self,
                        action: "unSaveLink")
                    self.navigationItem.rightBarButtonItems = [self.readerBarButtonItem, self.saveButtonItem]
                }
            })
        }
    }
    
    func unSaveLink() {
        // unsave
        if !SettingsManager.defaultManager.purchased {
            self.performSegueWithIdentifier("PurchaseSegue", sender: self)
        } else {
            RedditSession.sharedSession.unSaveLink(self.link, completion: { (error) -> () in
                if error != nil {
                    UIAlertView(title: "Error!",
                        message: error!.localizedDescription,
                        delegate: self,
                        cancelButtonTitle: "Ok").show()
                    
                    LocalyticsSession.shared().tagEvent("Unsave failed")
                } else {
                    self.saveButtonItem = UIBarButtonItem(image: UIImage(named: "Saved"),
                        style: .Plain,
                        target: self,
                        action: "saveLink")
                    self.navigationItem.rightBarButtonItems = [self.readerBarButtonItem, self.saveButtonItem]
                }
            })
        }
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
            self.upvoteButton.image = UIImage(named: "UpSelected")
            self.downvoteButton.image = UIImage(named: "Down")
        } else if self.link.downvoted() {
            self.upvoteButton.image = UIImage(named: "Up")
            self.downvoteButton.image = UIImage(named: "DownSelected")
        } else {
            self.upvoteButton.image = UIImage(named: "Up")
            self.downvoteButton.image = UIImage(named: "Down")
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "CommentsSegue" {
            if let controller = segue.destinationViewController as? CommentsViewController {
                controller.link = self.link
            }
        } else if segue.identifier == "WebSegue" {
            if let nav = segue.destinationViewController as? UINavigationController {
                if let controller = nav.viewControllers[0] as? WebViewController {
                    if let url = sender as? NSURL {
                        controller.url = url
                    }
                }
            }
        }
    }
    
    @IBAction func shareButtonTapped(sender: AnyObject) {
        self.optionsController = LinkShareOptionsViewController(link: self.link)
        self.optionsController.barbuttonItem = self.shareButton
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
    
    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        self.performSegueWithIdentifier("WebSegue", sender: URL)
        return false
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        self.textView.text = ""
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        if let content = self.content.content {
            let mutableString = content.html2AttributedString
            self.textView.attributedText = mutableString
            self.preferredAppearance()
        }
    }
    
    override func preferredAppearance() {
        
        self.navigationController?.navigationBar.backgroundColor = MyRedditBackgroundColor
        self.navigationController?.navigationBar.barTintColor = MyRedditBackgroundColor
        self.navigationController?.navigationBar.tintColor = MyRedditLabelColor
        
        self.toolbar.barTintColor = MyRedditBackgroundColor
        self.toolbar.backgroundColor = MyRedditBackgroundColor
        self.toolbar.tintColor = MyRedditLabelColor
        
        self.textView.textColor = MyRedditLabelColor
        self.textView.font = MyRedditSelfTextFont
        
        self.postTitleView.backgroundColor = MyRedditBackgroundColor
        self.postTitleLabel.textColor = MyRedditLabelColor
        
        self.view.backgroundColor = MyRedditBackgroundColor
        
        self.webView.backgroundColor = MyRedditDarkBackgroundColor
                
        if self.link.saved {
            self.navigationItem.rightBarButtonItem?.tintColor = MyRedditColor
        }
        
        self.configureNav()
    }
}