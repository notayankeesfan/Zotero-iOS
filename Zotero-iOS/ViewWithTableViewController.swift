//
//  ViewWithTableViewController.swift
//  Zotero-iOS
//
//  Created by Rohan Kadambi on 6/15/19.
//  Copyright © 2019 Rohan Kadambi. All rights reserved.
//

import UIKit

class ViewWithTableViewController: UIViewController,
    UITableViewDelegate, UITableViewDataSource{

    // MARK: - Table view data source
    // This Dictionary reprsents the table data source. it is a dictionary mapping UUIDs to an array of
    // [Doc Name, Year, formatted first author]
    var RefItemDict = [Int : [String]]()
    @IBOutlet weak var RefTable: UITableView!
    
    // Mark: Load
    override func viewDidLoad() {
        super.viewDidLoad()
        RefTable.delegate = self
        RefTable.dataSource = self
        
        // Load Data
        loadFakeData()
    }
    
    // Mark: Private Methods
    func loadFakeData(){
        RefItemDict[0] = ["doc 0", "2019", "A. Avery"]
        RefItemDict[1] = ["doc 1", "2018", "N. Cox"]
        RefItemDict[2] = ["doc 2", "2017", "R. Kadambi"]
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
        print("test")

        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? RefItemTableViewCell  else {
            fatalError("The dequeued cell is not an instance of RefItemTableViewCell.")
        }
        
        let data = RefItemDict[indexPath.row]
        
        cell.ItemName.text = data![0]
        cell.ItemYear.text = data![1]
        cell.ItemAuthor.text = data![2]
        
        
        
        return cell
    }
    
    // Mark: Nav
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "RefDetailController") as? RefDetailController
        vc!.UUID = indexPath.row
        self.navigationController?.pushViewController(vc!, animated: true)
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
    
}
