//
//  RangingViewController.swift
//  XBeacon
//
//  Created by zzj on 7/22/15.
//  Copyright © 2015 zzj. All rights reserved.
//

import UIKit

class RangingViewController: UIViewController {

    @IBOutlet weak var rangingSwitch: UISwitch!
    @IBOutlet weak var rangeInfoLbl: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        XBeaconManager.sharedManager.rangeInfoLbl = rangeInfoLbl
//        rangingSwitch.setOn(UserDefaults.boolForKey("RangingState"), animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func rangingSwitch(sender: UISwitch) {
//        UserDefaults.setBool(sender.on, forKey: "RangingState")
        if sender.on {
            XBeaconManager.sharedManager.startRanging()
        }else{
            XBeaconManager.sharedManager.stopRanging()
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
