//
//  AntiLostViewController.swift
//  XBeacon
//
//  Created by zzj on 7/20/15.
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

class AntiLostViewController: UIViewController,MKMapViewDelegate {

    @IBOutlet weak var atlostSwitch: UISwitch!
    @IBOutlet weak var lostMapView: MKMapView!
    let regionRadius: CLLocationDistance = 1000

    override func viewDidLoad() {
        super.viewDidLoad()
        atlostSwitch.setOn(UserDefaults.boolForKey("AntiLostState"), animated: false)
        XBeaconManager.sharedManager.antiLostViewController = self
        XBeaconManager.sharedManager.locationManager.desiredAccuracy=kCLLocationAccuracyBest
        XBeaconManager.sharedManager.locationManager.distanceFilter=kCLDistanceFilterNone
        XBeaconManager.sharedManager.locationManager.startMonitoringSignificantLocationChanges()
        XBeaconManager.sharedManager.locationManager.startUpdatingLocation()
    }
    
    func centerMapOnLocation(location: CLLocation) {
        XBeaconManager.sharedManager.locationManager.stopUpdatingLocation()
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        lostMapView.setRegion(coordinateRegion, animated: true)
        
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
                    self.lostMapView.addAnnotation(lostPin)
                }
        })
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func antiLostSwitch(sender: UISwitch) {
        UserDefaults.setBool(sender.on, forKey: "AntiLostState")
        if sender.on {
            XBeaconManager.sharedManager.setNotifyEntryStateOnDisplayOn()
        }else{
            XBeaconManager.sharedManager.setNotifyEntryStateOnDisplayOff()
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
