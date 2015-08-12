//
//  BeaconSearchViewController.swift
//  XBeacon
//
//  Created by zzj on 8/11/15.
//  Copyright © 2015 zzj. All rights reserved.
//

import UIKit

class BeaconSearchViewController: UIViewController,UITableViewDelegate {

    var sectionArrayDataSource:ArrayDataSource!
    var detectedBeacons = [CLBeacon](){
        didSet{
            updateDetectedBeacons()
        }
    }
    
    @IBOutlet weak var beaconSearchListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "managerSearchingUpdate", name: "UpdateSearchingBeaconResults", object: nil)
        XBeaconManager.sharedManager.startRanging()
        setupTableView()
    }

    func setupTableView() {
        
        let configCell:TableViewCellConfigureClosure = {
            if let sectionCell = $0 as? SearchedBeaconCell {
                sectionCell.configForSelection($1)
            }else{
                fatalError("The Cell is Not SecitonCell!")
            }
        }
        
        let items:[AnyObject] = (XBeaconManager.sharedManager.beacons != nil) ? XBeaconManager.sharedManager.beacons! : [CLBeacon]()
        detectedBeacons = (XBeaconManager.sharedManager.beacons != nil) ? XBeaconManager.sharedManager.beacons! : [CLBeacon]()
        sectionArrayDataSource = ArrayDataSource(items: items, cellIdentifier: "DetectedBeaconCell", configColsure: configCell)
        beaconSearchListTableView.dataSource = sectionArrayDataSource
        beaconSearchListTableView.delegate = self
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "CreateBeacon" {
            if let cell = sender as? SearchedBeaconCell {
                if let vc = segue.destinationViewController as? BeaconSettingViewController {
                    vc.beacon = cell.beacon
                }
            }
        }
    }
    
    func managerSearchingUpdate() {
        if let beacons = XBeaconManager.sharedManager.beacons {
            let filterBeacons = filteredBeacons(beacons)
            let removedIndexPath = indexPathOfRemovedBeacons(filterBeacons)
            let insertedIndexPath = indexPathOfInsertedBeacons(filterBeacons)
            detectedBeacons = filterBeacons
            beaconSearchListTableView.beginUpdates()
            if insertedIndexPath.count > 0 {
                beaconSearchListTableView.insertRowsAtIndexPaths(insertedIndexPath, withRowAnimation: .Fade)
            }
            if removedIndexPath.count > 0 {
                beaconSearchListTableView.deleteRowsAtIndexPaths(removedIndexPath, withRowAnimation: .Fade)
            }
            beaconSearchListTableView.endUpdates()
        }
    }
    
    func indexPathOfRemovedBeacons(beacons:[CLBeacon]) -> [NSIndexPath] {
        var indexPaths = [NSIndexPath]()
        let section = 0
        var row = 0
        for existingBeacon in detectedBeacons {
            var stillExists = false
            for beacon in beacons {
                if existingBeacon.major == beacon.major && existingBeacon.minor == beacon.minor && existingBeacon.proximityUUID == beacon.proximityUUID {
                    stillExists = true
                    break
                }
            }
            if !stillExists {
                indexPaths.append(NSIndexPath(forRow: row, inSection: section))
            }
            row++
        }
        return indexPaths
    }
    
    func indexPathOfInsertedBeacons(beacons:[CLBeacon]) -> [NSIndexPath] {
        var indexPaths = [NSIndexPath]()
        let section = 0
        var row = 0
        for beacon in beacons {
            var isNewBeacon = true
            for existingBeacon in detectedBeacons {
                if existingBeacon.major == beacon.major && existingBeacon.minor == beacon.minor && existingBeacon.proximityUUID == beacon.proximityUUID {
                    isNewBeacon = false
                    break
                }
            }
            if isNewBeacon {
                indexPaths.append(NSIndexPath(forRow: row, inSection: section))
            }
            row++
        }
        return indexPaths
    }
    
    func filteredBeacons(beacons:[CLBeacon]) -> [CLBeacon] {
        var filteredBeacons = beacons
        var lookup = Set<String>()
        for  i in 0..<beacons.count {
            let beacon = beacons[i]
            let id = "\(beacon.major)\(beacon.minor)\(beacon.proximityUUID)"
            if lookup.contains(id) {
                filteredBeacons.removeAtIndex(i)
            }else{
                lookup.insert(id)
            }
        }
        return filteredBeacons
    }
    
    func updateDetectedBeacons() {
        if let dataSource = sectionArrayDataSource {
            dataSource.items = detectedBeacons
        }
    }
    

    deinit {
        print("SearchNewBeaconController deinit")
    }
}
