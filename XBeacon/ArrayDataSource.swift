//
//  ArrayDataSource.swift
//  Desk
//
//  Created by zzj on 7/16/15.
//  Copyright (c) 2015 ZZJ. All rights reserved.
//

import UIKit

typealias TableViewCellConfigureClosure = (cell:UITableViewCell, items:AnyObject) -> ()

class ArrayDataSource: NSObject,UITableViewDataSource {

    var items:[AnyObject]!
    var cellIdentifier:String!
    var configureCellClosure:TableViewCellConfigureClosure!
    
    init(items:[AnyObject], cellIdentifier:String, configColsure:TableViewCellConfigureClosure) {
        super.init()
        self.items = items
        self.cellIdentifier = cellIdentifier
        self.configureCellClosure = configColsure
    }
    
    internal func itemAtIndexPath(indexPath:NSIndexPath) -> AnyObject {
        return items[indexPath.row]
    }
    
    // MARK: - UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as UITableViewCell
        let item: AnyObject = itemAtIndexPath(indexPath)
        configureCellClosure(cell: cell, items: item)
        return cell
    }
    
}
