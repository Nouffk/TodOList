//
//  CoreDataManger.swift
//  TodoList
//
//  Created by Nouf Faisal  on 08/10/1445 AH.
//

import CoreData

struct CoreDataManger {
 
 static let shared = CoreDataManger()
 let container: NSPersistentContainer
 init(inMemory: Bool = false) {
 container = NSPersistentContainer (name: "Model" )
     if inMemory {
         container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
     }
     container.loadPersistentStores { storeDescription, error in
         print("Error while loading CoreData")
     }
 container.viewContext.automaticallyMergesChangesFromParent = true
 }
 }
