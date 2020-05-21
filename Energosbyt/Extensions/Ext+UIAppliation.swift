//
//  Ext+UIAppliation.swift
//  Energosbyt
//
//  Created by Александр Смородов on 17.02.2020.
//  Copyright © 2020 Alex. All rights reserved.
//

import UIKit

extension UIApplication {
    
    var mainWindow: UIWindow? {
        return UIApplication.shared.delegate?.window ?? nil
    }
    
    var rootViewController: UIViewController? {
        get { return mainWindow?.rootViewController }
        set { mainWindow?.rootViewController = newValue }
    }
    
}
