//
//  Ext+Double.swift
//  Energosbyt
//
//  Created by Александр Смородов on 16.02.2020.
//  Copyright © 2020 Alex. All rights reserved.
//

import Foundation

extension Double {
    
    mutating func inverse() {
        self = 0 - self
    }
    
    func formattedString(numberOfFraction: Int) -> String? {
        
        let nf = NumberFormatter()
        
        nf.minimumIntegerDigits = 1
        nf.minimumFractionDigits = numberOfFraction
        nf.maximumFractionDigits = numberOfFraction
        nf.decimalSeparator = ","
        
        nf.groupingSeparator = " "
        nf.numberStyle = .decimal
        
        return nf.string(from: NSNumber(value: self))
    }
    
    func apiFormattedString() -> String? {
        
        let nf = NumberFormatter()
        
        nf.minimumIntegerDigits = 1
        nf.minimumFractionDigits = 2
        nf.maximumFractionDigits = 2
        nf.decimalSeparator = "."
        
        nf.numberStyle = .decimal
        
        return nf.string(from: NSNumber(value: self))
    }
    
    func rounded(numberOfFraction: Int) -> Double {
        let divisor = pow(10, Double(numberOfFraction))
        return (self * divisor).rounded() / divisor
    }
}
