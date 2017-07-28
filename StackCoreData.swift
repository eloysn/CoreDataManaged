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
    
    //inicializador del stack, donde le decimos por defecto que queremos almacenamiento en disco 
    //true:  NSSQLiteStoreType
    //false: NSInMemoryStoreType
    
    init(modelName: String, ofType type: Bool = true) {
        self.modelName = modelName
        self.type = type
        
        
    }
    //MARK: -Public Field
    lazy var contex: NSManagedObjectContext = {
        ///Creamos el contexto y lo hacemos publico
        let contex = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        contex.persistentStoreCoordinator = self.storeCordinator
        return contex
        
    }()
    
    
    //MARK: -Private Field
    private lazy var managedObjectModel: NSManagedObjectModel = {
        ///buscamos el modelo en Blundel de app, con el nombre del modelo real
        guard let modelURL = Bundle.main.url(forResource: self.modelName, withExtension: "momd") else {
            fatalError("Unable to Find Data Model")
        }
        ///Si lo encontramos creamos el objectModel y lo devolvemos
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Unable to Load Data Model")
        }
        
        return managedObjectModel
    }()
    
    
    
    
    private lazy var storeCordinator: NSPersistentStoreCoordinator = {
        /// creamos el storeCordinator
        let persistentStoreCoordinator: NSPersistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        ///Configuramos donde vamos a guardar la base de datos normalmente en el directorio document de la app y le damos extension sqlite
        let fileManager = FileManager.default
        let storeName = "\(self.modelName).sqlite"
        let documentsDirectoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let persistentStoreURL = documentsDirectoryURL.appendingPathComponent(storeName)
        
        ///configuramos el store, como migracion de models y donde lo queremos guardar en memory o en disco
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
