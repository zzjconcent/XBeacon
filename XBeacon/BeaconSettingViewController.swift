//
//  BeaconSettingViewController.swift
//  XBeacon
//
//  Created by zzj on 8/11/15.
//  Copyright © 2015 zzj. All rights reserved.
//

import UIKit

class BeaconSettingViewController: UIViewController {

    var beacon:CLBeacon!
    
    @IBOutlet weak var dataPickerView: UIPickerView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var shareBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func finishSetting(sender: UIBarButtonItem) {
        let rawString = nameTextField.text!
        let whitespace = NSCharacterSet.whitespaceAndNewlineCharacterSet()
        let trimmed = rawString.stringByTrimmingCharactersInSet(whitespace)

        if trimmed.isEmpty {
            return
        }
        
        let xbeacon = XBeacon.MR_createEntityInContext(NSManagedObjectContext.MR_defaultContext())
        xbeacon.clregion = beacon
        xbeacon.name = nameTextField.text
        xbeacon.managedObjectContext!.MR_saveToPersistentStoreAndWait()
        performSegueWithIdentifier("finishSettingToUnwind", sender: self)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
