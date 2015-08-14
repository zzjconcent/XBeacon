//
//  XBeaconManager.swift
//  XBeacon
//
//  Created by zzj on 7/20/15.
//  Copyright © 2015 zzj. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth

private let xBeaconManager = XBeaconManager()

class XBeaconManager: NSObject,CLLocationManagerDelegate,CBPeripheralManagerDelegate {
    
    let locationManager = CLLocationManager()
    let beaconRegion = CLBeaconRegion(proximityUUID: kUUID!, identifier: kIdentifier)// CLBeaconRegion(proximityUUID: kUUID!, major: major, minor: minor, identifier: kIdentifier)
    var peripheralManager:CBPeripheralManager!
    var rangingInfo:String!
    var inRegin = false
    var pmBeaconState = false
    var rangeInfoLbl: UILabel?
    var antiLostViewController:AntiLostViewController?
    var beacons:[CLBeacon]?
    var lostBeacons = Set<String>()
    
    override init() {
        super.init()
        if CLLocationManager.locationServicesEnabled() {
            if locationManager.respondsToSelector("requestAlwaysAuthorization") {
                locationManager.requestAlwaysAuthorization()
            }
        }
        
        locationManager.delegate = self
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
        setNotifyEntryStateOnDisplayOn()
        startMonitor(beaconRegion)
    }

    class var sharedManager : XBeaconManager {
        return xBeaconManager
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        UserDefaults.setObject(locations.first, forKey: "LostLocation")
        let xbeacons = XBeacon.MR_findAll()
        for xbeacon in xbeacons {
            if let beacon = xbeacon as? XBeacon {
                if lostBeacons.contains(beacon.name!) && beacon.location == nil {
                    beacon.location = locations.first!.locationMarsFromEarth()
                    beacon.managedObjectContext!.MR_saveToPersistentStoreAndWait()
                }
            }
        }
        NSNotificationCenter.defaultCenter().postNotificationName("BeaconLost", object: nil)
        xBeaconManager.locationManager.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager,
        didChangeAuthorizationStatus status: CLAuthorizationStatus) {
            if status == .AuthorizedWhenInUse || status == .AuthorizedAlways {
                locationManager.startUpdatingLocation()
            }
    }
    
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
//        sendLocalNotificationForBeaconReagion(region, detailStr: "Enter Region")
        inRegin = true
    }
    
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        sendLocalNotificationForBeaconReagion(region, detailStr: "\(region.identifier) Lost")
        lostBeacons.insert(region.identifier)
        xBeaconManager.locationManager.startUpdatingLocation()
        inRegin = false
    }
    
    func locationManager(manager: CLLocationManager, didDetermineState state: CLRegionState, forRegion region: CLRegion) {
        var stateStr = "none"
        switch state {
        case .Inside:stateStr = "Inside"
        case .Outside:stateStr = "Outside"
        case .Unknown:stateStr = "Unknow"
        }
        sendLocalNotificationForBeaconReagion(region, detailStr: "DetermineState: \(stateStr)")
    }
    
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        var newBeacons = beacons
        if let addedBeacons = XBeacon.MR_findAll() as? [CLBeacon] {
            for i in stride(from: newBeacons.count - 1, through: 0, by: -1) {
                var alreadyExists = false
                let newBeacon = newBeacons[i]
                for addedBeacon in addedBeacons {
                    if addedBeacon.major == newBeacon.major && addedBeacon.minor == newBeacon.minor && addedBeacon.proximityUUID == newBeacon.proximityUUID {
                        alreadyExists = true
                        break
                    }
                }
                if alreadyExists {
                    newBeacons.removeAtIndex(i)
                }
            }
        }
        xBeaconManager.beacons = newBeacons
        if beacons.count == 1 {
            let userInfo = ["proximity":beacons.first!.proximity.rawValue]
            NSNotificationCenter.defaultCenter().postNotificationName(region.identifier, object: nil, userInfo: userInfo)
            if beacons.first!.proximity == .Unknown {
                lostBeacons.insert(region.identifier)
                xBeaconManager.locationManager.startUpdatingLocation()
            }
        }
        NSNotificationCenter.defaultCenter().postNotificationName("UpdateSearchingBeaconResults", object: nil)
        for beacon in beacons {
            if beacon.proximityUUID == kUUID! {
                var proximity:String!
                switch beacon.proximity {
                case .Near:
                    proximity = "Near"
                case .Immediate:
                    proximity = "Immediate"
                case .Far:
                    proximity = "Far"
                case .Unknown:
                    proximity = "Unknown"
                }
                rangingInfo = "proximity:\(proximity)\naccuracy:\(beacon.accuracy)\nrssi:\(beacon.rssi)"
                if let lbl = rangeInfoLbl {
                    lbl.text = rangingInfo
                }
            }
        }
    }
    // MARK: - Beacon advertising delegate methods
    func peripheralManagerDidStartAdvertising(peripheral: CBPeripheralManager, error: NSError?) {
        if (error != nil) {
            print("Couldn't turn on advertising: \(error)")
            return
        }
        
        if peripheralManager.isAdvertising {
            print("Turned on advertising.")
        }
    }
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        if peripheralManager.state != .PoweredOn {
            print("Peripheral manager is off.")
            return;
        }
        
        print("Peripheral manager is on.")
    }
    
    // MARK: - Event Method
    func setNotifyEntryStateOnDisplayOn() {
        beaconRegion.notifyEntryStateOnDisplay = true
    }
    
    func setNotifyEntryStateOnDisplayOff() {
        beaconRegion.notifyEntryStateOnDisplay = false
    }
    
    func startMonitor(beaconRegion:CLBeaconRegion) {
        locationManager.startMonitoringForRegion(beaconRegion)
    }
    
    func stopMonitor(beaconRegion:CLBeaconRegion) {
        locationManager.stopMonitoringForRegion(beaconRegion)
    }
    
    func startRanging(beaconRegion:CLBeaconRegion) {
        locationManager.startRangingBeaconsInRegion(beaconRegion)
    }
    
    func stopRanging(beaconRegion:CLBeaconRegion) {
        locationManager.stopRangingBeaconsInRegion(beaconRegion)
    }
    
    func startAdvertisingBeacon() {
        if peripheralManager.state != .PoweredOn {
            print("Peripheral manager is off.")
            return;
        }
        
        let mj:CLBeaconMajorValue = 1234
        let mi:CLBeaconMajorValue = 5678

        let region = CLBeaconRegion(proximityUUID: kUUID!, major: mj, minor: mi, identifier: kIdentifier)
        let beaconPeripheralData = region.peripheralDataWithMeasuredPower(nil)
        var swiftDict : Dictionary<String,AnyObject!> = Dictionary<String,AnyObject!>()
        for key : AnyObject in beaconPeripheralData.allKeys {
            let stringKey = key as! String
            if let keyValue = beaconPeripheralData.valueForKey(stringKey){
                swiftDict[stringKey] = keyValue
            }
        }
        peripheralManager.startAdvertising(swiftDict)
        pmBeaconState = true
    }
    
    func stopAdvertisingBeacon() {
        peripheralManager.stopAdvertising()
        pmBeaconState = false
    }
    
    // MARK: - Private Method
    func sendLocalNotificationForBeaconReagion(region:CLRegion,detailStr:String) {
        let localNotification = UILocalNotification()
        
        localNotification.alertBody = detailStr
        localNotification.alertAction = "View Details"
        localNotification.soundName = UILocalNotificationDefaultSoundName
//        localNotification.category = "displayCategory"
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
    }
    
}
