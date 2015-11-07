//
//  GalleryImageCollectionViewCell.swift
//  MyReddit
//
//  Created by Nickolas Lanasa on 7/25/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation
import UIKit

class GalleryImageCollectionViewCell: UICollectionViewCell {    
    @IBOutlet weak var imageView: FLAnimatedImageView!
    
    var imageURL: NSURL! {
        didSet {
            if self.imageURL.absoluteString.containsString("gif") {
                if self.imageURL.absoluteString.containsString("gifv") {
                    self.imageURL = NSURL(string: self.imageURL.absoluteString.stringByReplacingOccurrencesOfString("gifv", withString: "gif"))
                    let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
                    dispatch_async(dispatch_get_global_queue(priority, 0)) {
                        let image = FLAnimatedImage(GIFData: NSData(contentsOfURL: self.imageURL))
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.imageView.animatedImage = image
                        })
                    }
                }
            } else {
                self.imageView.sd_setImageWithURL(self.imageURL) { (image, error, cacheType, url) -> Void in
                    if error != nil {
                        self.imageView.image = UIImage(named: "noImage")
                    } else {
                        self.imageView.image = image
                    }
                }
            }
        }
    }
}