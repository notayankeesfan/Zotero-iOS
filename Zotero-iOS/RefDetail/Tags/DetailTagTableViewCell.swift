//
//  DetailTagTableViewCell.swift
//  Zotero-iOS
//
//  Created by Rohan Kadambi on 6/17/19.
//  Copyright © 2019 Rohan Kadambi. All rights reserved.
//

import UIKit

class DetailTagTableViewCell: UITableViewCell {

    
    @IBOutlet weak var tagNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
