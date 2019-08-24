//
//  pic+CoreDataProperties.swift
//  NASA Space
//
//  Created by vikas on 24/08/19.
//  Copyright © 2019 project1. All rights reserved.
//

import CoreData


extension Picture {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Picture> {
        return NSFetchRequest<Picture>(entityName: self.entityName())
    }
    
    @NSManaged public var title: String?
    @NSManaged public var explanation: String?
    @NSManaged public var dateString: String?
    @NSManaged public var imageSet: String?
    @NSManaged public var hdURLString: String?
    @NSManaged public var copyright: String?
    @NSManaged public var mediaType: String?
    @NSManaged public var urlString: String?
}
