//
//  Picture.swift
//  NASA Space
//
//  Created by vikas on 23/08/19.
//  Copyright © 2019 project1. All rights reserved.
//
import Foundation
import CoreData
import UIKit


@objc(Picture)
public class Picture: NSManagedObject {
    convenience init(dictionary: [String: AnyObject], context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: type(of: self).entityName(), in: context) {
            
            self.init(entity: ent, insertInto: context)
            self.title = dictionary[NasaApi.ResponseKeys.Title] as? String
            self.explanation = dictionary[NasaApi.ResponseKeys.Explanation] as? String
            self.dateString = dictionary[NasaApi.ResponseKeys.Date] as? String
            self.urlString = dictionary[NasaApi.ResponseKeys.URL] as? String
            self.hdURLString = dictionary[NasaApi.ResponseKeys.HDURL] as? String
            self.copyright = dictionary[NasaApi.ResponseKeys.Copyright] as? String
            self.mediaType = dictionary[NasaApi.ResponseKeys.MediaType] as? String
            if let key = dictionary["resource"] {
                self.imageSet = key[NasaApi.ResponseKeys.MediaType] as? String
            }
        } else {
            fatalError("Unable to find Entity Name")
        }
    }
}
