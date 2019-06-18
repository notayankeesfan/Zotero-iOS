//
//  DetailTagController.swift
//  Zotero-iOS
//
//  Created by Rohan Kadambi on 6/17/19.
//  Copyright © 2019 Rohan Kadambi. All rights reserved.
//

import UIKit

class DetailTagController:  UIViewController,
UITableViewDelegate, UITableViewDataSource {
    
    var tagList : [String] = []
    var UUID : Int = -1
    var db : DatabaseMaster?
    @IBOutlet weak var DetailTagTable: UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Delegates
        DetailTagTable.delegate = self
        DetailTagTable.dataSource = self
        
        // Prepare tagList
        tagList = db!.tagsForItem(UUID: UUID)
        
        // Do any additional setup after loading the view.
        DetailTagTable.tableFooterView = UIView()

    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        //TBD
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // TBD
        return tagList.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "DetailTagTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? DetailTagTableViewCell  else {
            fatalError("The dequeued cell is not an instance of DetailTagTableViewCell.")
        }
        cell.tagNameLabel.text = tagList[indexPath.row]
        return cell
    }
    
    // Mark: Nav
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
    }

}
