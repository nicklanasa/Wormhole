//
//  SplitViewController+Helpers.swift
//  MyReddit
//
//  Created by Nickolas Lanasa on 10/17/15.
//  Copyright © 2015 Nytek Production. All rights reserved.
//

import UIKit

extension UISplitViewController {
    func toggleMaster() {
        let barButtonItem = self.displayModeButtonItem()
        UIApplication.sharedApplication().sendAction(barButtonItem.action,
            to: barButtonItem.target,
            from: nil,
            forEvent: nil)
    }
}
