//
//  NasaApiComponents.swift
//  NASA Space
//
//  Created by vikas on 21/08/19.
//  Copyright © 2019 project1. All rights reserved.
//

import Foundation
import CoreData
import UIKit
extension NasaApi{
    var sharedStack: CoreDataStackManager {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.dataStack
    }
    
    var sharedContext: NSManagedObjectContext{
        return sharedStack.context
    }
    
    func pictureFromResults(results: [[String:AnyObject]]) {
        for result in results{
            if (result[ResponseKeys.MediaType] as! String == "image"){
                let picture = Picture(dictionary: result,context : self.sharedContext)
                self.sharedContext.insert(picture)
                self.sharedStack.save()
                
        }
    }
}
    
    // NB: Concept Tags are currently turned off in NASA's service
    func getPhotos(startDate: Date, endDate: Date, conceptTags: Bool = false, completionHandlerForPictures: @escaping (_ success: Bool, _ error: Error?) -> Void){
        let startDateString = format(date: startDate)
        let endDateString = format(date: endDate)
        let conceptTagsValueString = conceptTags ? "True" : "False"
        let parameters = [URLKeys.StartDate: startDateString as AnyObject,
                          URLKeys.EndDate: endDateString as AnyObject,
                          URLKeys.ConceptTag: conceptTagsValueString as AnyObject]
        let _ = taskForGetMethod(parameters: parameters, parseJSON: true) { (result, error) in
            if (error != nil) {
                completionHandlerForPictures(false, error)
            } else {
                //                print("\(String(describing: jsonArray)), \(String(describing: error))")
                if let results = result as? [[String: AnyObject]] {
                    self.pictureFromResults(results: results)
                    completionHandlerForPictures(true, nil)
                }
                else {
                    completionHandlerForPictures(false, error)
                }
            }
        }
    }
    
    // Format dates to the String value required for the APOD API
    private func format(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        return dateFormatter.string(from: date)
    }
}
