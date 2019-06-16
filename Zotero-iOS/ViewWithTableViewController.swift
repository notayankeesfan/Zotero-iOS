//
//  ViewWithTableViewController.swift
//  Zotero-iOS
//
//  Created by Rohan Kadambi on 6/15/19.
//  Copyright © 2019 Rohan Kadambi. All rights reserved.
//

import UIKit
import SQLite

class ViewWithTableViewController: UIViewController,
    UITableViewDelegate, UITableViewDataSource{

    // MARK: - Table view data source
    // This Dictionary reprsents the table data source. it is a dictionary mapping UUIDs to an array of
    // [Doc Name, Year, formatted first author]
    var RefItemDict : [refSummary] = []
    
    // TableView to Control
    @IBOutlet weak var RefTable: UITableView!
    
    // Side Menu Properties
    var isVisibleSideMenu : Bool = false
    @IBOutlet weak var SideMenuLeadConstraint: NSLayoutConstraint!
    @IBOutlet weak var SideMenuWidth: NSLayoutConstraint!
    
    // DataBaseObject and related propereties
    var db : DatabaseMaster? = nil
    // The structure of these dicts is still up in the air, need to figure out how to manage this info
    var filterDict = [Int: [String]] ()
    var orderDict = [Int: [String]] ()
    var tagDict = [Int: [String]] ()
    var library = ""
    var collection = ""
    
    // Mark: Load
    override func viewDidLoad() {
        // Call Super
        super.viewDidLoad()
        
        // Assign Self as Delegate
        RefTable.delegate = self
        RefTable.dataSource = self
        
        // Init Gesture Recognizer on tableview
        let tap = UITapGestureRecognizer(target: self, action: #selector(tableTapped))
        RefTable.addGestureRecognizer(tap)
        
        // Connect to test database if current connection is nil
        if let _ = db {

        } else {
            let dbUrl = Bundle.main.url(forResource: "zotero", withExtension: "sqlite")!
            let dbPath = dbUrl.path
            db = DatabaseMaster(dbPath)
        }
        
        RefItemDict = (db!.prepareRefList(library: 1, collection: 16, tagList: tagFilter(include: [],exclude: [2z]), filterDict: 1, authorDict: 1, orderDict: 1))
        
        // Load Data
        //loadFakeData()
        
        
    }
    
    // Mark: Private Methods
    func loadFakeData(){
        RefItemDict.append(refSummary(UUID : 0, year : "2019", author : "A. Avery", title: "doc 0"))
        RefItemDict.append(refSummary(UUID : 1, year : "2018", author : "A. Avery", title: "doc 0"))
        RefItemDict.append(refSummary(UUID : 2, year : "2017", author : "A. Avery", title: "doc 0"))

    }
    
    // Mark: Public Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return RefItemDict.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "RefItemTableViewCell"

        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? RefItemTableViewCell  else {
            fatalError("The dequeued cell is not an instance of RefItemTableViewCell.")
        }
        
        let data = RefItemDict[indexPath.row]
        
        cell.ItemName.text = data.title
        cell.ItemYear.text = data.year
        cell.ItemAuthor.text = data.author
        
        return cell
    }
    
    // Mark: Nav
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (!isVisibleSideMenu) {
            let vc = storyboard?.instantiateViewController(withIdentifier: "RefDetailController") as? RefDetailController
            vc!.UUID = RefItemDict[indexPath.row].UUID
            vc!.documentTitle = RefItemDict[indexPath.row].title
            self.navigationController?.pushViewController(vc!, animated: true)
        }
        else{
            ToggleLeftMenu()
        }
    }
    
    //Mark: Actions
    
    @IBAction func LeftMenuPress(_ sender: Any) {
        ToggleLeftMenu()
    }
    
    func ToggleLeftMenu(){
        isVisibleSideMenu = !isVisibleSideMenu
        SideMenuLeadConstraint.constant = (!isVisibleSideMenu ? 1:0) * -SideMenuWidth.constant
    }
    
    @objc func tableTapped(tap:UITapGestureRecognizer) {
        let location = tap.location(in: RefTable)
        let path = RefTable.indexPathForRow(at: location)
        if let indexPathForRow = path {
            self.tableView(RefTable, didSelectRowAt: indexPathForRow)
        } else {
            if (isVisibleSideMenu) {
                ToggleLeftMenu()
            }
        }
    }
}
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
