//
//  CoreDataConnect.swift
//  money
//
//  Created by devilcry on 2017/1/12.
//  Copyright © 2017年 devilcry. All rights reserved.
//

import Foundation
import CoreData

class CoreDataConnect {
    var moc :NSManagedObjectContext!
    
    typealias MyType = Account
    
    init(moc:NSManagedObjectContext) {
        self.moc = moc
    }
    
    // CRUD 四大方法
    func insert(myEntityName:String,
                attributeInfo:[String:String]) -> Bool {
        let insetData =
            NSEntityDescription.insertNewObject(
                forEntityName: myEntityName, into: self.moc)
                as! MyType
        
        for (key,value) in attributeInfo {
            let t =
                insetData.entity.attributesByName[key]?.attributeType
            
            if t == .integer16AttributeType
                || t == .integer32AttributeType
                || t == .integer64AttributeType {
                insetData.setValue(Int(value),
                                   forKey: key)
            } else if t == .doubleAttributeType
                || t == .floatAttributeType {
                insetData.setValue(Double(value),
                                   forKey: key)
            } else if t == .booleanAttributeType {
                insetData.setValue(
                    (value == "true" ? true : false),
                    forKey: key)
            } else { //string
                insetData.setValue(value, forKey: key)
            }
        }
        
        do {
            try moc.save()
            
            return true
        } catch {
            fatalError("\(error)")
        }
        
        return false
    }
    
    func update(myEntityName:String, predicate:String?,
        attributeInfo:[String:String]) -> Bool {
       
        if let results = self.fetch(
            myEntityName: myEntityName,
            predicate: predicate, sort: nil, limit: nil) {
            
            for result in results {
                for (key,value) in attributeInfo {
                    let t =
                        result.entity.attributesByName[key]?.attributeType
                    
                    if t == .integer16AttributeType
                        || t == .integer32AttributeType
                        || t == .integer64AttributeType {
                        result.setValue(
                            Int(value), forKey: key)
                    } else if t == .doubleAttributeType
                        || t == .floatAttributeType {
                        result.setValue(
                            Double(value), forKey: key)
                    } else if t == .booleanAttributeType {
                        result.setValue(
                            (value == "true" ? true : false),
                            forKey: key)
                    } else {
                        result.setValue(
                            value, forKey: key)
                    }
                }
            }
            
            do {
                try self.moc.save()
                return true
            } catch {
                fatalError("\(error)")
            }
        }
        
        return false
    }
    
    func delete(myEntityName:String, predicate:String?)
        -> Bool {
            if let results = self.fetch(myEntityName: myEntityName,
                predicate: predicate,
                sort: nil,
                limit: nil)
            {
                for result in results {
                    self.moc.delete(result)
                }
                
                do {
                    try self.moc.save()
                    return true
                } catch {
                    fatalError("\(error)")
                }
            }
            return false
    }
    
    func fetch(myEntityName:String, predicate:String?,
               sort:[[String:Bool]]?, limit:Int?) -> [MyType]? {
        let request = NSFetchRequest<NSFetchRequestResult>(
            entityName: myEntityName)
        
        // predicate
        if let myPredicate = predicate {
            request.predicate =
                NSPredicate(format: myPredicate)
        }
        
        // sort
        if let mySort = sort {
            var sortArr :[NSSortDescriptor] = []
            for sortCond in mySort {
                for (k, v) in sortCond {
                    sortArr.append(
                        NSSortDescriptor(
                            key: k, ascending: v))
                }
            }
            
            request.sortDescriptors = sortArr
        }
        
        // limit
        if let limitNumber = limit {
            request.fetchLimit = limitNumber
        }
        
        do {
            let results =
                try moc.fetch(request) as! [MyType]
            return results
        } catch {
            fatalError("\(error)")
        }
        
        return nil
    }
    
}
