//
//  XBTableViewController.swift
//  XBeacon
//
//  Created by zzj on 7/20/15.
//  Copyright © 2015 zzj. All rights reserved.
//

import UIKit

class XBTableViewController: UITableViewController {

    var sectionArrayDataSource:ArrayDataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
    }

    func setupTableView() {
        
        let configCell:TableViewCellConfigureClosure = {
            $0.textLabel?.text = "\($1)"
        }
        
        let items:[AnyObject] = ["AntiLost","Region"]
        sectionArrayDataSource = ArrayDataSource(items: items, cellIdentifier: "SectionCell", configColsure: configCell)
        tableView.dataSource = sectionArrayDataSource
        
    }
    // MARK: - TableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.row {
        case 0:performSegueWithIdentifier("AntiLost", sender: nil)
        case 1:performSegueWithIdentifier("Region", sender: nil)
        default:break
        }
    }
    
}
