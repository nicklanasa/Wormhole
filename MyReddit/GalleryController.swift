//
//  ProductGalleryController.swift
//  Hybris
//
//  Created by Nick Lanasa on 2/6/15.
//  Copyright (c) 2015 Siteworx. All rights reserved.
//

import Foundation
import UIKit

class GalleryController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var upvoteButton: UIBarButtonItem!
    @IBOutlet weak var downvoteButton: UIBarButtonItem!
    @IBOutlet weak var pagesBarbutton: UIBarButtonItem!
   
    var link: RKLink!
    
    
    override func viewDidLoad() {
        self.updateVoteButtons()
        
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
        self.navigationItem.title = self.link.title
        
        self.view.backgroundColor = MyRedditBackgroundColor
        self.pageControl.hidden = true
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
            
            self.pageControl.numberOfPages = self.images?.count ?? 0
        }
    }
    
    var currentIndex: Int = 0
    
    var images: [AnyObject]?

    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        var controller = viewController as! ImageViewController
        var index: NSInteger = controller.pageIndex
        
        self.pageControl.currentPage = index
        
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
        
        self.pageControl.currentPage = index
        
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
        let objectsToShare = [self.link.title, self.link.URL]
        
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        
        self.presentViewController(activityVC, animated: true, completion: nil)
    }
    
    @IBAction func downvoteButtonTapped(sender: AnyObject) {
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
}