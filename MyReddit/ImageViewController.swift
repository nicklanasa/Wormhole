//
//  ProductImagesPageViewController.swift
//  Hybris
//
//  Created by Nick Lanasa on 2/6/15.
//  Copyright (c) 2015 Siteworx. All rights reserved.
//

import Foundation
import UIKit

protocol ImageViewControllerDelegate {
    func imageViewController(controller: ImageViewController, didTapImage image: UIImage?)
}

class ImageViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var imageView: FLAnimatedImageView!
    @IBOutlet weak var scrollView: CenteringScrollView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var delegate: ImageViewControllerDelegate?
    
    var imageURL: NSURL!
    var pageIndex: Int!

    override func viewDidDisappear(animated: Bool) {
        self.imageView.backgroundColor = MyRedditBackgroundColor
        self.imageView.image = nil
        self.imageView.gestureRecognizers = []
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        LocalyticsSession.shared().tagScreen("GalleryImage")
        self.imageView.backgroundColor = MyRedditBackgroundColor
        self.view.backgroundColor = MyRedditBackgroundColor
    }
    
    func longHold() {
        if let selectedImage = self.imageView.image {
            self.presentViewController(UIAlertController.saveImageAlertController(selectedImage),
                animated: true,
                completion: nil)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        self.indicator.tintColor = MyRedditLabelColor
        self.indicator.startAnimating()
        self.imageView.contentMode = .ScaleAspectFit
        
        if self.imageURL.absoluteString.containsString("gif") {
            if self.imageURL.absoluteString.containsString("gifv") {
                self.imageURL = NSURL(string: self.imageURL.absoluteString.stringByReplacingOccurrencesOfString("gifv", withString: "gif"))
                
                let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
                dispatch_async(dispatch_get_global_queue(priority, 0)) {
                    let image = FLAnimatedImage(GIFData: NSData(contentsOfURL: self.imageURL))
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.imageView.animatedImage = image
                        self.indicator.stopAnimating()
                    })
                }
            }
        } else {
            self.imageView.sd_setImageWithURL(self.imageURL) { (image, error, cacheType, url) -> Void in
                if error != nil {
                    UIAlertView(title: "Error!",
                        message: "Unable to load image.",
                        delegate: self,
                        cancelButtonTitle: "Ok").show()
                } else {
                    self.imageView.image = image
                }
                self.indicator.stopAnimating()
            }
        }
        
        self.scrollView.contentSize = self.imageView.frame.size

        self.scrollView.minimumZoomScale = 1.0
        
        let tap = UITapGestureRecognizer(target: self, action: "imageViewTapped:")
        tap.numberOfTapsRequired = 1
        
        let longHold = UILongPressGestureRecognizer(target: self, action: "longHold")
        
        self.imageView.gestureRecognizers = [tap, longHold]
        self.view.gestureRecognizers = [tap]
    }

    func imageViewTapped(gesture: UIGestureRecognizer) {
        self.delegate?.imageViewController(self, didTapImage: self.imageView.image)
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}

class CenteringScrollView: UIScrollView {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let imageView = self.subviews[1] as? UIImageView {
            // center the image as it becomes smaller than the size of the screen
            let boundsSize = self.bounds.size
            
            // center horizontally
            if imageView.frame.size.width < boundsSize.width {
                imageView.frame.origin.x = (boundsSize.width - imageView.frame.size.width) / 2
            } else {
                imageView.frame.origin.x = 0
            }
            
            // center vertically
            if imageView.frame.size.height < boundsSize.height {
                // Minus some padding
                imageView.frame.origin.y = ((boundsSize.height - imageView.frame.size.height) / 2) - 20
            } else {
                imageView.frame.origin.y = 0
            }
        }
    }
}