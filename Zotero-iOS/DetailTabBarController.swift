//
//  File.swift
//  Zotero-iOS
//
//  Created by Rohan Kadambi on 6/17/19.
//  Copyright © 2019 Rohan Kadambi. All rights reserved.
//

import Foundation
import UIKit

class DetailTabBarController: UITabBarController {
    
    var UUID : Int = -1
    var db: DatabaseMaster?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for viewController in viewControllers!{
            if let viewController = viewController as? RefDetailController{
                viewController.db = db
                viewController.UUID = UUID
            }

        }
    }
}
