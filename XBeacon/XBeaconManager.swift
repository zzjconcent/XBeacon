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

class XBeaconManager: NSObject,CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    let beaconRegion = CLBeaconRegion(proximityUUID: kUUID!, major: major, minor: minor, identifier: kIdentifier)
    let peripheralManager = CBPeripheralManager()
    var rangingInfo:String!
    var inRegin = false
    var rangeInfoLbl: UILabel?
    
    override init() {
        super.init()
        if CLLocationManager.locationServicesEnabled() {
            if locationManager.respondsToSelector("requestAlwaysAuthorization") {
                locationManager.requestAlwaysAuthorization()
            }
        }
        
        locationManager.delegate = self
        setNotifyEntryStateOnDisplayOn()
        startMonitor()
    }

    class var sharedManager : XBeaconManager {
        return xBeaconManager
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager,
        didChangeAuthorizationStatus status: CLAuthorizationStatus) {
            if status == .AuthorizedWhenInUse || status == .AuthorizedAlways {
                locationManager.startUpdatingLocation()
            }
    }
    
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        sendLocalNotificationForBeaconReagion(region, detailStr: "Enter Region")
        inRegin = true
    }
    
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        sendLocalNotificationForBeaconReagion(region, detailStr: "Exit Region")
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
    
    // MARK: - Event Method
    func setNotifyEntryStateOnDisplayOn() {
        beaconRegion.notifyEntryStateOnDisplay = true
    }
    
    func setNotifyEntryStateOnDisplayOff() {
        beaconRegion.notifyEntryStateOnDisplay = false
    }
    
    func startMonitor() {
        locationManager.startMonitoringForRegion(beaconRegion)
    }
    
    func stopMonitor() {
        locationManager.stopMonitoringForRegion(beaconRegion)
    }
    
    func startRanging() {
        locationManager.startRangingBeaconsInRegion(beaconRegion)
    }
    
    func stopRanging() {
        locationManager.stopRangingBeaconsInRegion(beaconRegion)
    }
    
    // MARK: - Private Method
    func sendLocalNotificationForBeaconReagion(region:CLRegion,detailStr:String) {
        let localNotification = UILocalNotification()
        
        localNotification.alertBody = detailStr
        localNotification.alertAction = "View Details"
        localNotification.soundName = UILocalNotificationDefaultSoundName
        localNotification.category = "displayCategory"
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
    }
    
}
