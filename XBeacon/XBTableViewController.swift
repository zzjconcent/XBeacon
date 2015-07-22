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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "openWebSite", name: "openWebSite", object: nil)
    }

    func setupTableView() {
        
        let configCell:TableViewCellConfigureClosure = {
            $0.textLabel?.text = "\($1)"
        }
        
        let items:[AnyObject] = ["AntiLost","Region","Ranging"]
        sectionArrayDataSource = ArrayDataSource(items: items, cellIdentifier: "SectionCell", configColsure: configCell)
        tableView.dataSource = sectionArrayDataSource
        
    }
    
    func openWebSite() {
        performSegueWithIdentifier("OpenWebsite", sender: nil)
    }
    // MARK: - TableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.row {
        case 0:performSegueWithIdentifier("AntiLost", sender: nil)
        case 1:performSegueWithIdentifier("Region", sender: nil)
        case 2:performSegueWithIdentifier("Ranging", sender: nil)
        default:break
        }
    }
    
}
