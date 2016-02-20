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
        
        // Make sure that the cell does not have any previously added GADBanner view as it would be reused
        for view in self.contentView.subviews {
            if view.isKindOfClass(GADBannerView.self) {
                view.removeFromSuperview()
            }
        }
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