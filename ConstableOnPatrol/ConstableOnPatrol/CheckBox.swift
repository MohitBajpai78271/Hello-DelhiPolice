//
//  CheckBox.swift
//  ConstableOnPatrol
//
//  Created by Mac on 10/07/24.
//

import UIKit

class CheckBox: UIButton {
    // Images
     let checkedImage = UIImage(named: "checkedImage")
    let uncheckedImage = UIImage(named: "uncheckedImage")
    // Bool property
    var isChecked: Bool = false {
        didSet {
            if isChecked {
                self.setImage(checkedImage, for: .normal)
            } else {
                self.setImage(uncheckedImage, for: .normal)
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.addTarget(self, action: #selector(buttonClicked(sender:)), for: .touchUpInside)
        self.isChecked = false
    }
    @objc func buttonClicked(sender: UIButton) {
                  if sender == self {
                      isChecked = !isChecked
                  }
              }
    }
