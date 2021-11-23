//
//  studentController.swift
//  TestPhase1
//
//  Created by Nilu Technologies 1 on 26/10/21.
//

import UIKit

class studentController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

   

}
class student: studentController {
    var name:String
    var number:String
    
    init(name:String,number:String) {
        self.name = name
        self.number = number
        super.init(nibName: nil, bundle: nil)
    }
        func doHomeWork() {
               print(name)
           }

    
  //  var stu = student(coder: NSCoder)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
