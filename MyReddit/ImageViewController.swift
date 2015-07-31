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
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var delegate: ImageViewControllerDelegate?
    
    var imageURL: NSURL!
    var pageIndex: Int!

    override func viewDidDisappear(animated: Bool) {
        self.imageView.backgroundColor = MyRedditBackgroundColor
        self.imageView.image = nil
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        LocalyticsSession.shared().tagScreen("GalleryImage")
        self.imageView.backgroundColor = MyRedditBackgroundColor
        self.view.backgroundColor = MyRedditBackgroundColor
    }
    
    override func viewDidAppear(animated: Bool) {
        self.indicator.startAnimating()
        self.imageView.sd_setImageWithURL(self.imageURL, placeholderImage: nil, options: nil) { (image, error, cacheType, url) -> Void in
            if error != nil {
                UIAlertView(title: "Error!", message: "Unable to load image.", delegate: self, cancelButtonTitle: "Ok").show()
            } else {
                self.imageView.image = image
                self.imageView.center = self.scrollView.center
            }
            self.indicator.stopAnimating()
        }
        
        self.scrollView.contentSize = self.view.frame.size
        self.scrollView.minimumZoomScale = 0.5
        
        var tap = UITapGestureRecognizer(target: self, action: "imageViewTapped:")
        tap.numberOfTapsRequired = 1
        self.imageView.gestureRecognizers = [tap]
    }

    func imageViewTapped(gesture: UIGestureRecognizer) {
        self.delegate?.imageViewController(self, didTapImage: self.imageView.image)
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        var top: CGFloat = 0
        var left: CGFloat = 0
        
        if self.scrollView.contentSize.width < self.scrollView.bounds.size.width {
            left = (self.scrollView.bounds.size.width - self.scrollView.contentSize.width) * 0.5
        }
        
        if (self.scrollView.contentSize.height < self.scrollView.bounds.size.height) {
            top = (self.scrollView.bounds.size.height - self.scrollView.contentSize.height) * 0.5
        }
        
        self.scrollView.contentInset = UIEdgeInsetsMake(top, left, top, left)
    }
}