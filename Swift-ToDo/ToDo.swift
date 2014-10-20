//
//  ToDo.swift
//  Swift-ToDo
//
//  Created by Matthew Smith on 10/15/14.
//  Copyright (c) 2014 Matthew Smith. All rights reserved.
//

import CoreData

class ToDo: NSManagedObject {
   
    @NSManaged
    var createdAt: NSDate
    
    @NSManaged
    var summary: String?
    
    @NSManaged
    var order: Int32
    
    @NSManaged
    var completed: Bool
    
    class func entityName() -> NSString {
        return "ToDo"
    }
    
    class func insertNewObjectIntoContext(context : NSManagedObjectContext) -> ToDo {
        let todo = NSEntityDescription.insertNewObjectForEntityForName(self.entityName(), inManagedObjectContext:context) as ToDo;
        todo.createdAt = NSDate();
        todo.order = todo.lastMaxPosition() + 1
        todo.completed = false
        return todo;
    }
    
    func lastMaxPosition () -> Int32 {
        let request = NSFetchRequest(entityName: self.entity.name!)
        request.fetchLimit = 1
        request.sortDescriptors = [NSSortDescriptor(key: "order", ascending: false)]
        
        var error: NSError? = nil
        let context : NSManagedObjectContext = self.managedObjectContext!
        let todos = context.executeFetchRequest(request, error: &error) as [ToDo]
        return todos.isEmpty ? 0 : todos[0].order
    }
}
