//
//  ProductImagesPageViewController.swift
//  Hybris
//
//  Created by Nick Lanasa on 2/6/15.
//  Copyright (c) 2015 Siteworx. All rights reserved.
//

import Foundation
import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var imageURL: NSURL!
    var pageIndex: Int!
    
    override func viewDidAppear(animated: Bool) {
        self.imageView.clipsToBounds = true
        self.indicator.startAnimating()
        self.imageView.sd_setImageWithURL(self.imageURL, placeholderImage: nil, options: nil) { (image, error, cacheType, url) -> Void in
            self.indicator.stopAnimating()
            self.imageView.image = image
        }
        
        self.view.backgroundColor = MyRedditBackgroundColor
        
        self.scrollView.contentSize = self.parentViewController!.view.frame.size
    }

    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}