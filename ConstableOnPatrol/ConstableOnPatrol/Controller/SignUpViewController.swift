//
//  SignUpViewController.swift
//  ConstableOnPatrol
//
//  Created by Mac on 10/07/24.
//

import UIKit

class SignUpViewController: UIViewController{
    
    @IBOutlet weak var MobileNoTextFieldSignUp: UITextField!
    @IBOutlet weak var GeneratedOTPOutlet: UIButton!
    @IBOutlet weak var warningLabel: UIView!
    
    var numberIsGood : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MobileNoTextFieldSignUp.delegate = self
        GeneratedOTPOutlet.tintColor = UIColor.gray
        
        checkBox()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissMyKeyboaed))
        view.addGestureRecognizer(tapGesture)
    }
    
    func checkBox(){
        let checkBoxSwitch = UISwitch(frame: CGRect(x: 10, y: 420, width: 3, height: 3))
        
        checkBoxSwitch.onTintColor = .clear
        checkBoxSwitch.thumbTintColor = .white
        checkBoxSwitch.tintColor = .lightGray
        checkBoxSwitch.layer.borderColor = UIColor.lightGray.cgColor
        checkBoxSwitch.layer.borderWidth = 1
        checkBoxSwitch.layer.cornerRadius = 16
        
        checkBoxSwitch.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
        
        self.view.addSubview(checkBoxSwitch)
        
    }
    
    @objc func switchValueChanged(_ sender: UISwitch){
        if sender.isOn{
            print("yes")
        }else{
            print("No")
        }
    }
    
    @objc func dismissMyKeyboaed(){
        view.endEditing(true)
    }
    
    @IBAction func GenerateOTPPressed(_ sender: UIButton) {
        
        if numberIsGood == false{
            warningLabel.isHidden = false
            Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
                self.warningLabel.isHidden = true
            }
        }else{
            
        }
        
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
           // Get the updated text
           let currentText = textField.text ?? ""
           let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
           
           // Check if the updated text contains exactly 10 digits
           if updatedText.count == 10 && CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: updatedText)) {
               numberIsGood = true
               GeneratedOTPOutlet.tintColor = UIColor.blue
           } else {
               GeneratedOTPOutlet.tintColor = UIColor.gray
           }
           
           return true
       }
}

extension SignUpViewController: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


