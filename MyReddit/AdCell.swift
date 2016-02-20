//
//  AdCell.swift
//  MyReddit
//
//  Created by Nickolas Lanasa on 2/20/16.
//  Copyright © 2016 Nytek Production. All rights reserved.
//

import Foundation
import UIKit
import GoogleMobileAds

class AdCell: UITableViewCell {
    
    @IBOutlet weak var bannerView: GADBannerView!

    var link: SuggestedLink!
        
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}