//
//  Measures.swift
//  Energosbyt
//
//  Created by Александр Смородов on 16.02.2020.
//  Copyright © 2020 Alex. All rights reserved.
//

import Foundation
import SwiftSoup

class Measures {
    
    var measures: [Measure] = []
    
    init?(_ document: Document?) {
        guard let doc = document else {
            return nil
        }
        
        let tables = try? doc.select("table#single-header-example-1")
        
        if let tableMeasures = tables?.first(),
            let elements = try? tableMeasures.select("thead").first()?.select("tr").first()?.select("th") {
            
            let indexesDict = Measure.Attribute.indexesDict(elements)
            
            try? tableMeasures.select("tbody").first()?.select("tr.measure_tbl").forEach() { elems in
                let measureElems = try? elems.select("td").array()
                
                let measure = Measure()
                
                indexesDict.forEach {
                    measure.setValue(try? measureElems?[$1].text(), forAttribute: $0)
                }
                
                //добавить заполнение measureId
                
                measures.append(measure)
            }
        }
        
        if tables?.count ?? 0 > 1, let tableMeasuresHistory = tables?[1],
            let elements = try? tableMeasuresHistory.select("thead").first()?.select("tr").first()?.select("th") {
            
            //запоминаем историю передачи показаний в текущем месяце
        }
    }
}
