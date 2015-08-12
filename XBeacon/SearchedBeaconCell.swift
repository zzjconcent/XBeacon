//
//  SearchedBeaconCell.swift
//  XBeacon
//
//  Created by zzj on 8/12/15.
//  Copyright © 2015 zzj. All rights reserved.
//

import UIKit

class SearchedBeaconCell: UITableViewCell {

    var beacon:CLBeacon!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configForSelection(item:AnyObject) {
        if let beacon = item as? CLBeacon {
            self.beacon = beacon
            textLabel?.text = "\(beacon.proximityUUID)"
            detailTextLabel?.text = "major\(beacon.major) minor\(beacon.minor) distance\(beacon.accuracy)"
        }
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
