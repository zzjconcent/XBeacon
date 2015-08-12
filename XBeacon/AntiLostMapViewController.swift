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

class AntiLostMapViewController: UIViewController,MKMapViewDelegate,UITableViewDataSource,UITableViewDelegate,NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var atlostSwitch: UISwitch!
    @IBOutlet weak var lostMapView: MKMapView!
    @IBOutlet weak var antiLostListTableView: UITableView!
    let regionRadius: CLLocationDistance = 1000
    var frc:NSFetchedResultsController!
    
    var setRegionAnimateOnce = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        atlostSwitch.setOn(UserDefaults.boolForKey("RegionState"), animated: false)
        XBeaconManager.sharedManager.locationManager.desiredAccuracy=kCLLocationAccuracyBest
        XBeaconManager.sharedManager.locationManager.distanceFilter=kCLDistanceFilterNone
        XBeaconManager.sharedManager.locationManager.startMonitoringSignificantLocationChanges()
        if let lostLocation = UserDefaults.objectForKey("LostLocation") as? CLLocation {
            centerMapOnLocation(lostLocation)
        }
        antiLostListTableView.dataSource = self
        antiLostListTableView.delegate = self
        
        let fetchRequest = XBeacon.MR_createFetchRequest()
        fetchRequest.sortDescriptors =  [NSSortDescriptor]()
        frc = XBeacon.MR_fetchController(fetchRequest, delegate: self, useFileCache: false, groupedBy: nil, inContext: NSManagedObjectContext.MR_defaultContext())
        do {
            try frc.performFetch()
        }
        catch let error as NSError {
            print(error)
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
        if let xbeacon = frc.fetchedObjects![indexPath.row] as? XBeacon {
            cell.textLabel?.text = xbeacon.name
            print("\(xbeacon.name)")
        }
        return cell
    }
    
    func centerMapOnLocation(location: CLLocation) {
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
                    let title = "\(pm[0].subLocality)"
                    let subTitle = "\(pm[0].thoroughfare)\(pm[0].subThoroughfare)"
                    let lostPin = LostPin(title: title, subTitle:subTitle ,coordinate: pm[0].location.coordinate)
                    self.lostMapView.removeAnnotations(self.lostMapView.annotations)
                    self.lostMapView.addAnnotation(lostPin)
                }
        })
        
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
