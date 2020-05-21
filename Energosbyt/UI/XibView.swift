//
//  XibView.swift
//  Energosbyt
//
//  Created by Александр Смородов on 19.02.2020.
//  Copyright © 2020 Alex. All rights reserved.
//

import UIKit

class XibView: UIView, IXib {
    
    deinit {
        #if DEBUG
        print("\(type(of: self)) deinit")
        #endif
    }
    
    var targetView: UIView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        
        awakeFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
        
        awakeFromNib()
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        targetView.frame = self.bounds
    }
}
