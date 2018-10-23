//
//  Tasl.swift
//  TestCoreData
//
//  Created by Lainel John Dela Cruz on 22/10/2018.
//  Copyright © 2018 Lainel John Dela Cruz. All rights reserved.
//

import Foundation
import CoreData

class Task:NSManagedObject{
    convenience init(){
        self.init();
    }
    func set(id:String, name:String, isDone:Bool){
        self.id=id;
        self.taskname=name;
        self.isDone=isDone;
    }
    
}
