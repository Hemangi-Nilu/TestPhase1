//
//  ButtonViewController.swift
//  TestPhase1
//
//  Created by Nilu Technologies 1 on 11/11/21.
//

import UIKit

class ButtonViewController: UIViewController {

    @IBOutlet var btn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func btnSubmit(_ sender: UIButton) {
        print("tapp")
    }
    

}
