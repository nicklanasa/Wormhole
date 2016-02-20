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

    var link: SuggestedLink!
        
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    class func cellBannerView(rootVC: UIViewController, frame: CGRect) -> GADBannerView {
        
        let bannerView = GADBannerView()
        
        bannerView.frame = frame
        
        bannerView.rootViewController = rootVC
        
        bannerView.adUnitID = "ca-app-pub-4512025392063519/5619854982"
        
        bannerView.adSize = kGADAdSizeBanner
        
        return bannerView
        
    }
    
}