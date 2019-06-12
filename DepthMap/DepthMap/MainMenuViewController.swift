//
//  MainMenuViewController.swift
//  DepthMap
//
//  Created by joe rho on 5/30/19.
//  Copyright © 2019 joe rho. All rights reserved.
//

import UIKit

class MainMenuViewController: UIViewController {
    @IBOutlet weak var useExisitingButton: UIButton!
    @IBOutlet weak var newPhotoButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
//    @IBAction func useExistingButtonPressed(_ sender: Any) {
//        performSegue(withIdentifier: "useExisting", sender: self)
//    }
    
    
    // MARK: - Navigation

    //In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         //Get the new view controller using segue.destination.
         //Pass the selected object to the new view controller.
    }
 

}
