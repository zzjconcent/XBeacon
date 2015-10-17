//
//  BeaconSettingViewController.swift
//  XBeacon
//
//  Created by zzj on 8/11/15.
//  Copyright © 2015 zzj. All rights reserved.
//

import UIKit
import CoreBluetooth

let NOTIFY_MTU = 20

class BeaconSettingViewController: UIViewController,CBPeripheralManagerDelegate {

    var beacon:CLBeacon!
    var xBeacon:XBeacon?
    var peripheralManager:CBPeripheralManager!
    var transferCharacteristic:CBMutableCharacteristic!
    var dataToSend:NSData!
    var sendDataIndex = 0
    
    @IBOutlet weak var sharingSwitch: UISwitch!
    
    
    @IBOutlet weak var dataPickerView: UIPickerView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var shareBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        if xBeacon == nil {
            sharingSwitch.enabled = false
        }else{
            nameTextField.text = xBeacon!.name
        }
        // Do any additional setup after loading the view.
    }

    override func viewWillDisappear(animated: Bool) {
        peripheralManager.stopAdvertising()
        super.viewWillDisappear(animated)
    }
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        if peripheral.state != .PoweredOn {
            return
        }
        
        print("self.peripheralManager poweredon.")
        
        transferCharacteristic = CBMutableCharacteristic(type: CBUUID(string: TRANSFER_CHARACTERISTIC_UUID), properties: CBCharacteristicProperties.Notify, value: nil, permissions: CBAttributePermissions.Readable)
        let transferService = CBMutableService(type: CBUUID(string: TRANSFER_SERVICE_UUID), primary: true)
        transferService.characteristics = [transferCharacteristic]
        peripheralManager.addService(transferService)
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, central: CBCentral, didSubscribeToCharacteristic characteristic: CBCharacteristic) {
        print("Central subscribed to characteristic")
        
        dataToSend = NSKeyedArchiver.archivedDataWithRootObject(xBeacon!)
        sendDataIndex = 0
        sendData()
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFromCharacteristic characteristic: CBCharacteristic) {
        print("Central unsubscribed from characteristic")
    }
    
    var sendingEOM = false
 
    func sendData() {
        if sendingEOM {
            let endStr = "EOM"
            let didSend = peripheralManager.updateValue(endStr.dataUsingEncoding(NSUTF8StringEncoding)!, forCharacteristic: self.transferCharacteristic, onSubscribedCentrals: nil)
            
            if didSend {
                sendingEOM = false
                print("Sent: EOM")
            }
            return
        }
        
        if sendDataIndex >= dataToSend.length {
            return
        }
        
        var didSend = true
        repeat {
            
            
            var amountToSend = dataToSend.length - sendDataIndex
            
            if amountToSend > NOTIFY_MTU {
                amountToSend = NOTIFY_MTU
            }
            
            // Copy out the data we want
            let chunk = NSData(bytes: dataToSend.bytes + sendDataIndex, length: amountToSend)
            
            // Send it
            didSend = peripheralManager.updateValue(chunk, forCharacteristic: transferCharacteristic, onSubscribedCentrals: nil)
            
            // If it didn't work, drop out and wait for the callback
            if (!didSend) {
                return
            }
            
            // It did send, so update our index
            sendDataIndex += amountToSend;
            
            // Was it the last one?
            if sendDataIndex >= dataToSend.length {
                
                // It was - send an EOM
                
                // Set this so if the send fails, we'll send it next time
                sendingEOM = true
                
                // Send it
                let EOM = "EOM"
                let eomSent = peripheralManager.updateValue(EOM.dataUsingEncoding(NSUTF8StringEncoding)!, forCharacteristic: transferCharacteristic, onSubscribedCentrals: nil)
                
                if eomSent {
                    // It sent, we're all done
                    sendingEOM = false
                    
                    NSLog("Sent: EOM")
                }
                
                return
            }
            
        }while didSend
        
        
    }
    
    func peripheralManagerIsReadyToUpdateSubscribers(peripheral: CBPeripheralManager) {
        sendData()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    @IBAction func sharingStateChange(sender: UISwitch) {
        
        if sender.on {
            peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey:[CBUUID(string: TRANSFER_SERVICE_UUID)]])
            nameTextField.enabled = false
        }else{
            peripheralManager.stopAdvertising()
            nameTextField.enabled = true
        }
        
    }
    
    @IBAction func finishSetting(sender: UIBarButtonItem) {
        let rawString = nameTextField.text!
        let whitespace = NSCharacterSet.whitespaceAndNewlineCharacterSet()
        let trimmed = rawString.stringByTrimmingCharactersInSet(whitespace)
        var sameName = false
        if let xBeacons = XBeacon.MR_findAll() as? [XBeacon] {
            for xBeacon in xBeacons {
                if rawString == xBeacon.name! {
                    sameName = true
                    break
                }
            }
        }
        if trimmed.isEmpty && sameName {
            return
        }
        
        if xBeacon != nil {
            xBeacon!.name = nameTextField.text
            xBeacon!.managedObjectContext!.MR_saveToPersistentStoreAndWait()
            performSegueWithIdentifier("finishSettingToUnwind", sender: self)
            return
        }
        
        let xbeacon = XBeacon.MR_createEntityInContext(NSManagedObjectContext.MR_defaultContext())
        xbeacon.beacon = beacon
        xbeacon.name = nameTextField.text
        xbeacon.antiLost = false
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
