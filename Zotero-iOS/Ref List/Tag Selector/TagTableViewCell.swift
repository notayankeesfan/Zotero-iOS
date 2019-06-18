//
//  TagTableViewCell.swift
//  Zotero-iOS
//
//  Created by Rohan Kadambi on 6/16/19.
//  Copyright © 2019 Rohan Kadambi. All rights reserved.
//

import UIKit

class TagTableViewCell: UITableViewCell {

    @IBOutlet weak var TagLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func set(tag : tagContents){
        TagLabel.text = tag.name
        switch tag.state {
        case 0:
            TagLabel.textColor = UIColor(hue: 360/360, saturation: 100/100, brightness: 0/100, alpha: 1.0) /* #000000 */
        case 1:
            TagLabel.textColor = UIColor(hue: 135/360, saturation: 100/100, brightness: 100/100, alpha: 1.0) /* #00ff3f */
        default:
            TagLabel.textColor =  UIColor(hue: 0/360, saturation: 100/100, brightness: 100/100, alpha: 1.0) /* #ff0000 */
        }
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
