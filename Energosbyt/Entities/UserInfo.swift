//
//  UserInfo.swift
//  Energosbyt
//
//  Created by Александр Смородов on 15.02.2020.
//  Copyright © 2020 Alex. All rights reserved.
//

import Foundation
import SwiftSoup

class UserInfo: Codable {
    
    var accountNumber: String?
    var contractNumber: String?
    var address: String?
    var fio: String?
    var phone: String?
    var email: String?
    
    var electricityDebt: Double?
    var electricitySoiDebt: Double?
    var totalDebt: Double?
    
    
    init() { }
    
    init?(_ document: Document?) {
        guard let doc = document else {
            return nil
        }
        
        let elements = try? doc.select("div").filter({ $0.hasClass("col-xs-12 col-sm-6") && !$0.children().contains(where: { (try? $0.iS("div")) ?? false }) })
        
        elements?.forEach({ (elem) in
            let child = elem.children()
            if child.count > 1 {
                if let key = try? child[0].text(), let val = try? child[1].text().notEmptyValue {
                    setProperty(name: key, value: val)
                }
            } else {
                if let el = child.first() {
                    if let key = try? el.children().first()?.text(), let val = (try? el.text())?.replacingOccurrences(of: key, with: "").notEmptyValue {
                        setProperty(name: key, value: val)
                    }
                }
            }
        })
        
        email = try? doc.select(".ic-email-val").first()?.text()
        
        let debt = try? doc.select("table").filter({ $0.hasClass("table table-xs-line") }).first
        
        try? debt?.select("tr").compactMap({ $0.children() }).forEach({ (elem) in
            if let key = try? elem.first(where: { $0.hasClass("text-left") })?.text(), let rightElem = elem.first(where: { $0.hasClass("text-right") }) {
                
                if let val = try? rightElem.text() {
                    setDebtProperty(name: key, value: val, pozitive: rightElem.hasClass("text-success"))
                }
            }
        })
    }
    
    func setProperty(name: String, value: String?) {
        let name = name.lowercased()
        
        if name.contains("лицевой счет") {
            accountNumber = value
        } else if name.contains("договор по электроэнергии") {
            contractNumber = value
        } else if name.contains("адрес") {
            address = value
        } else if name.contains("фио") {
            fio = value
        } else if name.contains("телефон") {
            phone = value
        }
    }
    
    func setDebtProperty(name: String, value: String?, pozitive: Bool) {
        let name = name.lowercased()
        var value = value?.rubValue
        
        if !pozitive {
            value?.inverse()
        }
        
        if name.contains("сои") {
            electricitySoiDebt = value
        } else if name.contains("итог") {
            totalDebt = value
        } else if name.contains("электроэнергия") {
            electricityDebt = value
        }
    }
}
