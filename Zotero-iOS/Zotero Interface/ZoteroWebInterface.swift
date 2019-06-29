//
//  ZoteroWebInterface.swift
//  Zotero-iOS
//
//  Created by Rohan Kadambi on 6/28/19.
//  Copyright © 2019 Rohan Kadambi. All rights reserved.
//

import Foundation

struct ItemFromJSON{
    var id : Int
    var creators : Any
    // TBD
    
    init(JSON: [String: Any]){
        id = -1
        creators = -1
    }
}
class ZoteroWebInterface{
    // MARK: Methods
    // Connect to new Account
    // Get all items
    // Get one item
    // Get updated items
}
