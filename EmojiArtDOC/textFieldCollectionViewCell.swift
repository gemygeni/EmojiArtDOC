//
//  textFieldCollectionViewCell.swift
//  EmojiArt222
//
//  Created by AHMED GAMAL  on 1/11/20.
//  Copyright © 2020 AHMED GAMAL . All rights reserved.
//

import UIKit

class textFieldCollectionViewCell: UICollectionViewCell, UITextFieldDelegate {
    
    
    @IBOutlet weak var textField: UITextField!{
        didSet{
            textField.delegate = self
        }
    }
     
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    var resignationHandler : (()-> Void)?
    func textFieldDidEndEditing(_ textField: UITextField) {
       resignationHandler?()
    }
    
    
    
}
