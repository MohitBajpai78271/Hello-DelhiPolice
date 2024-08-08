//
//  SignUpViewController.swift
//  ConstableOnPatrol
//
//  Created by Mac on 10/07/24.
//

import UIKit


struct OTPResponse2: Decodable {
    let success: Bool
    let msg: String
}

class SignUpViewController: UIViewController{
    
    @IBOutlet weak var MobileNoTextFieldSignUp: UITextField!
    @IBOutlet weak var GeneratedOTPOutlet: UIButton!
    @IBOutlet weak var warningLabel: UIView!
    
    let alertHelper = AlertManager.shared
    
    var numberIsGood : Bool = false
    private var isAlertPresented = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextField()
    
        GeneratedOTPOutlet.tintColor = UIColor.gray
        checkBox()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissMyKeyboaed))
        view.addGestureRecognizer(tapGesture)
    }
    func setupTextField(){
        MobileNoTextFieldSignUp.delegate = self
        MobileNoTextFieldSignUp.autocorrectionType = .no
    }
    
    @objc func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
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
        UserDefaults.standard.set(sender.isOn, forKey: "TermsAgreed")
    }
    
    @objc func dismissMyKeyboaed(){
        view.endEditing(true)
    }
    
    @IBAction func GenerateOTPPressed(_ sender: UIButton) {
        
        let termsAgreed = UserDefaults.standard.bool(forKey: "TermsAgreed")
        
    
        guard let phoneNumber = MobileNoTextFieldSignUp.text, !phoneNumber.isEmpty else {
            
            return
        }
     
        if !termsAgreed {
              
              if let presentedVC = self.presentedViewController {
                  presentedVC.dismiss(animated: false, completion: {
                      self.showTermsAgreementAlert()
                  })
              } else {
                  showTermsAgreementAlert()
              }
              return
          }
        
        if numberIsGood == false{
            warningLabel.isHidden = false
            Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
                self.warningLabel.isHidden = true
            }
        }else{
           
            UserDefaults.standard.removeObject(forKey: "userPhoneNumber")
            UserDefaults.standard.set(phoneNumber,forKey: "phoneNumberSignUp")
            UserDefaults.standard.synchronize()
            
            UserData.shared.isSignup = true
            let fullphoneNumber = "+91\(phoneNumber)"
            
            AuthService.shared.getOTP(phoneNumber: fullphoneNumber) { response, error in
                DispatchQueue.main.async{
                    if let error = error {
                        self.alertHelper.showAlert(on: self, message: "Failed to generate OTP: \(error.localizedDescription)")
                        return
                    }
                    if let response = response {
                        self.performSegue(withIdentifier: K.signupSegue, sender: fullphoneNumber)
                        self.alertHelper.showAlert(on: self, message: response.msg)
                    }
                }
            }
            
        }
    }

    func showTermsAgreementAlert(){
        let alert = UIAlertController(title: "Terms Agreement Required", message: "You must agree to our terms and condition to proceed", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert,animated: true,completion: nil)
    }
}

extension SignUpViewController: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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


