//
//  RegionViewController.swift
//  XBeacon
//
//  Created by zzj on 7/20/15.
//  Copyright © 2015 zzj. All rights reserved.
//

import UIKit

class RegionViewController: UIViewController {

    @IBOutlet weak var regionSwitch: UISwitch!
    override func viewDidLoad() {
        super.viewDidLoad()
        regionSwitch.setOn(UserDefaults.boolForKey("RegionState"), animated: false)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func regionSwitch(sender: UISwitch) {
        UserDefaults.setBool(sender.on, forKey: "RegionState")
        if sender.on {
            XBeaconManager.sharedManager.startMonitor()
        }else{
            XBeaconManager.sharedManager.stopMonitor()
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
