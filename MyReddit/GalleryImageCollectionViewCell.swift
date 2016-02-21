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
    
    @IBOutlet weak var imageView: UIImageView!
    
    var imageURL: NSURL! {
        didSet {
            if self.imageURL.absoluteString.containsString("gif") {
                if self.imageURL.absoluteString.containsString("gifv") {
                    self.imageURL = NSURL(string: self.imageURL.absoluteString.stringByReplacingOccurrencesOfString("gifv", withString: "gif"))
                }
            }
            
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