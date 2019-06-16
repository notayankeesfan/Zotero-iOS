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
    var UUID = -1
    var year = ""
    var author = ""
    var title = ""
    
    init(UUID : Int, year : String, author : String, title: String){
        self.UUID = UUID
        self.year = year
        self.author = author
        self.title = title
    }
}

class tagFilter {
    var include : [Int]
    var exclude : [Int]

    init(include : [Int], exclude : [Int]){
        self.include = include
        self.exclude = exclude
    }
    
    func addInclude(tagID: Int) {
        removeExclude(tagID: tagID)
        if(!include.contains(tagID)){
            include.append(tagID)
        }
    }
    
    func addExclude(tagID: Int) {
        removeInclude(tagID: tagID)
        if(!exclude.contains(tagID)){
            exclude.append(tagID)
        }
    }
    
    func removeInclude(tagID: Int){
        if(!include.contains(tagID)){
            include.remove(at: include.firstIndex(of: tagID)!)
        }
    }
    
    func removeExclude(tagID: Int){
        if(!exclude.contains(tagID)){
            exclude.remove(at: exclude.firstIndex(of: tagID)!)
        }
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
    let collectionID = "collectionID"
    let collectionName = "collectionName"
    let libraryID = "libraryID"
    let libraryName = "libraryName"
    let itemID = "itemID"
    let parentcollectionID = "parentcollectionID"
    let fieldID = "fieldID"
    let valueID = "valueID"
    let value = "value"
    let tagID = "tagID"

    //FieldID Dict
    let fieldDict = ["title" : 110,
                     "date" : 14,]
    //Mark: Init
    init(_ dbPath: String){
        conn = try! Connection(dbPath, readonly: true)
    }
    
    //Mark: Methods
    func prepareRefList(library : Int, collection: Int, tagList: tagFilter, filterDict: Any, authorDict: Any, orderDict: Any) -> [refSummary]{
        // May add boolean for include subdirs, curerntly coding to always include
        var validItemIDs : [Int] = []
        
        // Determine any additional nested collections
        // Determine which Collections are in this library
        var collectionArray = ["\(collection)"]
        let collection_query = """
                               SELECT \(collectionID), \(parentcollectionID) FROM \(collections)
                               WHERE \(libraryID) = \(library)
                               AND \(parentcollectionID) IS NOT NULL
                               """
        do{
            // Prepare SQL
            let stmt = try conn.prepare(collection_query)
        
            // Define Column Indexes in Output
            let collectionID_ind = 0
            let parentcollectionID_ind = 1
            
            //Check if any of the collections that are already in this library have a parentCollection that is already in collection array
            var anyAdded = true
            while(anyAdded){
                anyAdded = false
                for row in stmt {
                    let current_parent = "\(getIntRow(row: row, ind: parentcollectionID_ind))"
                    let current_collection = "\(getIntRow(row: row, ind: collectionID_ind))"
                    if(collectionArray.contains(current_parent)){
                        anyAdded = true
                        collectionArray.append("\(current_collection)")
                    }
                }
            }
            
        } catch {
            fatalError()
        }
        
        let collectionList = collectionArray.joined(separator: ", ")
        
        // Create List of all items who exist in a valid collection
        var valid_item_collection : [Int] = []
        let collectionItems_query = """
                                    SELECT \(itemID) FROM \(collectionItems)
                                    WHERE \(collectionID) IN (\(collectionList))
                                    """
        do{
            let stmt = try conn.prepare(collectionItems_query)
            // Iterate over stmt and add the itemID to a list
            for row in stmt {
                valid_item_collection.append(getIntRow(row: row, ind: 0))
            }
        } catch {
            fatalError()
        }
        
        // Query items with tags (itemTags Table)
        let anyTagFilter = (tagList.include.count != 0) || (tagList.exclude.count != 0)
        var include_tag_item : [Int] = []
        var exclude_tag_item : [Int] = []
        if(anyTagFilter){
            if tagList.include.count != 0 {
                // fill include_tag
                include_tag_item = getItemsWithTag(tagList: tagList.include)
            }
            
            if tagList.exclude.count != 0 {
                // fill exclude_tag
                exclude_tag_item = getItemsWithTag(tagList: tagList.exclude)
            }

        }
            
        // Query items meeting Filter Dict
        
        // THis might need to be a loop
        
        // Find intersection of the different sets
        //TEMPORARY REPLACE THIS with INTERSECTION LOGIC
        validItemIDs = valid_item_collection
        if (tagList.include.count != 0) {
            validItemIDs = intersectItemLists(main: validItemIDs, secondary: include_tag_item, includeSecondary: true)
        }
        if (tagList.exclude.count != 0) {
            validItemIDs = intersectItemLists(main: validItemIDs, secondary: exclude_tag_item, includeSecondary: false)
        }
        
        
        // Order Valid ItemIDs
        
        // Create Dicts mapping UUID --> year, author, title
        let titleDict : [Int: String] = populateDict(dataID: fieldDict["title"]!, ID_List: validItemIDs)
        let yearDict : [Int: String] = populateDict(dataID: fieldDict["date"]!, ID_List:validItemIDs)
        let authorDict : [Int: String] = [:]

        // Create Array of refSummary Structs with UUID set to ItemIDs and everything else defaulted
        var outputArray : [refSummary] = []
        for item in validItemIDs {
            var year = ""
            var author = ""
            var title = ""
            
            if let opt = titleDict[item] {
                title = "\(opt)"
            }
            
            if let opt = authorDict[item] {
                author = "\(opt)"
            }
            
            if let opt = yearDict[item] {
                year = String("\(opt)".suffix(4))
            }
            outputArray.append(refSummary(UUID: item, year: year, author: author , title: title))
        }
        return outputArray
    }
    

    
    
    func prepareRefDetail(itemId: Int) -> [String: String]{
        
        
        return [ : ]
    }
    
    
    //Mark: Utilitiy
    func getIntRow(row : Statement.Element, ind : Int) -> Int{
        return Int(row[ind]! as! Int64)
    }
    
    func populateDict(dataID : Int, ID_List : [Int] ) -> [Int : String]{
        var output : [Int : String] = [:]
        let query = """
        SELECT \(itemData).\(itemID), \(itemDataValues).\(value)
        FROM \(itemData)
        INNER JOIN \(itemDataValues)
        ON \(itemData).\(valueID) = \(itemDataValues).\(valueID)
        Where \(itemData).\(fieldID) = \(dataID)
        """
        do{
            let stmt = try conn.prepare(query)
            // Iterate over stmt and add the itemID to a list
            for row in stmt {
                output[getIntRow(row: row, ind: 0)] = "\(row[1]!)"
            }
        } catch {
            fatalError()
        }
        return output
    }
    
    func getAuthor(ID_List : [Int], onlyFirst : Bool) -> [Int : [String]]{
        
        return[:]
    }
    
    func getItemsWithTag(tagList : [Int]) -> [Int]{
        var itemIDs : [Int] = []
        var tagListStr : [String] = []
        for item in tagList{
            tagListStr.append("\(item)")
        }
        
        let query = """
                    SELECT DISTINCT \(itemID) FROM \(itemTags)
                    Where \(tagID) IN ( \(tagListStr.joined(separator: ", ")) )
                    """
        do{
            let stmt = try conn.prepare(query)
            for row in stmt {
                itemIDs.append(getIntRow(row: row, ind: 0))
            }
        } catch {
            fatalError()
        }
        return itemIDs
    }

}

func intersectItemLists(main : [Int], secondary : [Int], includeSecondary : Bool) -> [Int]{
    var combinedList : [Int] = []
    let setMain =  Set(main)
    let setSecondary = Set(secondary)
    if(includeSecondary) {
        combinedList = Array(setMain.intersection(setSecondary))
    } else {
        combinedList = Array(setMain.subtracting(setSecondary))
    }
    return combinedList
}
