//
//  Account+CoreDataProperties.swift
//  recordMoney
//
//  Created by devilcry on 2017/1/22.
//  Copyright © 2017年 devilcry. All rights reserved.
//

import Foundation
import CoreData


extension Account {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Account> {
        return NSFetchRequest<Account>(entityName: "Account");
    }

    @NSManaged public var id: Int16
    @NSManaged public var amount: Double
    @NSManaged public var desc: String?
    @NSManaged public var createTime: String?
    @NSManaged public var type: String?

}
