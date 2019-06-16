//
//  DatabaseMaster.swift
//  Zotero-iOS
//
//  Created by Rohan Kadambi on 6/15/19.
//  Copyright © 2019 Rohan Kadambi. All rights reserved.
//

import Foundation
import SQLite


class DatabaseMaster{
    //Mark: Properties
    var conn : Connection
    
    //Mark: Init
    init(_ dbPath: String){
        conn = try! Connection(dbPath, readonly: true)

    }
    
    //
}
