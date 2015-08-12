//
//  XBeacon+CoreDataProperties.swift
//  XBeacon
//
//  Created by zzj on 8/11/15.
//  Copyright © 2015 zzj. All rights reserved.
//
//  Delete this file and regenerate it using "Create NSManagedObject Subclass…"
//  to keep your implementation up to date with your model.
//

import Foundation
import CoreData
import CoreLocation

extension XBeacon {

    @NSManaged var name: String?
    @NSManaged var clregion: CLBeacon?

}
