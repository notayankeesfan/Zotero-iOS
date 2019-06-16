//
//  DatabaseMaster.swift
//  Zotero-iOS
//
//  Created by Rohan Kadambi on 6/15/19.
//  Copyright © 2019 Rohan Kadambi. All rights reserved.
//

import Foundation
import SQLite

struct refSummary{
    var UUID = ""
    var year = ""
    var author = ""
    var title = ""
    init(UUID : String, year : String, author : String, title: String){
        self.UUID = UUID
        self.year = year
        self.author = author
        self.title = title
    }
}


class DatabaseMaster{
    //Mark: Properties
    var conn : Connection
    
    // Collection Tables
    let collections = "collections"
    let collectionItems = "collectionItems"
    let libraries = "libraries"
    let groups = "groups"
    
    // Item Tables
    let items = "Items"
    let itemTags = "ItemTags"
    let itemData = "ItemData"
    
    // Reference Tables
    let fieldsCombined = "fieldsCombined"
    let itemDataValues = "ItemDataValues"
    let itemTypeFieldsCombined = "itemTypeFieldsCombined"
    let itemTypesCombined = "itemTypesCombined"
    
    // Column Names
    let collectionId = "collectionId"
    let collectionName = "collectionName"
    let libraryId = "libraryId"
    let libraryName = "libraryName"
    let itemId = "itemId"
    let parentcollectionId = "parentcollectionId"

    //Mark: Init
    init(_ dbPath: String){
        conn = try! Connection(dbPath, readonly: true)
    }
    
    //Mark: Methods
    func prepareRefList(library : Int, collection: Int, tagDict: [Int:[Int]], filterDict: Any, orderDict: Any) -> [refSummary]{
        // Determine which Collections are in this library
        var collectionArray = ["\(collection)"]
        let collection_query = """
                               SELECT \(collectionId), \(parentcollectionId) FROM \(collections)
                               WHERE \(libraryId) = \(library)
                               AND \(parentcollectionId) IS NOT NULL
                               """
        do{
            let stmt = try conn.run(collection_query)
            print(stmt)
            stmt.run
            var added = false
            for row in stmt {

                print(row)
                print(row[0])
//                if ( collectionArray.contains(row[1]!) && !collectionArray.contains(row[0]!)) {
//                    added = true
//                    collectionArray.append("\(row[0]!)")
//                }
            }
            
        } catch {
            print("c")
            fatalError("Query Failed")
        }
        
        let collectionList = collectionArray.joined(separator: ",")
        
        // Determine any additional nested collections
        
        if (collectionList.count != 0) {
            // Query items in collections (collectionItems Table)
            let collectionItems_query = """
                                        SELECT \(itemId) FROM \(collectionItems)
                                        WHERE \(collectionId) IN \(collectionList)
                                        """
        } else {
            // If there isn't a collection list deal with it
        }
        
        
        // Query items with tags (itemTags Table)
        
        // Query items meeting Filter Dict
        // THis might need to be a loop
        
        // Find inner join of the different sets
    
        return []
    }
    
    
    func prepareRefDetail(itemId: Int) -> Any{
        
        
        return [Int: [String]]()
    }
    //
}
