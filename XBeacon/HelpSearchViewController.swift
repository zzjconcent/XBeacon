//
//  HelpSearchViewController.swift
//  XBeacon
//
//  Created by zzj on 8/14/15.
//  Copyright © 2015 zzj. All rights reserved.
//

import UIKit
import CoreBluetooth

let TRANSFER_SERVICE_UUID = "E20A39F4-73F5-4BC4-A12F-17D1AD07A961"
let TRANSFER_CHARACTERISTIC_UUID = "08590F7E-DB05-467E-8757-72F6FAEB13D4"

class HelpSearchViewController: UIViewController,CBCentralManagerDelegate,CBPeripheralDelegate {

    @IBOutlet weak var detectedBeaconLbl: UILabel!
    var centralManager:CBCentralManager!
    var discoveredPeripheral:CBPeripheral?
    var data = NSMutableData()
    var xBeacon:XBeacon? {
        didSet{
           detectedBeaconLbl.text = xBeacon!.name
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        // Do any additional setup after loading the view.
    }
    override func viewWillDisappear(animated: Bool) {
        centralManager.stopScan()
        print("Scanning stopped")
        super.viewWillDisappear(animated)
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        if central.state != .PoweredOn {
            return
        }
        
        scan()
    }
    
    func scan() {
        centralManager.scanForPeripheralsWithServices([CBUUID(string: TRANSFER_SERVICE_UUID)], options: [CBCentralManagerScanOptionAllowDuplicatesKey : NSNumber(bool: true)])
        print("Scanning started")
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        if RSSI.integerValue > -15 || RSSI.integerValue < -60 {
            return
        }
        
        print("Discovered \(peripheral.name) at \(RSSI)")
        
        if discoveredPeripheral != peripheral {
            discoveredPeripheral = peripheral
            print("Connecting to peripheral \(peripheral)")
            centralManager.connectPeripheral(peripheral, options: nil)
        }
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("Failed to connect to \(peripheral) \(error!.localizedDescription)")
        cleanup()
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        print("Peripheral Connected")
        
        centralManager.stopScan()
        print("Scanning stopped")
        
        data.length = 0
        peripheral.delegate = self
        
        peripheral.discoverServices([CBUUID(string:TRANSFER_SERVICE_UUID)])
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        if (error != nil) {
            print("Error discovering services: \(error!.localizedDescription)")
            cleanup()
            return
        }
        
        for service in peripheral.services! {
            peripheral.discoverCharacteristics([CBUUID(string: TRANSFER_CHARACTERISTIC_UUID)], forService: service)
        }
    }

    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        if (error != nil) {
            print("Error discovering characteristics: \(error!.localizedDescription)")
            cleanup()
            return
        }
        
        for characteristic in service.characteristics! {
            if characteristic.UUID.isEqual(CBUUID(string: TRANSFER_CHARACTERISTIC_UUID)) {
                peripheral.setNotifyValue(true, forCharacteristic: characteristic)
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if (error != nil) {
            print("Error discovering characteristics: \(error!.localizedDescription)")
            return
        }
        
        if let endCheckString = NSString(data: characteristic.value!, encoding: NSUTF8StringEncoding) {
            if endCheckString.isEqual("EOM") {
                if let xbeaconFromData = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? XBeacon {
                    xBeacon = xbeaconFromData
                }
                peripheral.setNotifyValue(false, forCharacteristic: characteristic)
                centralManager.cancelPeripheralConnection(peripheral)
            }
        }
        data.appendData(characteristic.value!)
 
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if (error != nil) {
            print("Error changing notification state: \(error!.localizedDescription)")
        }
        if !characteristic.UUID.isEqual(CBUUID(string: TRANSFER_CHARACTERISTIC_UUID)) {
            return
        }
        
        if characteristic.isNotifying {
            print("Notification began on \(characteristic)")
        }else{
            print("Notification stopped on \(characteristic) Disconnecting")
            centralManager.cancelPeripheralConnection(peripheral)
        }
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("Peripheral Disconnected")
        discoveredPeripheral = nil
//        scan()
    }
    
    func cleanup() {
        if discoveredPeripheral!.state == .Connected {
            return
        }
        
        if discoveredPeripheral!.services != nil {
            for service in discoveredPeripheral!.services! {
                if service.characteristics != nil {
                    for characteristic in service.characteristics! {
                        if characteristic.UUID.isEqual(CBUUID(string: TRANSFER_CHARACTERISTIC_UUID)) {
                            if characteristic.isNotifying {
                                discoveredPeripheral!.setNotifyValue(false, forCharacteristic: characteristic)
                                return
                            }
                        }
                    }
                }
            }
        }
        
        centralManager.cancelPeripheralConnection(discoveredPeripheral!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func addHelpSearchBeacon(sender: UIButton) {
        if xBeacon == nil {
            return
        }
        
        if xBeacon!.antiLost!.boolValue {
            let beacon = xBeacon!.beacon!
            let major = CLBeaconMajorValue(beacon.major.integerValue)
            let minor = CLBeaconMinorValue(beacon.minor.integerValue)
            let beaconRegion = CLBeaconRegion(proximityUUID: beacon.proximityUUID, major: major, minor: minor, identifier: xBeacon!.name!)
            XBeaconManager.sharedManager.startMonitor(beaconRegion)
            XBeaconManager.sharedManager.startRanging(beaconRegion)
        }
        xBeacon!.managedObjectContext!.MR_saveToPersistentStoreAndWait()
        navigationController?.popViewControllerAnimated(true)
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
