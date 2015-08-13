//
//  AntiLostBeaconCell.swift
//  XBeacon
//
//  Created by zzj on 8/12/15.
//  Copyright © 2015 zzj. All rights reserved.
//

import UIKit

class AntiLostBeaconCell: UITableViewCell {

    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var antiLostSwitch: UISwitch!
    @IBOutlet weak var stateImgView: UIImageView!
    var beaconRegion:CLBeaconRegion!
    var xBeacon:XBeacon!{
        didSet{
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "stateChanged:", name: xBeacon.name, object: nil)
            createBeaconRegion()
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func createBeaconRegion() {
        let beacon = xBeacon.beacon!
        let major = CLBeaconMajorValue(beacon.major.integerValue)
        let minor = CLBeaconMinorValue(beacon.minor.integerValue)
        beaconRegion = CLBeaconRegion(proximityUUID: beacon.proximityUUID, major: major, minor: minor, identifier: xBeacon.name!)
    }
    
    func stateChanged(stateChangeNoti:NSNotification) {
        if let state = stateChangeNoti.userInfo!["proximity"] as? Int {
            let proximity = CLProximity(rawValue: state)!
            switch proximity {
            case .Unknown:stateImgView.backgroundColor = UIColor.grayColor()
            case .Immediate:
                xBeacon.location = nil
                xBeacon.managedObjectContext!.MR_saveToPersistentStoreAndWait()
                NSNotificationCenter.defaultCenter().postNotificationName("BeaconLost", object: nil)
                stateImgView.backgroundColor = UIColor.greenColor()
            case .Near:stateImgView.backgroundColor = UIColor.yellowColor()
            case .Far:stateImgView.backgroundColor = UIColor.redColor()
            }
        }
    }
    
    @IBAction func antiLost(sender: UISwitch) {
        if sender.on {
            XBeaconManager.sharedManager.startMonitor(beaconRegion)
            XBeaconManager.sharedManager.startRanging(beaconRegion)
            xBeacon.antiLost = true
        }else {
            XBeaconManager.sharedManager.stopMonitor(beaconRegion)
            XBeaconManager.sharedManager.stopRanging(beaconRegion)
            xBeacon.antiLost = false
            stateImgView.backgroundColor = UIColor.clearColor()
        }
        xBeacon.managedObjectContext!.MR_saveToPersistentStoreAndWait()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
