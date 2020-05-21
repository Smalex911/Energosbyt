//
//  Ext+String.swift
//  Energosbyt
//
//  Created by Александр Смородов on 15.02.2020.
//  Copyright © 2020 Alex. All rights reserved.
//

import Foundation

extension String {
    
    var notEmptyValue: String? {
        let value = trimmingCharacters(in: .whitespaces)
        return value != "" ? value : nil
    }
    
    var onlyDecimalNumber: String {
        var characterSet = CharacterSet.decimalDigits
        characterSet.insert(charactersIn: ".")
        return replacingOccurrences(of: ",", with: ".").components(separatedBy: characterSet.inverted).joined()
    }
    
    var rubValue: Double? {
        guard let str = self.replacingOccurrences(of: "р.", with: "").replacingOccurrences(of: ",", with: ".").notEmptyValue else {
            return nil
        }
        return str.doubleValue
    }
    
    var doubleValue: Double? {
        return Double(self)
    }
    
    var intValue: Int? {
        return Int(self)
    }
}
