//
//  User+Helpers.swift
//  MyReddit
//
//  Created by Nickolas Lanasa on 3/25/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation

extension User {
    func parseUser(user: AnyObject, password: String) {
        if let rkUser = user as? RKUser {
            if let username = rkUser.username {
                self.username = username
            }
            
            self.commentKarma = rkUser.commentKarma
            self.linkKarma = rkUser.linkKarma
            self.hasMail = rkUser.hasMail
            self.hasModeratorMail = rkUser.hasModeratorMail
            self.hasVerifiedEmailAddress = rkUser.hasVerifiedEmailAddress
            self.gold = rkUser.gold
            self.friend = rkUser.friend
            self.mod = rkUser.mod
            self.over18 = rkUser.over18
            self.created = rkUser.created
            
            self.password = password
        }
    }
}