//
//  ViewController.swift
//  Zotero-iOS
//
//  Created by Rohan Kadambi on 6/10/19.
//  Copyright © 2019 Rohan Kadambi. All rights reserved.
//

import UIKit

class RefDetailController: UIViewController,
        UITableViewDelegate, UITableViewDataSource{

    //MARK: Params
    @IBOutlet weak var ContentsTable: UITableView!
    
    var db : DatabaseMaster? = nil
    var UUID : Int = -1
    var fieldList : [DetailPropertyCellContents] = []
    
    //MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Connect to Table
        ContentsTable.delegate = self
        ContentsTable.dataSource = self
        
        
        // Load data
        fieldList = db!.prepareRefDetail(UUID: UUID)
        // Load Tag
        
        
        // Resize Cells
        ContentsTable.estimatedRowHeight = 60
        ContentsTable.rowHeight = UITableView.automaticDimension
        
        ContentsTable.tableFooterView = UIView()

    }

    //MARK: IBAction
    @IBAction func ButtonPressEdit(_ sender: Any) {
        // Debug
        print("Button Test")
        // Toggle if field is editable
    }
    
    
    // Mark: Public Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        //TBD
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // TBD
        return fieldList.count
    }
    
    
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

