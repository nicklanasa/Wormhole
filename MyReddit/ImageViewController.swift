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
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: CenteringScrollView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var delegate: ImageViewControllerDelegate?
    
    var imageURL: NSURL!
    var pageIndex: Int!
    var image: UIImage!

    override func viewDidDisappear(animated: Bool) {
        self.imageView.backgroundColor = MyRedditBackgroundColor
        self.imageView.gestureRecognizers = []
        self.imageView.image = nil
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
        self.indicator.startAnimating()
        self.imageView.contentMode = .ScaleAspectFit
        
        let tap = UITapGestureRecognizer(target: self, action: "imageViewTapped:")
        tap.numberOfTapsRequired = 1
        
        let longHold = UILongPressGestureRecognizer(target: self, action: "longHold")
        self.imageView.gestureRecognizers = [tap, longHold]
        self.view.gestureRecognizers = [tap]
        
        if self.imageURL != nil {
            self.imageView.sd_setImageWithURL(self.imageURL, completed: { (i, e, c, u) -> Void in
                if let resizedImage = i?.imageWithImage(i, toSize: self.imageView.frame.size) {
                    self.imageView.image = resizedImage
                } else {
                    self.imageView.image = UIImage(named: "Reddit")
                }
            })
        } else if image != nil {
            self.imageView.image = image
        }
        
        self.scrollView.minimumZoomScale = 1.0
        self.indicator.stopAnimating()
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