//
//  XBeacon+CoreDataProperties.swift
//  XBeacon
//
//  Created by zzj on 8/13/15.
//  Copyright © 2015 zzj. All rights reserved.
//
//  Delete this file and regenerate it using "Create NSManagedObject Subclass…"
//  to keep your implementation up to date with your model.
//

import Foundation
import CoreData

extension XBeacon {

    @NSManaged var beacon: CLBeacon?
    @NSManaged var name: String?
    @NSManaged var location: CLLocation?
    @NSManaged var antiLost: NSNumber?

}
