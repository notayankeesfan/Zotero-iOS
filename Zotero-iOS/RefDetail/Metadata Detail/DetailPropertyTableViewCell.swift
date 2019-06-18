//
//  DetailPropertyTableViewCell.swift
//  Zotero-iOS
//
//  Created by Rohan Kadambi on 6/16/19.
//  Copyright © 2019 Rohan Kadambi. All rights reserved.
//

import UIKit

class DetailPropertyTableViewCell: UITableViewCell {

    @IBOutlet weak var FieldLabel: UILabel!
    @IBOutlet weak var ContentLabel: UILabel!
   
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func set(contents: DetailPropertyCellContents){
        FieldLabel.text = contents.FieldName
        ContentLabel.text = contents.Expanded ? contents.Value : ""
        FieldLabel.font = UIFont.boldSystemFont(ofSize: 24.0)

    }
}

class DetailPropertyCellContents {
    var FieldName : String = ""
    var Value : String = ""
    var Expanded: Bool = true
    init(FieldName : String, Value: String){
        self.FieldName = FieldName
        self.Value = Value
    }
}
