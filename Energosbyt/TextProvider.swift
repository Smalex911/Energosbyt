//
//  TextProvider.swift
//  Energosbyt
//
//  Created by Александр Смородов on 16.02.2020.
//  Copyright © 2020 Alex. All rights reserved.
//

import Foundation

class TextProvider {
    
    static var rub: String {
        return "₽"
    }
    
    static func priceFormat(_ price: Double?, numberOfFraction: Int = 2) -> String {
        return price?.formattedString(numberOfFraction: numberOfFraction) ?? "–"
    }
    
    static func priceRub(_ price: Double?, numberOfFraction: Int = 2) -> String? {
        return price != nil ? (priceFormat(price, numberOfFraction: numberOfFraction) + " " + rub) : nil
    }
    
    static func balancePrefix(_ amount: Double?) -> String? {
        guard let amount = amount else { return nil }
        return amount > 0 ? "+" : nil
    }
    
    static func debt(_ amount: Double?, numberOfFraction: Int = 2) -> String? {
        return [balancePrefix(amount), priceRub(amount, numberOfFraction: numberOfFraction)].compactMap({$0}).joined(separator: " ")
    }
    
    static func consumption(_ consumption: Double?, numberOfFraction: Int = 2) -> String? {
        return consumption?.formattedString(numberOfFraction: numberOfFraction)
    }
    
    static func apiSumValue(_ amount: Double?) -> String? {
        return amount?.apiFormattedString()
    }
    
    static func paySum(_ amount: Double?, numberOfFraction: Int = 2) -> String? {
        return amount?.formattedString(numberOfFraction: numberOfFraction)
    }
}
