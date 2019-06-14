//
//  ViewController.swift
//  Zotero-iOS
//
//  Created by Rohan Kadambi on 6/10/19.
//  Copyright © 2019 Rohan Kadambi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    //MARK: Params
    @IBOutlet weak var DocumentName: UITextField!
    @IBOutlet weak var DocumentUUID: UITextField!
    @IBOutlet weak var DocumentYear: UITextField!
    
    //MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        DocumentName.text = "Test Name"
    }

    //MARK: IBAction
    @IBAction func ButtonPressEdit(_ sender: Any) {
        // Debug
        print("Button Test")
        // Toggle if field is editable
        DocumentName.allowsEditingTextAttributes = !DocumentName.allowsEditingTextAttributes
    }
}

