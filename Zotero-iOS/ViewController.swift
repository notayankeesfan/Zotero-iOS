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
    @IBOutlet weak var DocumentName: UITextField!
    @IBOutlet weak var DocumentUUID: UITextField!
    @IBOutlet weak var DocumentYear: UITextField!
    @IBOutlet weak var ContentsTable: UITableView!
    
    var UUID : Int = -1
    var documentTitle : String = ""
    var fake_data = [ DetailPropertyCellContents(FieldName: "Name", Value: "Document Title is Something"),
                      DetailPropertyCellContents(FieldName: "Test 1", Value: "test 1 text"),
                      DetailPropertyCellContents(FieldName: "Year", Value: "2019"),
                      DetailPropertyCellContents(FieldName: "Abstractt", Value: "Document Title is SomethingDocument Title is                                                           SomethingDocument Title is SomethingDocument                                                           Title is SomethingDocument Title is Something")
                    ]
    
    //MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Connect to Table
        ContentsTable.delegate = self
        ContentsTable.dataSource = self
        
        ContentsTable.estimatedRowHeight = 60
        ContentsTable.rowHeight = UITableView.automaticDimension
        
        // Do any additional setup after loading the view.
        DocumentName.text = "\(documentTitle)"
        DocumentUUID.text = "\(UUID)"
    }

    //MARK: IBAction
    @IBAction func ButtonPressEdit(_ sender: Any) {
        // Debug
        print("Button Test")
        // Toggle if field is editable
        DocumentName.allowsEditingTextAttributes = !DocumentName.allowsEditingTextAttributes
    }
    
    
    // Mark: Public Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        //TBD
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // TBD
        return fake_data.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "DetailPropertyTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? DetailPropertyTableViewCell  else {
            fatalError("The dequeued cell is not an instance of DetailPropertyTableViewCell.")
        }
        cell.set(contents: fake_data[indexPath.row])
        return cell
    }
    
    // Mark: Nav
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let content = fake_data[indexPath.row]
        content.Expanded = !content.Expanded
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

