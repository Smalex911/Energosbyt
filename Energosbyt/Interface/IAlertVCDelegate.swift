//
//  IAlertVCDelegate.swift
//  Energosbyt
//
//  Created by Александр Смородов on 17.02.2020.
//  Copyright © 2020 Alex. All rights reserved.
//

import UIKit

protocol IAlertVCDelegate: UIViewController {
    
    func showAlert(title: String?, message: String?, buttonTitles: [String], checkedTitle: String?, destructiveTitle: String?, cancelTitle: String?, style: UIAlertController.Style, closeAction: ((_ buttonIndex: Int)->Void)?, destructiveAction: (()->Void)?, cancelAction: (()->Void)?)
}

extension IAlertVCDelegate {
    
    func showAlert(title: String? = nil, message: String? = nil, buttonTitles: [String] = [], checkedTitle: String? = nil, destructiveTitle: String? = nil, cancelTitle: String? = nil, style: UIAlertController.Style = .alert, closeAction: ((_ buttonIndex: Int)->Void)? = nil, destructiveAction: (()->Void)? = nil, cancelAction: (()->Void)? = nil) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
//        alert.view.tintColor = .alertTint
        
        for i in 0..<buttonTitles.count {
            let action = UIAlertAction(title: buttonTitles[i], style: .default) { (action) in
                closeAction?(i)
            }
            if checkedTitle == buttonTitles[i] {
                action.setValue(true, forKey: "checked")
            }
            alert.addAction(action)
        }
        
        if let destructiveTitle = destructiveTitle {
            alert.addAction(UIAlertAction(title: destructiveTitle, style: .destructive) { (action) in
                destructiveAction?()
            })
        }
        
        if let cancelTitle = cancelTitle {
            alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel) { (action) in
                cancelAction?()
            })
        }
        present(alert, animated: true, completion: nil)
    }
}
