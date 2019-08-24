//
//  CoreDataStackManager.swift
//  NASA Space
//
//  Created by vikas on 21/08/19.
//  Copyright © 2019 project1. All rights reserved.
//

import Foundation
import CoreData


//Mark: - Properties
struct CoreDataStackManager {
    fileprivate let model: NSManagedObjectModel
    fileprivate let coordinator : NSPersistentStoreCoordinator
    fileprivate let modelURL : URL
    fileprivate let dbURL : URL
    fileprivate let persistentContext : NSManagedObjectContext
    fileprivate let backgroundContext : NSManagedObjectContext
    let context : NSManagedObjectContext
    
    
    // Mark: - Initializers
    init?(modelName: String){
        
        // Assumes the model is in the main bundle
        guard let modelUrl = Bundle.main.url(forResource: modelName, withExtension: "momd")
            else{
                print("Unabled to find \(modelName)in the main bundle")
                return nil}
            self.modelURL = modelUrl
        
        // Try to Create the model from the URl
        guard let model = NSManagedObjectModel(contentsOf: modelUrl) else{
            print("unable to create a model from \(modelUrl)")
            return nil
        }
        self.model = model
        
        
        //Create the Store Coordinator
        coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        
        //Create a persistanceContext (private Queue and the child one (main queue)
        // create a context and add connect it to the coordinator
        persistentContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        persistentContext.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
        persistentContext.persistentStoreCoordinator = coordinator
        context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.parent = persistentContext
        
        //Create a background context child of main context
        backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        backgroundContext.parent = context
        
        //Add a SQLite store located in the document folder
        let fm = FileManager.default
        
        guard let docUrl = fm.urls(for: .documentDirectory, in: .userDomainMask).first else{
            print("Unable to reach the documents folder")
            return nil
        }
        self.dbURL = docUrl.appendingPathComponent("model.sqlite")
        
        do{
            try addStoreCoordinator(NSSQLiteStoreType, configuration: nil,storeURL: dbURL,options: nil)
        }
        catch {
            print("unable to add store at \(dbURL)")
        }
    }
    
    // Marks: - Utilities
    func addStoreCoordinator(_ storeType:String,configuration: String?,storeURL:URL,options: [AnyHashable: Any]?)  throws{
        try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: dbURL, options: nil)
    }
}

//Mark: - Removing data
extension CoreDataStackManager{
    func dropAllData() throws{
        // delete all the objects in the db .this wonn,t delete the files, it will
        // just leave empty tables
        try coordinator.destroyPersistentStore(at: dbURL, ofType: NSSQLiteStoreType, options: nil)
        try addStoreCoordinator(NSSQLiteStoreType, configuration: nil, storeURL: dbURL, options: nil)
    }
}
// Mark: - Batch processing in the background
extension CoreDataStackManager{
    typealias Batch = (_ workerContext: NSManagedObjectContext) -> ()
    
    func performBackgroundBatchOperation(_ batch: @escaping Batch){
        backgroundContext.perform(){
        batch(self.backgroundContext)
        // Save it to the  parent context, so normal saving
        // can work
        do{
            try self.backgroundContext.save()
        }catch{
            fatalError("Error while saving backgroundContext: \(error)")
            }
        }
    }
}
// Mark: - Save
extension CoreDataStackManager{
    
    func save(){
        context.performAndWait {
            if self.context.hasChanges{
                do{
                    try self.context.save()
                } catch{
                    fatalError("Fatal error while saving main context: \(error)")
                }
                
                self.persistentContext.perform {
                    do{
                        try self.persistentContext.save()
                    } catch{
                        fatalError("Fatal error while saving persisting context: \(error)")
                    }
                }
            }
        }
    }
    
    func autoSave(_ delayInSeconds: Int){
        if delayInSeconds > 0 {
            save()
            let nanoSecondsDelay = UInt64(delayInSeconds) * NSEC_PER_SEC
            let time =  DispatchTime.now() + Double(Int64(nanoSecondsDelay)) /
            Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: time, execute: {
            self.autoSave(delayInSeconds)
            })
        }
    }
}
