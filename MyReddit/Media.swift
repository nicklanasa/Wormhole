//
//  Media.swift
//  MyReddit
//
//  Created by Nick Lanasa on 3/25/15.
//  Copyright (c) 2015 Nytek Production. All rights reserved.
//

import Foundation
import CoreData

@objc(Media)
class Media: NSManagedObject {

    @NSManaged var authorName: String
    @NSManaged var authorURL: String
    @NSManaged var height: NSNumber
    @NSManaged var providerDescription: String
    @NSManaged var providerTitle: String
    @NSManaged var providerURL: String
    @NSManaged var thumbnailHeight: NSNumber
    @NSManaged var thumbnailURL: String
    @NSManaged var thumbnailWidth: NSNumber
    @NSManaged var type: String
    @NSManaged var width: NSNumber
    @NSManaged var link: Link

}
