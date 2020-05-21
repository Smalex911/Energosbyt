//
//  MeasureView.swift
//  Energosbyt
//
//  Created by Александр Смородов on 19.02.2020.
//  Copyright © 2020 Alex. All rights reserved.
//

import UIKit

class MeasureView: XibView {
    
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelLast: UILabel!
    @IBOutlet weak var labelCurrent: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    var measure: Measure? {
        didSet {
            labelTitle.text = measure?.tariffZone
            labelLast.text = TextProvider.consumption(measure?.lastMeasure)
            labelCurrent.text = TextProvider.consumption(measure?.currentMeasure)
            
            let hideInput = labelCurrent.text != nil
            labelCurrent.isHidden = !hideInput
            textField.isHidden = hideInput
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textField.keyboardType = .decimalPad
        textField.delegate = self
    }
}

extension MeasureView: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
