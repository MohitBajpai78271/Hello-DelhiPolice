//
//  ProfileViewController.swift
//  ConstableOnPatrol
//
//  Created by Mac on 12/07/24.
//

import UIKit

class ProfileViewController: UIViewController, UITextFieldDelegate{
    
    @IBOutlet weak var NameOfPerson: UITextField!
    @IBOutlet weak var DateOfBirth: UITextField!
    @IBOutlet weak var MobileNo: UITextField!
    @IBOutlet weak var PoliceStation: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NameOfPerson.delegate = self
        DateOfBirth.delegate = self
        MobileNo.delegate = self
        PoliceStation.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
           textField.resignFirstResponder()
           return true
       }
}
