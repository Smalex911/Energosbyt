//
//  Measure.swift
//  Energosbyt
//
//  Created by Александр Смородов on 19.02.2020.
//  Copyright © 2020 Alex. All rights reserved.
//

import Foundation
import SwiftSoup

class Measure {
    
    var tariffZone: String?
    var signsCount: Int?
    var counterNumber: String?
    var tariff: Double?
    var measureId: String?
    var lastMeasure: Double?
    var currentMeasure: Double?
    
    func setValue(_ value: String?, forAttribute attr: Attribute) {
        switch attr {
        case .tariffZone:
            tariffZone = value
            break
        case .signsCount:
            signsCount = value?.intValue
            break
        case .counterNumber:
            counterNumber = value
            break
        case .tariff:
            tariff = value?.doubleValue
            break
        case .measureId:
            measureId = value
            break
        case .lastMeasure:
            lastMeasure = value?.doubleValue
            break
        case .currentMeasure:
            currentMeasure = value?.doubleValue
            break
        }
    }
    
    enum Attribute {
        
        case tariffZone
        case signsCount
        case counterNumber
        case tariff
        case measureId
        case lastMeasure
        case currentMeasure
        
        static func indexesDict(_ elements: Elements) -> [Attribute: Int] {
            var dict = [Attribute: Int]()
            
            for i in 0..<elements.count {
                if let name = (try? elements[i].text())?.lowercased() {
                    
                    if name.contains("тарифная зона") {
                        dict[.tariffZone] = i
                    } else if name.contains("значность") {
                        dict[.signsCount] = i
                    } else if name.contains("номер счетчика") {
                        dict[.counterNumber] = i
                    } else if name.contains("тариф") {
                        dict[.tariff] = i
                    } else if name.contains("предыдущие показания") {
                        dict[.lastMeasure] = i
                    } else if name.contains("текущие показания") {
                        dict[.currentMeasure] = i
                        dict[.measureId] = i
                    }
                }
            }
            return dict
        }
    }
}
