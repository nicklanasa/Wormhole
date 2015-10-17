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
ImageViewControllerDelegate,
UICollectionViewDataSource,
UICollectionViewDelegate {
    
    @IBOutlet weak var upvoteButton: UIBarButtonItem!
    @IBOutlet weak var downvoteButton: UIBarButtonItem!
    @IBOutlet weak var pagesBarbutton: UIBarButtonItem!
    @IBOutlet weak var postTitleView: UIView!
    @IBOutlet weak var postTitleLabel: UILabel!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var seeMoreButton: UIButton!
    @IBOutlet weak var seeLessButton: UIButton!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var containerView: UIView!
    
    var optionsController: LinkShareOptionsViewController!
    var photosBarButtonItem: UIBarButtonItem!
    var saveButtonItem: UIBarButtonItem!
   
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
        self.navigationController?.setToolbarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if self.postTitleView.frame.size.height > 35 {
            self.seeMoreButtonTapped(self)
        }
        
        self.navigationController?.setToolbarHidden(false, animated: true)
    }
    
    override func viewDidLoad() {
        
        self.collectionView.alpha = 0.0
        self.collectionView.reloadData()
        
        self.updateVoteButtons()
        
        self.seeMoreButton.hidden = false
        self.seeLessButton.hidden = true
    
        self.view.backgroundColor = MyRedditBackgroundColor
        self.collectionView.backgroundColor = MyRedditBackgroundColor
        self.containerView.backgroundColor = MyRedditBackgroundColor
        self.postTitleView.backgroundColor = MyRedditBackgroundColor
        self.postTitleLabel.textColor = MyRedditLabelColor
        
        self.navigationController?.navigationBar.tintColor = MyRedditLabelColor
        
        RedditSession.sharedSession.markLinkAsViewed(self.link,
            completion: { (error) -> () in })
        
        NSUserDefaults.standardUserDefaults().setObject(true, forKey: self.link.identifier)
        
        self.photosBarButtonItem = UIBarButtonItem(image: UIImage(named: "Grid"),
            style: .Plain,
            target: self,
            action: "showGrid")
        
        self.saveButtonItem = UIBarButtonItem(image: UIImage(named: "Saved"),
            style: .Plain,
            target: self,
            action: "saveLink")
        
        self.navigationItem.rightBarButtonItems = [self.photosBarButtonItem, self.saveButtonItem]
        
        if self.link.saved {
            self.navigationItem.rightBarButtonItem?.tintColor = MyRedditColor
        }
        
        self.pagesBarbutton.title = "\(1)/\(self.images!.count)"
        
        self.configureNav()
    }
    
    func showGrid() {
        if self.collectionView.alpha == 0.0 {
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.containerView.alpha = 0.0
            }, completion: { (s) -> Void in
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    self.collectionView.alpha = 1.0
                    if self.postTitleView.alpha == 0.0 {
                        UIView.animateWithDuration(0.3, animations: { () -> Void in
                            self.postTitleView.alpha = 1.0
                            self.toolbar.alpha = 1.0
                        })
                    }
                })
            })
            
            self.photosBarButtonItem = UIBarButtonItem(image: UIImage(named: "GridSelected"),
                style: .Plain,
                target: self,
                action: "showGrid")
            self.navigationItem.rightBarButtonItems = [self.photosBarButtonItem, self.saveButtonItem]
        } else {
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.collectionView.alpha = 0.0
            }, completion: { (s) -> Void in
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    self.containerView.alpha = 1.0
                })
            })
            
            self.photosBarButtonItem = UIBarButtonItem(image: UIImage(named: "Grid"),
                style: .Plain,
                target: self,
                action: "showGrid")
            self.navigationItem.rightBarButtonItems = [self.photosBarButtonItem, self.saveButtonItem]
        }
    }
    
    private func configureNav() {
        
        let infoString = NSMutableAttributedString(string:"\(self.link.title)\nby \(self.link.author) on /r/\(self.link.subreddit)")
        let attrs = [NSFontAttributeName : MyRedditSelfTextFont]
        let subAttrs = [NSFontAttributeName : MyRedditSelfTextFont, NSForegroundColorAttributeName : MyRedditColor]
        infoString.addAttributes(attrs, range: NSMakeRange("\(self.link.title)\nby ".characters.count, link.author.characters.count))
        infoString.addAttributes(subAttrs, range: NSMakeRange("\(self.link.title)\nby \(self.link.author) on ".characters.count, "/r/\(link.subreddit)".characters.count))
        
        self.postTitleLabel.attributedText = infoString
        
        self.view.backgroundColor = MyRedditBackgroundColor
        
        let score = self.link.score.abbreviateNumber()
        let comments = self.link.totalComments
        
        let titleString = NSMutableAttributedString(string: "\(score)\n\(comments) comments")
        let fontAttrs = [NSFontAttributeName : MyRedditCommentTextFont,
            NSForegroundColorAttributeName : MyRedditLabelColor]
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
    
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
        if self.postTitleView.frame.size.height > 35 {
            self.seeMoreButtonTapped(self)
        }
    }
    
    var pageViewController: UIPageViewController! {
        didSet {
            self.pageViewController.dataSource = self
            self.pageViewController.delegate = self
            
            let controller = self.viewControllerAtIndex(0)!
            
            self.pageViewController.setViewControllers([controller],
                direction: UIPageViewControllerNavigationDirection.Forward,
                animated: false,
                completion: nil)
        }
    }
    
    var currentIndex: Int = 0
    
    var images: [AnyObject]?

    func pageViewController(pageViewController: UIPageViewController,
        viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let controller = viewController as! ImageViewController
        var index: NSInteger = controller.pageIndex
        
        self.pagesBarbutton.title = "\(index+1)/\(self.images!.count)"
        
        if index == 0 || index == NSNotFound {
            return nil
        }
        
        index -= 1
        
        return self.viewControllerAtIndex(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController,
        viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let controller = viewController as! ImageViewController
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
        let imagesCount = self.images?.count ?? 0
        if imagesCount == 0 || index >= imagesCount {
            return nil
        }
        
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("ImageViewController") as! ImageViewController
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
            if let controller = segue.destinationViewController as? CommentsViewController {
                controller.link = self.link
            }
        }
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
                } else {
                    self.saveButtonItem = UIBarButtonItem(image: UIImage(named: "SavedSelected"), style: .Plain, target: self, action: "unSaveLink")
                    self.navigationItem.rightBarButtonItems = [self.photosBarButtonItem, self.saveButtonItem]
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
                } else {
                    self.saveButtonItem = UIBarButtonItem(image: UIImage(named: "Saved"), style: .Plain, target: self, action: "saveLink")
                    self.navigationItem.rightBarButtonItems = [self.photosBarButtonItem, self.saveButtonItem]
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
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
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
        })
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
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images?.count ?? 0
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ImageCell",
            forIndexPath: indexPath) as! GalleryImageCollectionViewCell
        if let imgImage = self.images?[indexPath.row] as? IMGImage {
            let thumbnailImageURL = imgImage.URLWithSize(IMGSize(rawValue: IMGSize.MediumThumbnailSize.rawValue)!)
            cell.imageView.sd_setImageWithURL(thumbnailImageURL)
        } else if let imageURL = self.images?[indexPath.row] as? NSURL {
            cell.imageView.sd_setImageWithURL(imageURL)
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.collectionView.alpha = 0.0
            
        }) { (s) -> Void in
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.containerView.alpha = 1.0
        
                self.pageViewController.setViewControllers([self.viewControllerAtIndex(indexPath.row)!],
                    direction: UIPageViewControllerNavigationDirection.Forward,
                    animated: false,
                    completion: nil)
            })
        }
    }
}