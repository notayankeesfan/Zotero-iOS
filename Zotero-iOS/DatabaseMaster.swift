//
//  DatabaseMaster.swift
//  Zotero-iOS
//
//  Created by Rohan Kadambi on 6/15/19.
//  Copyright © 2019 Rohan Kadambi. All rights reserved.
//

import Foundation
import SQLite

/**
 - Tag: refSummary
 */
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

/**
 - Tag: authorStruct
 */
struct authorStruct{
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

/**
 - Tag: tagFilter
 */
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
/**
 - Tag: DatabaseMaster
 */
class DatabaseMaster{
    //Mark: Properties
    //SQLite Connection
    var conn : Connection
    
    // MARK: Data Tables
    let items = "items" // List of all items, what item type they are, what library they are in, sync status
    let libraries = "libraries" //List of all libraries, when they were last sync'd
    let groups = "groups" // Name of Group Libraries
    let collections = "collections" // List of all collections, sync status
    let creators = "creators" // List of all creators (authors)
    let tags = "tags" // List of all Tags
    let itemDataValues = "ItemDataValues" // List of different datavalues
    let itemTypes = "itemTypes" // List of different item types (define what fields should be used)
    let fields = "fields" // List of different fields


    // MARK: Relationship Tables
    let itemTags = "itemTags" // Tags associated with Items
    let itemData = "itemData" // Data associated with Items
    let collectionItems = "collectionItems" // Items in Collections (not 1:1 with items b/c of unfiled)
    let itemCreators = "itemCreators" // Creators associated with Items
    let itemTypeFields = "itemTypeFields" // What Fields are used for each itemType, what order should they display

    
    // MARK: Column Names
    let collectionID = "collectionID"
    let parentcollectionID = "parentcollectionID"
    let collectionName = "collectionName"
    let libraryID = "libraryID"
    let libraryName = "libraryName"
    let itemID = "itemID"
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

    //FieldID Dict: Quick Reference for fieldname to field id
    let fieldDict_id_lookup = ["title" : 110,
                               "date" : 14,]
    // MARK: Methods
    
    // MARK: Init
    init(_ dbPath: String){
        conn = try! Connection(dbPath, readonly: true)
    }
    
    //MARK: Query Data to Display
    /**
     This Method returns an array of <refSummary> Stucts which is used by the "RefList" View Controller to populate its table view with a list of all items meeting user chosen criteria. Includes functionality to return a list of items based on library, collection, tags, author (TBD), and general fitlers (TBD).
     
     - Parameter library: Library ID specifying where to pull items from
     - Parameter collection: Collection ID specifying where to pull items from
     - Parameter includeSub: Boolean specying where to include sub collections or not
     - Parameter tagList: [tagFilter](x-source-tag://tagFilter) Struct that specifies which tags to include or exclude
     - Parameter filterDict: TBD
     - Parameter authorDict: TBD
     - Parameter orderDict: TBD
     
     - Returns: [refSummary](x-source-tag://refSummary) Array
     
     - Tag: DatabaseMaster_prepareRefList
     */
    func prepareRefList(library : Int, collection: Int, includeSub: Bool, tagList: tagFilter, filterDict: Any, authorDict: Any, orderDict: Any) -> [refSummary]{
        // TODO: Implement General Filters
        // TODO: Implement Author Filters
        // TODO: Implement Output Order Control
        // TODO: Update collection to be an Optional
        
        // Empty Array that will hold final list of valid Item IDs that will be included in output
        var validItemIDs : [Int] = []
        
        // TODO: Move this logic to its own function
        // Neeed to narrow by library then by collection
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
        
        // Convert the final list of valid collections into a String separated by commas for use in SQL WHERE Clause
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
        
        // Create List of items include or excluded by filters
        // Any tags applied?
        let anyTagFilter = (tagList.include.count != 0) || (tagList.exclude.count != 0)
        // Initialize arrays to hold output
        var include_tag_item : [Int] = []
        var exclude_tag_item : [Int] = []
        // If Any Tags applied
        if(anyTagFilter){
            // If any to include, get list of those itemIDs which have a tag to include
            if tagList.include.count != 0 {
                // fill include_tag
                include_tag_item = getItemsWithTag(tagList: tagList.include)
            }
            
            // If any to exclude, get list of those itemIDs which have a tag to exclude
            if tagList.exclude.count != 0 {
                // fill exclude_tag
                exclude_tag_item = getItemsWithTag(tagList: tagList.exclude)
            }

        }
            
        // Query items meeting Filter Dict
        // THis might need to be a loop
        
        // Find intersection of the different lists of item Lists
        validItemIDs = valid_item_collection // Initialize the list of validIDs with the items that were in a valid collection
        // If there were any tag Include Filters intersect with that list
        if (tagList.include.count != 0) {
            validItemIDs = intersectItemLists(main: validItemIDs, secondary: include_tag_item, includeSecondary: true)
        }
        // If there were any tag Exclude Filters subtract that list
        if (tagList.exclude.count != 0) {
            validItemIDs = intersectItemLists(main: validItemIDs, secondary: exclude_tag_item, includeSecondary: false)
        }
        //TODO: Add Intersection for other Filter Types
        
        //TODO: Order Valid ItemIDs
        
        // Create Dicts mapping UUID --> title, year, author
        // These checks are done separately because 1) the author info is in a different table 2) allows some items to be missing some data.
        let titleDict : [Int: String] = populateDict(dataID: fieldDict_id_lookup["title"]!, IDList: validItemIDs)
        let yearDict : [Int: String] = populateDict(dataID: fieldDict_id_lookup["date"]!, IDList:validItemIDs)
        let authorDict : [Int: [authorStruct]] = getAuthor(IDList : validItemIDs, onlyFirst : true)

        // Create Array of refSummary Structs with UUID set to ItemIDs
        var outputArray : [refSummary] = []
        for item in validItemIDs {
            // Default Fields to Empty String
            var year = ""
            var author = ""
            var title = ""
            
            // If the title was found use it
            if let opt = titleDict[item] {
                title = "\(opt)"
            }
            
            // If an author was found use it
            if let opt = authorDict[item] {
                if opt.count > 0 {
                    author = "\(opt[0].formatName(style: 0))"
                }
            }
            
            // If a year was found use it
            if let opt = yearDict[item] {
                year = String("\(opt)".suffix(4))
            }
            outputArray.append(refSummary(UUID: item, year: year, author: author , title: title))
        }
        return outputArray
    }
    

    
    /**
     This Method returns an array of DetailPropopertyCellContents Structs which are used to display the detailed metadata of a given item
     
     - Parameter UUID: the itemID of the item of interest
     
     - Returns: [DetailPropertyCellContents](x-source-tag://) Array
     
     - Tag: DatabaseMaster_prepareRefDetail
     */
    func prepareRefDetail(UUID: Int) -> [DetailPropertyCellContents]{
        var propertyList : [DetailPropertyCellContents] = []
        //TODO: Update Query to join on itemType and itemTypeFields to get a dispaly order
        
        // Select the Join of fields required with fields with data
        let query = """
                    SELECT
                    \(fields).\(fieldName),
                    \(itemDataValues).\(value)
                    FROM \(fields)
                    INNER JOIN \(itemData)
                    ON \(itemData).\(fieldID) = \(fields).\(fieldID)
                    INNER JOIN \(itemDataValues)
                    ON \(itemData).\(valueID) = \(itemDataValues).\(valueID)
                    WHERE \(itemData).\(itemID) = \(UUID)
                    """
        do{
            let stmt = try conn.prepare(query)
            // Iterate over and add to property list
            for row in stmt {
                propertyList.append(DetailPropertyCellContents(FieldName: "\(row[0]!)", Value: "\(row[1]!)"))
            }
        } catch {
            fatalError()
        }
        
        // Separately get data for authors because thats in a different table
        let authorDict : [Int: [authorStruct]] = getAuthor(IDList : [UUID], onlyFirst : false)
        if let opt = authorDict[UUID] {
            if opt.count > 0 {
                var authorString = ""
                for author in opt{
                    authorString = "\(authorString)\n\(author.formatName(style: 0))"
                }
                //TODO: Update where in the display this should be
                propertyList.append(DetailPropertyCellContents(FieldName: "Author", Value: authorString))
            }
        }

        return propertyList
    }
    
    /**
     This Method returns an array of Strings listing the tags for a given item
     
     - Parameter UUID: the itemID of the item of interest
     
     - Returns: [String] Array
     
     - Tag: DatabaseMaster_tagsForItem
     */
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
    
    /**
     This Method returns an array of tagContents which are used in the TagController to keep track of which tags are selected
     
     - Returns: [tagContents](x-source-tag://) Array
     
     - Tag: DatabaseMaster_getAllTags
     */
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
    
    //MARK: Helper Functions
    /**
     This Method returns the integer representation of a specified index of a connection Statement Element
     
     - Parameter row: The statement element row in question
     - Parameter ind: The index of the row to be cast to int
     
     - Returns: Int value of the the row provided at the given index
     
     - Tag: DatabaseMaster_getIntRow
     */
    func getIntRow(row : Statement.Element, ind : Int) -> Int{
        return Int(row[ind]! as! Int64)
    }
    
    /**
     This Method returns a dictionary of Int -> String which represents a mapping from itemID to the string representation of some specified data field.
     
     - Parameter dataID: The fieldID of the field of interest
     - Parameter IDList: The list of IDs for which we would like to find this value for
     
     - Returns: Dictionary of Int -> String
     
     - Tag: DatabaseMaster_populateDict
     */
    func populateDict(dataID : Int, IDList : [Int] ) -> [Int : String]{
        var output : [Int : String] = [:]
        //I have no idea how this line works
        let IDListStr = IDList.map { String($0) }
        let query = """
        SELECT \(itemData).\(itemID), \(itemDataValues).\(value)
        FROM \(itemData)
        INNER JOIN \(itemDataValues)
        ON \(itemData).\(valueID) = \(itemDataValues).\(valueID)
        Where \(itemData).\(fieldID) = \(dataID)
        AND \(itemData).\(itemID) IN ( \(IDListStr.joined(separator: ", ")) )
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
    
    /**
     This Method returns a Dictionary mapping the specified IDs to an Array of Author Structs which contain the data about the authors of that item. Includes boolean to specify if only the "primary" author should be included.
     
     - Parameter IDList: The array of IDs for which we would like to find author(s) for
     - Parameter onlyFirst: Boolean representing if we want multiple Authors returned or just the "primary" one
     
     - Returns: Dictionary of Int -> Array of [authorStruct](x-source-tag://authorStruct)
     
     - Tag: DatabaseMaster_getAuthor
     */
    func getAuthor(IDList : [Int], onlyFirst : Bool) -> [Int : [authorStruct]]{
        var output : [Int : [authorStruct]] = [:]
        for id in IDList{
            output[id] = nil
        }
        // Iterate over UUID
        // Select Join on authors where ID = ID
        for id in IDList{
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
                var temp : [authorStruct] = []
                for (ind, row) in stmt.enumerated() {
                    if (onlyFirst ? ind == 0 : true) {
                        temp.append(authorStruct(firstName: "\(row[0]!)", lastName: "\(row[1]!)", id: getIntRow(row: row, ind: 2)))
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
    
    /**
     This Method returns a list of items in a given library and optionally a given collection. Includes option to include subdirectories of the specified library/collection
     
     - Parameter library: libraryID of the library of interest
     - Parameter collection: Optional collectionID of a collection in library
     - Parameter includeSub: Boolean specifying if sub-collections should be included
     
     - Returns: Array of Ints representing the valid itemIDs
     
     - Tag: DatabaseMaster_getItemsInCollections
     */
    func getItemsInCollections(library : Int, collection : Int?, includeSub: Bool) -> [Int]{
        //TODO: Write the function
        var itemList : [Int] = []
        var allCollectionList : [Int] = []
        var collectionList : [Int] = []
        var allParentCollectionList : [Int?] = []
        var directFlag = true // 3 of the different scenarios of libary-collection pairs can be handled the same way once the collections are defined. this makes it easier to determine them in a single conditional
        let collec_query = """
                           SELECT \(collectionID), \(parentcollectionID) FROM \(collections)
                           Where \(libraryID) = \(library)
                           """
        do{
            let collec_stmt = try conn.prepare(collec_query)
            for collec_row in collec_stmt {
                allCollectionList.append(getIntRow(row: collec_row, ind: 0))
                allParentCollectionList.append(Int(collec_row[1]! as! Int64))
            }
        } catch {
            fatalError()
        }
        
        if let collec = collection{
            // If a collection was specified
            if (includeSub){
                // If a collection was specified and includeSub was chosen
                directFlag = true
                collectionList.append(collec)
                var anyAddition = true
                while (anyAddition){
                    anyAddition = false
                    for (ind, col) in allCollectionList.enumerated() {
                        let current_parent = allParentCollectionList[ind]!
                        if(collectionList.contains(current_parent)){
                            anyAddition = true
                            collectionList.append(col)
                        }
                    }
                }
                
            } else {
                // If a collection was specified and includeSub was not chosen
                directFlag = true
                collectionList.append(collec)
            }
        } else{
            // If a collection was not specified
            if (includeSub){
                // If a collection was not specified and includeSub was chosen
                directFlag = true
                collectionList = allCollectionList

            } else {
                // If a collection was not specified and includeSub was not chosen
                directFlag = false
                collectionList = []
            }
        
        }
        
        if(directFlag){
            let collectionListStr = collectionList.map { String($0) }
            let item_query = """
                             SELECT \(itemID) FROM \(collectionItems)
                             WHERE \(libraryID) = \(library)
                             AND \(collectionID) IN (\(collectionListStr.joined(separator: ", ")))
                             """
            do{
                let item_stmt = try conn.prepare(item_query)
                for item_row in item_stmt {
                    itemList.append(getIntRow(row: item_row, ind: 0))
                }
            } catch {
                fatalError()
            }
        } else {
            
        }
        
        
        
        return itemList
    }
    
    /**
     This Method returns a list of itemIDs that have the specified Tags of Interest
     
     - Parameter tagList: Array of tagIDs
     
     - Returns: Array of Ints representing the itemIDs that have ANY of the Tags provided
     
     - Tag: DatabaseMaster_getItemsWithTag
     */
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

    /**
     This Method returns a list of itemIDs that are either in 1) the interesection of the two sets or 2) the subtraction of the secondary set from the primary. The conversion from Array to Set implicitly removes duplicates
     
     - Parameter main: Primary Array of Ints representing itemIDs
     - Parameter secondary: Secondary Array of Ints representing itemIDs
     - Parameter incldueSecondary: Boolean representing if "Intersection" or "Subtraction" logic should be used
     
     - Returns: Array of Ints representing the itemIDs that are part of the intersected/subtracted sets
     
     - Tag: DatabaseMaster_itersectItemLists
     */
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
}


