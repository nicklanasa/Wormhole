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
    
    var imageURL: NSURL!
    var pageIndex: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.sd_setImageWithURL(self.imageURL,
            placeholderImage: UIImage(named: "Placeholder"))
        self.view.backgroundColor = MyRedditBackgroundColor
        
        self.scrollView.contentSize = self.parentViewController!.view.frame.size
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}