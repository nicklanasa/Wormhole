//
//  SuggestedLink.swift
//  MyReddit
//
//  Created by Nickolas Lanasa on 2/20/16.
//  Copyright © 2016 Nytek Production. All rights reserved.
//

import Foundation

class SuggestedLink: NSObject {
    var adUnitID: String!
    
    convenience init(adUnitID: String) {
        self.init()
        self.adUnitID = adUnitID
    }
    
    class func removeAdsLink() -> SuggestedLink {
        return SuggestedLink(adUnitID: "ca-app-pub-4512025392063519/5000635786")
    }
    
    class func bannerAdLink() -> SuggestedLink {
        return SuggestedLink(adUnitID: "ca-app-pub-4512025392063519/5619854982")
    }
}
