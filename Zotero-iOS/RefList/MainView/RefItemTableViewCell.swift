//
//  RefItemTableViewCell.swift
//  Zotero-iOS
//
//  Created by Rohan Kadambi on 6/13/19.
//  Copyright © 2019 Rohan Kadambi. All rights reserved.
//

import UIKit

class RefItemTableViewCell: UITableViewCell {

    //Mark: Properties

    @IBOutlet weak var ItemName: UILabel!
    @IBOutlet weak var ItemYear: UILabel!
    @IBOutlet weak var ItemAuthor: UILabel!
    
    
    //Mark: Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
