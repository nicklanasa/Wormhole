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
        func floatToString(val: Float) -> String {
            var ret: NSString = NSString(format: "%.1f", val)
            
            var c = ret.characterAtIndex(ret.length - 1)
            
            if c == 46 {
                ret = ret.substringToIndex(ret.length - 1)
            }
            
            return ret as String
        }
        
        var abbrevNum = ""
        var num: Float = Float(self)
        
        if num >= 1000 {
            var abbrev = ["K","M","B"]
            
            for var i = abbrev.count-1; i >= 0; i-- {
                var sizeInt = pow(Double(10), Double((i+1)*3))
                var size = Float(sizeInt)
                
                if size <= num {
                    num = num/size
                    var numStr: String = floatToString(num)
                    if numStr.hasSuffix(".0") {
                        numStr = numStr.substringToIndex(advance(numStr.startIndex,count(numStr)-2))
                    }
                    
                    var suffix = abbrev[i]
                    abbrevNum = numStr+suffix
                }
            }
        } else {
            abbrevNum = "\(num)"
            if abbrevNum.hasSuffix(".0") {
                abbrevNum = abbrevNum.substringToIndex(advance(abbrevNum.startIndex, count(abbrevNum)-2))
            }
        }
        
        return abbrevNum
    }
}