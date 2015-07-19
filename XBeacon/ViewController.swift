//
//  ViewController.swift
//  XBeacon
//
//  Created by zzj on 7/19/15.
//  Copyright © 2015 zzj. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth

let kUUID = NSUUID(UUIDString: "12345678-1234-1234-1234-1234567890ab")
let kIdentifier = "XBeacon"
let major:CLBeaconMajorValue = 4660
let minor:CLBeaconMinorValue = 4660

class ViewController: UIViewController,CLLocationManagerDelegate {

    
    let locationManager = CLLocationManager()
    let beaconRegion = CLBeaconRegion(proximityUUID: kUUID!, major: major, minor: minor, identifier: kIdentifier)
    let peripheralManager = CBPeripheralManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if CLLocationManager.locationServicesEnabled() {
            if locationManager.respondsToSelector("requestAlwaysAuthorization") {
                locationManager.requestAlwaysAuthorization()
            }
        }

        beaconRegion.notifyEntryStateOnDisplay = true
        locationManager.delegate = self
        locationManager.startMonitoringForRegion(beaconRegion)
    }
    
    func locationManager(manager: CLLocationManager,
        didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse || status == .AuthorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }

    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        sendLocalNotificationForBeaconReagion(region, detailStr: "Enter Region")
    }
    
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        sendLocalNotificationForBeaconReagion(region, detailStr: "Exit Region")
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
    
    func sendLocalNotificationForBeaconReagion(region:CLRegion,detailStr:String) {
        let localNotification = UILocalNotification()
        
        localNotification.alertBody = detailStr
        localNotification.alertAction = "View Details"
        localNotification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
    }
}

