//
//  Category.swift
//  TestCoreData
//
//  Created by Lainel John Dela Cruz on 23/10/2018.
//  Copyright © 2018 Lainel John Dela Cruz. All rights reserved.
//

import Foundation
import CoreData;


class Category:NSManagedObject{
    func set(name:String){
        self.name = name;
    }
}
