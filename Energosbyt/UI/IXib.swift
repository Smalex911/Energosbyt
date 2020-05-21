//
//  IXib.swift
//  Energosbyt
//
//  Created by Александр Смородов on 19.02.2020.
//  Copyright © 2020 Alex. All rights reserved.
//

import UIKit

protocol IXib: UIView {
    
    var targetView: UIView! { get set }
    
    func commonInit()
}

extension IXib {
    
    func commonInit() {
        
        targetView = loadViewFromNib()
        targetView.frame = self.bounds
        self.addSubview(targetView)
        targetView.translatesAutoresizingMaskIntoConstraints = false
        targetView.backgroundColor = .clear
        self.backgroundColor = .clear
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[childView]|",
                                                      options: [],
                                                      metrics: nil,
                                                      views: ["childView": targetView as Any]))
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[childView]|",
                                                      options: [],
                                                      metrics: nil,
                                                      views: ["childView": targetView as Any]))
    }
    
    func loadViewFromNib() -> UIView? {
        
        let name = type(of: self).description().components(separatedBy: ".").last!
        return UINib(nibName: name, bundle: nil).instantiate(withOwner: self, options: nil).first as? UIView
    }
}
