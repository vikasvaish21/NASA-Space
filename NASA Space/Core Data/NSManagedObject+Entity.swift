//
//  NSManagedObject+Entity.swift
//  NASA Space
//
//  Created by vikas on 21/08/19.
//  Copyright © 2019 project1. All rights reserved.
//

import Foundation
import  CoreData

extension NSManagedObject {
    class func entityName() -> String {
        return String(describing: self)
    }
}
