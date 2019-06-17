//
//  TagTableViewCell.swift
//  Zotero-iOS
//
//  Created by Rohan Kadambi on 6/16/19.
//  Copyright © 2019 Rohan Kadambi. All rights reserved.
//

import UIKit

class TagTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

class tagContents{
    var name : String
    var id : Int
    var state : Int
    init(name : String, id : Int){
        self.name = name
        self.id = id
        self.state = 0
    }
    
}
