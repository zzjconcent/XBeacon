//
//  AntiLostMapViewController.swift
//  XBeacon
//
//  Created by zzj on 8/10/15.
//  Copyright © 2015 zzj. All rights reserved.
//

import UIKit
import MapKit

class LostPin: NSObject, MKAnnotation {
    var beaconName:String!
    let title: String?
    let subTitle: String
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, subTitle: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subTitle = subTitle
        self.coordinate = coordinate
        
        super.init()
    }
    
    
    var subtitle: String? {
        return subTitle
    }
}

class AntiLostMapViewController: UIViewController,MKMapViewDelegate,UITableViewDataSource,UITableViewDelegate,NSFetchedResultsControllerDelegate,AntiLostBeaconCellDelegate {
    
//    @IBOutlet weak var atlostSwitch: UISwitch!
    @IBOutlet weak var lostMapView: MKMapView!
    @IBOutlet weak var antiLostListTableView: UITableView!
    let regionRadius: CLLocationDistance = 1000
    var frc:NSFetchedResultsController!
    
    var setRegionAnimateOnce = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        atlostSwitch.setOn(UserDefaults.boolForKey("RegionState"), animated: false)
        XBeaconManager.sharedManager.locationManager.desiredAccuracy=kCLLocationAccuracyBest
        XBeaconManager.sharedManager.locationManager.distanceFilter=kCLDistanceFilterNone
        XBeaconManager.sharedManager.locationManager.startMonitoringSignificantLocationChanges()
//        if let lostLocation = UserDefaults.objectForKey("LostLocation") as? CLLocation {
//            centerMapOnLocation(lostLocation)
//        }
        antiLostListTableView.dataSource = self
        antiLostListTableView.delegate = self
        antiLostListTableView.layer.borderWidth = 5
        antiLostListTableView.layer.borderColor = UIColor.lightGrayColor().CGColor
        let fetchRequest = XBeacon.MR_createFetchRequest()
        fetchRequest.sortDescriptors =  [NSSortDescriptor]()
        frc = XBeacon.MR_fetchController(fetchRequest, delegate: self, useFileCache: false, groupedBy: nil, inContext: NSManagedObjectContext.MR_defaultContext())
        frc.delegate = self
        do {
            try frc.performFetch()
        }
        catch let error as NSError {
            print(error)
        }
        
//        pinBeaconLostLocation()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "pinBeaconLostLocation", name: "BeaconLost", object: nil)
    }
    
    func pinBeaconLostLocation() {
        let xbeacons = XBeacon.MR_findAll() as! [XBeacon]
        for xbeacon in xbeacons {
            if xbeacon.location != nil {
                centerMapOnLocation(xbeacon.location!, beaconName: xbeacon.name!)
            }else{
                for an in self.lostMapView.annotations {
                    if let lp = an as? LostPin {
                        if lp.beaconName == xbeacon.name! {
                            self.lostMapView.removeAnnotation(lp)
                        }
                    }
                }
            }
        }
    }
    
    func markAntiLostLocation(xbeacon:XBeacon) {
        if xbeacon.location != nil {
            centerMapOnLocation(xbeacon.location!, beaconName: xbeacon.name!)
        }else{
            for an in self.lostMapView.annotations {
                if let lp = an as? LostPin {
                    if lp.beaconName == xbeacon.name! {
                        self.lostMapView.removeAnnotation(lp)
                    }
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return frc.fetchedObjects!.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AntiLostBeaconCell", forIndexPath: indexPath) as! AntiLostBeaconCell
        if let xBeacon = frc.fetchedObjects![indexPath.row] as? XBeacon {
            cell.nameLbl.text = xBeacon.name
            cell.xBeacon = xBeacon
            cell.antiLostSwitch.on = xBeacon.antiLost!.boolValue
            if xBeacon.antiLost!.boolValue {
                let beacon = xBeacon.beacon!
                let major = CLBeaconMajorValue(beacon.major.integerValue)
                let minor = CLBeaconMinorValue(beacon.minor.integerValue)
                let beaconRegion = CLBeaconRegion(proximityUUID: beacon.proximityUUID, major: major, minor: minor, identifier: xBeacon.name!)
                XBeaconManager.sharedManager.startRanging(beaconRegion)
            }
            markAntiLostLocation(xBeacon)
            cell.delegate = self
        }
        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            if let deleteBeacon = frc.fetchedObjects![indexPath.row] as? XBeacon {
                if deleteBeacon.antiLost!.boolValue {
                    let beacon = deleteBeacon.beacon!
                    let major = CLBeaconMajorValue(beacon.major.integerValue)
                    let minor = CLBeaconMinorValue(beacon.minor.integerValue)
                    let beaconRegion = CLBeaconRegion(proximityUUID: beacon.proximityUUID, major: major, minor: minor, identifier: deleteBeacon.name!)
                    XBeaconManager.sharedManager.stopMonitor(beaconRegion)
                    XBeaconManager.sharedManager.stopRanging(beaconRegion)
                    if deleteBeacon.location != nil {
                        for an in self.lostMapView.annotations {
                            if let lp = an as? LostPin {
                                if lp.beaconName == deleteBeacon.name! {
                                    self.lostMapView.removeAnnotation(lp)
                                    break
                                }
                            }
                        }
                    }
                }
                deleteBeacon.MR_deleteEntity()
                deleteBeacon.managedObjectContext!.MR_saveToPersistentStoreAndWait()
            }
        }
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        antiLostListTableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:antiLostListTableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:antiLostListTableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            //        case .Update:antiLostListTableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        default:break
        }

    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        antiLostListTableView.endUpdates()
    }
    
    func didUpdateCellAntiLostState(on: Bool, xBeacon: XBeacon) {
        if on {
            CLGeocoder().reverseGeocodeLocation(xBeacon.location!, completionHandler:
                {(placemarks, error) in
                    if (error != nil) {
                        print("reverse geodcode fail: \(error!.localizedDescription)")
                        return
                    }
                    let beaconName = xBeacon.name!
                    let pm = placemarks!
                    if pm.count > 0 {
                        let title = "\(beaconName)" + "\n" + "\(pm[0].subLocality)"
                        let subTitle = "\(pm[0].thoroughfare)\(pm[0].subThoroughfare)"
                        let lostPin = LostPin(title: title, subTitle:subTitle ,coordinate: pm[0].location!.coordinate)
                        lostPin.beaconName = beaconName
                        self.lostMapView.addAnnotation(lostPin)
                    }
            })
        }else{
            for an in self.lostMapView.annotations {
                if let lp = an as? LostPin {
                    if lp.beaconName == xBeacon.name {
                        self.lostMapView.removeAnnotation(lp)
                        break
                    }
                }
            }
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "BeaconSetting" {
            if let vc = segue.destinationViewController as? BeaconSettingViewController {
                let cell = sender as! AntiLostBeaconCell
                vc.xBeacon = cell.xBeacon
            }
        }
    }
    
    func centerMapOnLocation(location: CLLocation, beaconName:String) {
        print("\(location.coordinate)")
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        
        if setRegionAnimateOnce {
            lostMapView.setRegion(coordinateRegion, animated: true)
        }
        setRegionAnimateOnce = false
        
        CLGeocoder().reverseGeocodeLocation(location, completionHandler:
            {(placemarks, error) in
                if (error != nil) {
                    print("reverse geodcode fail: \(error!.localizedDescription)")
                    return
                }
                
                let pm = placemarks!
                if pm.count > 0 {
                    let title = "\(beaconName)" + "\n" + "\(pm[0].subLocality)"
                    let subTitle = "\(pm[0].thoroughfare)\(pm[0].subThoroughfare)"
                    let lostPin = LostPin(title: title, subTitle:subTitle ,coordinate: pm[0].location!.coordinate)
                    lostPin.beaconName = beaconName
                    for an in self.lostMapView.annotations {
                        if let lp = an as? LostPin {
                            if lp.beaconName == beaconName {
                                self.lostMapView.removeAnnotation(lp)
                            }
                        }
                    }
                    self.lostMapView.addAnnotation(lostPin)
                }
        })
        
    }
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @IBAction func unwindToAntiLostMapViewController(segue:UIStoryboardSegue) {
    
    }
    
    @IBAction func antiLostSwitch(sender: UISwitch) {
        UserDefaults.setBool(sender.on, forKey: "RegionState")
        if sender.on {
            //FIXME : MultiDevice
//            XBeaconManager.sharedManager.startMonitor()
        }else{
//            XBeaconManager.sharedManager.stopMonitor()
        }
    }
    
}
