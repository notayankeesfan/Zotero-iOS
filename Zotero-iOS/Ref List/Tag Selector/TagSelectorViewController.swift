//
//  TagSelectorViewController.swift
//  Zotero-iOS
//
//  Created by Rohan Kadambi on 6/16/19.
//  Copyright © 2019 Rohan Kadambi. All rights reserved.
//

import UIKit

class TagSelectorViewController: UIViewController,
    UITableViewDelegate, UITableViewDataSource{
    
    var tagCollection : tagFilter = tagFilter(include: [], exclude: [])
    var alltags : [Int : String] = [:]
    var db : DatabaseMaster? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        //TBD
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // TBD
        return alltags.count
    }
    
    // Need to be implemented
    /*
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "DetailPropertyTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? DetailPropertyTableViewCell  else {
            fatalError("The dequeued cell is not an instance of DetailPropertyTableViewCell.")
        }
        cell.set(contents: fieldList[indexPath.row])
        return cell
    }
    
    // Mark: Nav
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let content = fieldList[indexPath.row]
        content.Expanded = !content.Expanded
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
 */



}
