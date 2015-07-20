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
    
    var inRegin = false
    
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
    
    // MARK: - Private Method
    func sendLocalNotificationForBeaconReagion(region:CLRegion,detailStr:String) {
        let localNotification = UILocalNotification()
        
        localNotification.alertBody = detailStr
        localNotification.alertAction = "View Details"
        localNotification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
    }
    
}
