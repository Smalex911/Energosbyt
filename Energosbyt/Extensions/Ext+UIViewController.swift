//
//  Ext+UIViewController.swift
//  Energosbyt
//
//  Created by Александр Смородов on 17.02.2020.
//  Copyright © 2020 Alex. All rights reserved.
//

import UIKit

extension UIViewController {
    
    var navBarHeight: CGFloat {
        return navigationController?.navigationBar.frame.height ?? 0
    }
    
    var tabBarHeight: CGFloat {
        return tabBarController?.tabBar.frame.size.height ?? 0
    }
    
    var statusBarHeight: CGFloat {
        return UIApplication.shared.statusBarFrame.size.height
    }
    
    var topBarHeight: CGFloat {
        return statusBarHeight + navBarHeight
    }
    
    var bottomBarHeight: CGFloat {
        if tabBarHeight > 0 {
            return tabBarHeight
        }
        return UIViewController.safeAreaInsets.bottom
    }
    
    static var safeAreaInsets: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return UIApplication.shared.mainWindow?.safeAreaInsets ?? UIEdgeInsets.zero
        }
        return UIEdgeInsets.zero
    }
    
}
