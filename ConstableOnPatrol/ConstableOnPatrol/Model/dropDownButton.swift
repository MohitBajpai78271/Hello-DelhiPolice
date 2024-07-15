//
//  dropDownButton.swift
//  ConstableOnPatrol
//
//  Created by Mac on 13/07/24.
//

import UIKit

protocol dropDownButtonDelegate: AnyObject{
    func dropDownButton(_ button: dropDownButton,didSelectOption option: String)
    func dropDownButtonShowOptions(_ button : dropDownButton)
    func dropDownButtonHideOptions(_ button: dropDownButton)
}

class dropDownButton: UIButton{
    
    weak var delegate: dropDownButtonDelegate?
    weak var alertController : UIAlertController?//
    
    let button = UIButton()
    
    var options : [String] = []{
        didSet{
            
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        setupButton()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    private func setupButton() {
        button.addTarget(self, action: #selector(showOptions), for: .touchUpInside)
        addSubview(button)
        
        // You may want to set frame or constraints for button here
        button.frame = self.bounds
        button.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    @objc func showOptions(){
        
        let alertController = UIAlertController(title: "Select an Option", message: nil, preferredStyle: .actionSheet)
        
        for option in options{
            
            let action = UIAlertAction(title: option, style: .default){ [weak self] _ in
                self?.delegate?.dropDownButton(self!,didSelectOption: option)
            }
            alertController.addAction(action)
        }
        delegate?.dropDownButtonShowOptions(self)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController?.present(alertController, animated: true, completion: nil)
        }
           
        let tapgestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(dismissAlertController))
        alertController.view.superview?.addGestureRecognizer(tapgestureRecogniser)
}
    @objc func dismissAlertController() {
        delegate?.dropDownButtonHideOptions(self)
        // Dismiss the alert controller
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController?.dismiss(animated: true, completion: nil)
        }
    }
}
