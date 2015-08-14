//
//  XBeacon.swift
//  XBeacon
//
//  Created by zzj on 8/11/15.
//  Copyright © 2015 zzj. All rights reserved.
//

import Foundation
import CoreData

@objc(XBeacon)
class XBeacon: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    func encodeWithCoder(aCoder:NSCoder) {
        aCoder.encodeObject(beacon, forKey: "beacon")
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(location, forKey: "location")
        aCoder.encodeObject(antiLost, forKey: "antiLost")
    }
    
     convenience init(coder aDecoder:NSCoder) {
        let entity = NSEntityDescription.entityForName("XBeacon", inManagedObjectContext: NSManagedObjectContext.MR_defaultContext())
        self.init(entity: entity!, insertIntoManagedObjectContext: NSManagedObjectContext.MR_defaultContext())
        beacon = aDecoder.decodeObjectForKey("beacon") as? CLBeacon
            name = aDecoder.decodeObjectForKey("name") as? String
            location = aDecoder.decodeObjectForKey("location") as? CLLocation
            antiLost = aDecoder.decodeObjectForKey("antiLost") as? Bool
     }

}
