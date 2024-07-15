//
//  SignInViwController.swift
//  ConstableOnPatrol
//
//  Created by Mac on 10/07/24.
//

import UIKit

class SignInViwController: UIViewController{
    
    @IBOutlet weak var MoblineNoTextField: UITextField!
    @IBOutlet weak var GenerateOTPView: UIButton!
    @IBOutlet weak var warningView: UIView!
    
    var numberIsCorrect : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MoblineNoTextField.delegate = self
        GenerateOTPView.tintColor = UIColor.lightGray
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @IBAction func GenerateOTPPressed(_ sender: UIButton) {
        if numberIsCorrect == false{
            warningView.isHidden = false
            Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
                self.warningView.isHidden = true
            }
        }else{
            
        }
    }
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        // Check if the updated text contains exactly 10 digits
        if updatedText.count == 10 && updatedText.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil {
            // Change button color to active (e.g., green)
            GenerateOTPView.tintColor = UIColor.blue
            numberIsCorrect = true
        } else {
            // Reset button color to default (e.g., gray)
            GenerateOTPView.tintColor = UIColor.gray
        }
        
        return true
    }
}

extension SignInViwController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
