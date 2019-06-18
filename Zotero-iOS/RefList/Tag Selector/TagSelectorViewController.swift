//
//  TagSelectorViewController.swift
//  Zotero-iOS
//
//  Created by Rohan Kadambi on 6/16/19.
//  Copyright © 2019 Rohan Kadambi. All rights reserved.
//

// NEED TO FIGURE OUT HOW TO PASS TAG COLLECTION BACK
import UIKit

class TagSelectorViewController: UIViewController,
    UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var TagTable: UITableView!
    var tagCollection : tagFilter = tagFilter(include: [], exclude: [])
    var alltags : [tagContents] = []
    var db : DatabaseMaster? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        // set up delegates
        TagTable.delegate = self
        TagTable.dataSource = self
        
        // if db is empty try and reinit
        if let _ = db {
            
        } else {
            let dbUrl = Bundle.main.url(forResource: "zotero", withExtension: "sqlite")!
            let dbPath = dbUrl.path
            db = DatabaseMaster(dbPath)
        }
        
        // getList of alltags
        alltags = db!.getAllTags()
        
        // correct any tag status
        for tag_inc in tagCollection.include{
            for tg in alltags{
                if(tg.id == tag_inc){
                    tg.state = 1
                }
            }
        }
        for tag_exc in tagCollection.exclude{
            for tg in alltags{
                if(tg.id == tag_exc){
                    tg.state = 2
                }
            }
        }
        // Resize Cells
        TagTable.estimatedRowHeight = 60
        TagTable.rowHeight = UITableView.automaticDimension

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
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "TagTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? TagTableViewCell  else {
            fatalError("The dequeued cell is not an instance of TagTableViewCell.")
        }
        cell.set(tag: alltags[indexPath.row])
        return cell
    }
    
    // Mark: Nav
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let content = alltags[indexPath.row]
        content.state = (content.state + 1) % 3
        switch content.state {
        case 0:
            tagCollection.removeExclude(tagID: content.id)
            tagCollection.removeInclude(tagID: content.id)
        case 1:
            tagCollection.addInclude(tagID: content.id)
        default:
            tagCollection.addExclude(tagID: content.id)
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
}
