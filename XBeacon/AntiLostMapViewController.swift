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

class AntiLostMapViewController: UIViewController,MKMapViewDelegate {
    
    @IBOutlet weak var atlostSwitch: UISwitch!
    @IBOutlet weak var lostMapView: MKMapView!
    let regionRadius: CLLocationDistance = 1000
    
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func antiLostSwitch(sender: UISwitch) {
        UserDefaults.setBool(sender.on, forKey: "RegionState")
        if sender.on {
            XBeaconManager.sharedManager.startMonitor()
        }else{
            XBeaconManager.sharedManager.stopMonitor()
        }
    }
    
}
