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

struct author_struct{
    var firstName : String = ""
    var lastName : String = ""
    var id : Int = -1
    
    init(firstName: String, lastName: String, id: Int){
        self.firstName = firstName
        self.lastName = lastName
        self.id = id
    }
    
    func formatName(style: Int) -> String {
        var name = ""
        switch style{
        case 0:
            name = "\(firstName) \(lastName)"
        default:
            name = "\(lastName), \(firstName)"
        }
        return name
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
        if(include.contains(tagID)){
            include.remove(at: include.firstIndex(of: tagID)!)
        }
    }
    
    func removeExclude(tagID: Int){
        if(exclude.contains(tagID)){
            exclude.remove(at: exclude.firstIndex(of: tagID)!)
        }
    }
}


class DatabaseMaster{
    //Mark: Properties
    var conn : Connection
    
    // Collection Tables
    let collections = "collections"
    let libraries = "libraries"
    let groups = "groups"
    let creators = "creators"
    let tags = "tags"


    // Item Tables
    let items = "Items"
    let itemTags = "ItemTags"
    let itemData = "ItemData"
    let collectionItems = "collectionItems"
    let itemCreators = "itemCreators"
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
    let fieldName = "fieldName"
    let name = "name"
    let firstName = "firstName"
    let lastName = "lastName"
    let creatorID = "creatorID"
    let orderIndex = "orderIndex"

    //FieldID Dict
    let fieldDict = ["title" : 110,
                     "date" : 14,]
    //Mark: Init
    init(_ dbPath: String){
        conn = try! Connection(dbPath, readonly: true)
    }
    
    //Mark: Methods
    func prepareRefList(library : Int, collection: Int, includeSub: Bool, tagList: tagFilter, filterDict: Any, authorDict: Any, orderDict: Any) -> [refSummary]{
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
        let authorDict : [Int: [author_struct]] = getAuthor(ID_List : validItemIDs, onlyFirst : true)

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
                if opt.count > 0 {
                    author = "\(opt[0].formatName(style: 0))"
                }
            }
            
            if let opt = yearDict[item] {
                year = String("\(opt)".suffix(4))
            }
            outputArray.append(refSummary(UUID: item, year: year, author: author , title: title))
        }
        return outputArray
    }
    

    
    
    func prepareRefDetail(UUID: Int) -> [DetailPropertyCellContents]{
        var propertyList : [DetailPropertyCellContents] = []
        // Select the Join of fields required with fields with data
        let query = """
                    SELECT
                    \(fieldsCombined).\(fieldName),
                    \(itemDataValues).\(value)
                    FROM \(fieldsCombined)
                    INNER JOIN \(itemData)
                    ON \(itemData).\(fieldID) = \(fieldsCombined).\(fieldID)
                    INNER JOIN \(itemDataValues)
                    ON \(itemData).\(valueID) = \(itemDataValues).\(valueID)
                    WHERE \(itemData).\(itemID) = \(UUID)
                    """
        do{
            let stmt = try conn.prepare(query)
            // TEMPORARY, Missing some sort of order
            for row in stmt {
                propertyList.append(DetailPropertyCellContents(FieldName: "\(row[0]!)", Value: "\(row[1]!)"))
            }
        } catch {
            fatalError()
        }
        
        // Iterate over and add to property list
        
        //Add Logic for Author
        // Something with an Insert at and then getting the first/only index and then joining with \n
        return propertyList
    }
    
    
    func tagsForItem(UUID : Int) -> [String]{
        var tagArray : [String] = []
        let query = """
                    SELECT \(tags).\(name) FROM \(itemTags)
                    JOIN \(tags)
                    On \(itemTags).\(tagID) = \(tags).\(tagID)
                    WHERE \(itemTags).\(itemID) = \(UUID)
                    """
        do{
            let stmt = try conn.prepare(query)
            for row in stmt {
                tagArray.append("\(row[0]!)")
            }
        } catch {
            fatalError()
        }
        return tagArray
    }
    
    func getAllTags() -> [tagContents]{
        var tag_array : [tagContents] = []
        // Set up query
        let query = """
                    SELECT Distinct \(itemTags).\(tagID), \(tags).\(name) FROM \(itemTags)
                    JOIN \(tags)
                    ON \(itemTags).\(tagID) = \(tags).\(tagID)
                    """
        do{
            let stmt = try conn.prepare(query)
            for row in stmt {
                tag_array.append(tagContents(name: "\(row[1]!)", id: getIntRow(row: row, ind: 0)))
            }
        } catch {
            fatalError()
        }
        return tag_array
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
    
    func getAuthor(ID_List : [Int], onlyFirst : Bool) -> [Int : [author_struct]]{
        // TBD
        var output : [Int : [author_struct]] = [:]
        for id in ID_List{
            output[id] = nil
        }
        // Iterate over UUID
        // Select Join on authors where ID = ID
        for id in ID_List{
            let query = """
                        SELECT \(creators).\(firstName), \(creators).\(lastName), \(creators).\(creatorID)
                        FROM \(itemCreators)
                        Join \(creators)
                        ON \(itemCreators).\(creatorID) = \(creators).\(creatorID)
                        WHERE \(itemCreators).\(itemID) = \(id)
                        \(onlyFirst ? "AND \(itemCreators).\(orderIndex) = 0" : "")
                        """
            do{
                let stmt = try conn.prepare(query)
                var temp : [author_struct] = []
                for (ind, row) in stmt.enumerated() {
                    if (onlyFirst ? ind == 0 : true) {
                        temp.append(author_struct(firstName: "\(row[0]!)", lastName: "\(row[1]!)", id: getIntRow(row: row, ind: 2)))
                    }
                    //output.append()
                }
                output[id] = temp
                // add itemids
            } catch {
                fatalError()
            }
        }
        return output
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
