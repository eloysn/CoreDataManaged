//
//  File.swift
//  Core Data Stack
//
//  Created by eloysn on 25/7/17.
//  Copyright © 2017 eloysn. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
    private let modelName :String
    private let type: Bool
    
    //init
    //true:  NSSQLiteStoreType
    //false: NSInMemoryStoreType
    
    init(modelName: String, ofType type: Bool = true) {
        self.modelName = modelName
        self.type = type
        
        
    }
    //MARK: -Public Field
    lazy var contex: NSManagedObjectContext = {
        ///Contex public
        let contex = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        contex.persistentStoreCoordinator = self.storeCordinator
        return contex
        
    }()
    
    
    //MARK: -Private Field
    private lazy var managedObjectModel: NSManagedObjectModel = {
        
        guard let modelURL = Bundle.main.url(forResource: self.modelName, withExtension: "momd") else {
            fatalError("Unable to Find Data Model")
        }
        
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Unable to Load Data Model")
        }
        
        return managedObjectModel
    }()
    
    
    
    
    private lazy var storeCordinator: NSPersistentStoreCoordinator = {
        /// create storeCordinator
        let persistentStoreCoordinator: NSPersistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        ///save file sqlite
        let fileManager = FileManager.default
        let storeName = "\(self.modelName).sqlite"
        let documentsDirectoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let persistentStoreURL = documentsDirectoryURL.appendingPathComponent(storeName)
        
        ///configure store
        do {
            let options = [ NSInferMappingModelAutomaticallyOption : true,
                            NSMigratePersistentStoresAutomaticallyOption : true]
            
            try persistentStoreCoordinator.addPersistentStore(ofType: self.type ?  NSSQLiteStoreType : NSInMemoryStoreType,
                                                              configurationName: nil,
                                                              at: persistentStoreURL,
                                                              options: options)
        } catch {
            fatalError("Unable to Load Persistent Store")
        }
        
        
        return persistentStoreCoordinator
        
    }()
    
}
