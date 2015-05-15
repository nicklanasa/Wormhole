//
//  ProductGalleryController.swift
//  Hybris
//
//  Created by Nick Lanasa on 2/6/15.
//  Copyright (c) 2015 Siteworx. All rights reserved.
//

import Foundation
import UIKit

class GalleryController: UIViewController,
UIPageViewControllerDataSource,
UIPageViewControllerDelegate,
ImageViewControllerDelegate {
    
    @IBOutlet weak var upvoteButton: UIBarButtonItem!
    @IBOutlet weak var downvoteButton: UIBarButtonItem!
    @IBOutlet weak var pagesBarbutton: UIBarButtonItem!
    @IBOutlet weak var postTitleView: UIView!
    @IBOutlet weak var postTitleLabel: UILabel!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var seeMoreButton: UIButton!
    @IBOutlet weak var seeLessButton: UIButton!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    var optionsController: LinkShareOptionsViewController!
   
    var link: RKLink!
    
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
        LocalyticsSession.shared().tagScreen("Gallery")
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if self.postTitleView.frame.size.height > 35 {
            self.seeMoreButtonTapped(self)
        }
    }
    
    override func viewDidLoad() {
        self.updateVoteButtons()
        
        self.seeMoreButton.hidden = false
        self.seeLessButton.hidden = true
        
        self.postTitleView.backgroundColor = MyRedditBackgroundColor
        self.postTitleLabel.textColor = MyRedditLabelColor
        
        self.navigationController?.navigationBar.tintColor = MyRedditLabelColor
        
        RedditSession.sharedSession.markLinkAsViewed(self.link, completion: { (error) -> () in
            
        })
        
        NSUserDefaults.standardUserDefaults().setObject(true, forKey: self.link.identifier)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Saved"),
            style: .Plain,
            target: self,
            action: "saveLink")
        
        if self.link.saved {
            self.navigationItem.rightBarButtonItem?.tintColor = MyRedditColor
        }
        
        self.pagesBarbutton.title = "\(1)/\(self.images!.count)"
        
        self.configureNav()
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
        self.navigationItem.titleView = navLabel    }
    
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [AnyObject]) {
        if self.postTitleView.frame.size.height > 35 {
            self.seeMoreButtonTapped(self)
        }
    }
    
    var pageViewController: UIPageViewController! {
        didSet {
            self.pageViewController.dataSource = self
            self.pageViewController.delegate = self
            
            var controller = self.viewControllerAtIndex(0)!
            
            self.pageViewController.setViewControllers([controller],
                direction: UIPageViewControllerNavigationDirection.Forward,
                animated: false,
                completion: nil)
        }
    }
    
    var currentIndex: Int = 0
    
    var images: [AnyObject]?

    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        var controller = viewController as! ImageViewController
        var index: NSInteger = controller.pageIndex
        
        self.pagesBarbutton.title = "\(index+1)/\(self.images!.count)"
        
        if index == 0 || index == NSNotFound {
            return nil
        }
        
        index -= 1
        
        return self.viewControllerAtIndex(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        var controller = viewController as! ImageViewController
        var index: NSInteger = controller.pageIndex
        
        self.pagesBarbutton.title = "\(index+1)/\(self.images!.count)"
        
        if index == NSNotFound {
            return nil
        }
        
        index += 1
        
        if index == self.images?.count {
            return nil
        }
        
        
        return self.viewControllerAtIndex(index)
    }
    
    private func viewControllerAtIndex(index: NSInteger) -> ImageViewController? {
        var imagesCount = self.images?.count ?? 0
        if imagesCount == 0 || index >= imagesCount {
            return nil
        }
        
        var controller = self.storyboard?.instantiateViewControllerWithIdentifier("ImageViewController") as! ImageViewController
        controller.pageIndex = index
        if let imgImage = self.images?[index] as? IMGImage {
            controller.imageURL = imgImage.url
        } else if let imageURL = self.images?[index] as? NSURL {
            controller.imageURL = imageURL
        }
        
        controller.delegate = self
        
        return controller
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "embedPageController" {
            if let controller = segue.destinationViewController as? UIPageViewController {
                self.pageViewController = controller
            }
        } else if segue.identifier == "CommentsSegue" {
            if let nav = segue.destinationViewController as? UINavigationController {
                if let controller = nav.viewControllers[0] as? CommentsViewController {
                    controller.link = link
                }
            }
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

    @IBAction func shareButtonTapped(sender: AnyObject) {
        self.optionsController = LinkShareOptionsViewController(link: self.link)
        self.optionsController.barbuttonItem = self.shareButton
        self.optionsController.showInView(self.view)
        
        LocalyticsSession.shared().tagEvent("Gallery share button tapped")
    }
    
    @IBAction func downvoteButtonTapped(sender: AnyObject) {
        LocalyticsSession.shared().tagEvent("Gallery downvote button tapped")
        if !SettingsManager.defaultManager.purchased {
            self.performSegueWithIdentifier("PurchaseSegue", sender: self)
        } else {
            RedditSession.sharedSession.downvote(self.link, completion: { (error) -> () in
                if error != nil {
                    UIAlertView(title: "Error!",
                        message: error!.localizedDescription,
                        delegate: self,
                        cancelButtonTitle: "Ok").show()
                } else {
                    self.refreshLink()
                }
            })
        }
    }
    
    @IBAction func upvoteButtonTapped(sender: AnyObject) {
        LocalyticsSession.shared().tagEvent("Gallery upvote button tapped")
        if !SettingsManager.defaultManager.purchased {
            self.performSegueWithIdentifier("PurchaseSegue", sender: self)
        } else {
            RedditSession.sharedSession.upvote(self.link, completion: { (error) -> () in
                if error != nil {
                    UIAlertView(title: "Error!",
                        message: error!.localizedDescription,
                        delegate: self,
                        cancelButtonTitle: "Ok").show()
                } else {
                    self.refreshLink()
                }
            })
        }
    }
    
    func imageViewController(controller: ImageViewController, didTapImage image: UIImage?) {
        LocalyticsSession.shared().tagEvent("Gallery image tapped")
        if self.postTitleView.alpha == 0.0 {
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.postTitleView.alpha = 1.0
                self.toolbar.alpha = 1.0
            })
        } else {
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.postTitleView.alpha = 0.0
                self.toolbar.alpha = 0.0
            })
        }
    }
}