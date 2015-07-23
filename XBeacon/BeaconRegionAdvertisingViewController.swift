//
//  BeaconRegionAdvertisingViewController.swift
//  XBeacon
//
//  Created by zzj on 7/23/15.
//  Copyright © 2015 zzj. All rights reserved.
//

import UIKit

class BeaconRegionAdvertisingViewController: UIViewController {


    @IBOutlet weak var beaconRegionADSwitch: UISwitch!
    override func viewDidLoad() {
        super.viewDidLoad()
        beaconRegionADSwitch.setOn(XBeaconManager.sharedManager.pmBeaconState, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func beaconAdvertisingSwitch(sender: UISwitch) {
        if sender.on {
            XBeaconManager.sharedManager.startAdvertisingBeacon()
        }else{
            XBeaconManager.sharedManager.stopAdvertisingBeacon()
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
