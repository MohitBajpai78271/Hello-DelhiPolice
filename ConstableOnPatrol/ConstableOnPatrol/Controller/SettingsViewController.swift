//
//  SettingsViewController.swift
//  ConstableOnPatrol
//
//  Created by Mac on 12/07/24.
//

import UIKit

class SettingsViewController: UIViewController{
    
    @IBOutlet weak var logOutOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logOutOutlet.layer.borderColor = UIColor.black.cgColor
        logOutOutlet.layer.borderWidth = 2.0
    }
    
    @IBAction func logoutPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: "logoutSegue", sender: self)
    }
}
