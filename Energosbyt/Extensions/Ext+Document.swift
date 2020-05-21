//
//  Ext+Document.swift
//  Energosbyt
//
//  Created by Александр Смородов on 16.02.2020.
//  Copyright © 2020 Alex. All rights reserved.
//

import SwiftSoup

extension Document {
    
    var isAuthorized: Bool {
        return (try? select("button").contains(where: { $0.hasClass("slt-default dropdown-toggle") })) ?? false
    }
}
