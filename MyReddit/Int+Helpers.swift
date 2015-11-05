//
//  Int+Helpers.swift
//  MyReddit
//
//  Created by Nick Lanasa on 3/26/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation

extension Int {
    func abbreviateNumber() -> String {
        var num: Double = Double(self)
        let sign = ((num < 0) ? "-" : "" )
        
        num = fabs(num)
        
        if (num < 1000.0){
            return "\(sign)\(Int(floor(num)))"
        }
        
        let exp: Int = Int(log10(num) / log10(1000))
        
        let units: [String] = ["K","M","G","T","P","E"]
        
        let roundedNum: Int = Int(floor(round(10 * num / pow(1000.0, Double(exp))) / 10))
        
        return "\(sign)\(roundedNum)\(units[exp-1])"
    }
}