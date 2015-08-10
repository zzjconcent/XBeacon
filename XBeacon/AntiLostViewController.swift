//
//  AntiLostViewController.swift
//  XBeacon
//
//  Created by zzj on 7/20/15.
//  Copyright © 2015 zzj. All rights reserved.
//

import UIKit

class AntiLostViewController: UIViewController {
    
    @IBOutlet weak var atlostSwitch: UISwitch!
    override func viewDidLoad() {
        super.viewDidLoad()
        atlostSwitch.setOn(UserDefaults.boolForKey("AntiLostState"), animated: false)
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
