//
//  ViewController.swift
//  Energosbyt
//
//  Created by Александр Смородов on 15.02.2020.
//  Copyright © 2020 Alex. All rights reserved.
//

import UIKit

class ViewController: UIViewController, IAlertVCDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var labelAccountNumberTitle: UILabel!
    @IBOutlet weak var labelAccountNumber: UILabel!
    
    @IBOutlet weak var labelContractNumberTitle: UILabel!
    @IBOutlet weak var labelContractNumber: UILabel!
    
    @IBOutlet weak var labelAddressTitle: UILabel!
    @IBOutlet weak var labelAddress: UILabel!
    
    @IBOutlet weak var labelFioTitle: UILabel!
    @IBOutlet weak var labelFio: UILabel!
    
    @IBOutlet weak var labelPhoneTitle: UILabel!
    @IBOutlet weak var labelPhone: UILabel!
    
    @IBOutlet weak var labelEmailTitle: UILabel!
    @IBOutlet weak var labelEmail: UILabel!
    
    //Debt
    
    @IBOutlet weak var labelDebtTitle: UILabel!
    
    @IBOutlet weak var labelElectricityDebtTitle: UILabel!
    @IBOutlet weak var labelElectricityDebt: UILabel!
    
    @IBOutlet weak var labelElectricitySoiDebtTitle: UILabel!
    @IBOutlet weak var labelElectricitySoiDebt: UILabel!
    
    @IBOutlet weak var labelTotalDebtTitle: UILabel!
    @IBOutlet weak var labelTotalDebt: UILabel!
    
    //Measures
    
    @IBOutlet weak var labelMeasuresTitle: UILabel!
    @IBOutlet weak var stackViewMeasures: UIStackView!
    @IBOutlet weak var buttonSendMeasures: UIButton!
    
    //Pay
    
    @IBOutlet weak var labelPayTitle: UILabel!
    
    @IBOutlet weak var labelPayElectricityTitle: UILabel!
    @IBOutlet weak var textFieldPayElectricity: UITextField!
    
    @IBOutlet weak var labelPayElectricitySoiTitle: UILabel!
    @IBOutlet weak var textFieldPayElectricitySoi: UITextField!
    
    @IBOutlet weak var labelPaySendEmailChequeTitle: UILabel!
    @IBOutlet weak var switchPaySendEmailCheque: UISwitch!
    
    @IBOutlet weak var buttonPay: UIButton!
    
    var keyboardHandler: KeyboardBehaviorHandler?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        keyboardHandler = KeyboardBehaviorHandler(scrollView: scrollView, bottomOffset: bottomBarHeight, needHideByTap: true)
        
        labelAccountNumberTitle.text = "Лицевой счет"
        labelContractNumberTitle.text = "Договор по электроэнергии"
        labelAddressTitle.text = "Адрес"
        labelFioTitle.text = "ФИО"
        labelPhoneTitle.text = "Телефон"
        labelEmailTitle.text = "Электронная почта"
        
        labelDebtTitle.text = "Переплата / задолжность"
        labelElectricityDebtTitle.text = "Электроэнергия"
        labelElectricitySoiDebtTitle.text = "Электроэнергия на СОИ"
        labelTotalDebtTitle.text = "Итого к оплате"
        
        labelMeasuresTitle.text = "Показания счетчиков электроэнергии"
        
        buttonSendMeasures.setTitle("Передать показания", for: .normal)
        
        labelPayTitle.text = "Оплата"
        labelPayElectricityTitle.text = "Электроэнергия"
        labelPayElectricitySoiTitle.text = "Электроэнергия на СОИ"
        labelPaySendEmailChequeTitle.text = "Присылать квитанцию на почту?"
        
        textFieldPayElectricity.keyboardType = .decimalPad
        textFieldPayElectricity.delegate = self
        
        textFieldPayElectricitySoi.keyboardType = .decimalPad
        textFieldPayElectricitySoi.delegate = self
        
        buttonPay.setTitle("Оплатить", for: .normal)
        
        updateUserInfoUI()
        updateMeasuresUI()
        
        ServiceLayer.shared.loadUserInfo() { [weak self] userInfo in
            DispatchQueue.main.async {
                self?.userInfo = userInfo
            }
        }
        
        ServiceLayer.shared.loadMeasures { [weak self] measures in
            DispatchQueue.main.async {
                self?.measures = measures
            }
        }
    }
    
    var userInfo: UserInfo? = ServiceLayer.shared.userInfo {
        didSet {
            updateUserInfoUI()
        }
    }
    
    func updateUserInfoUI() {
        labelAccountNumber.text = userInfo?.accountNumber
        labelContractNumber.text = userInfo?.contractNumber
        labelAddress.text = userInfo?.address
        labelFio.text = userInfo?.fio
        labelPhone.text = userInfo?.phone
        labelEmail.text = userInfo?.email
        
        labelElectricityDebt.text = TextProvider.debt(userInfo?.electricityDebt)
        labelElectricitySoiDebt.text = TextProvider.debt(userInfo?.electricitySoiDebt)
        labelTotalDebt.text = TextProvider.priceRub(0 - (userInfo?.totalDebt ?? 0))
        
        textFieldPayElectricity.text = ((userInfo?.electricityDebt ?? 0 < 0) ? TextProvider.paySum(0 - (userInfo?.electricityDebt ?? 0)) : nil) ?? "500,00"
        textFieldPayElectricitySoi.text = ((userInfo?.electricitySoiDebt ?? 0 < 0) ? TextProvider.paySum(0 - (userInfo?.electricitySoiDebt ?? 0)) : nil) ?? "0,00"
    }
    
    var measures: Measures? {
        didSet {
            updateMeasuresUI()
        }
    }
    
    func updateMeasuresUI() {
        
        stackViewMeasures.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let emptyView = UIView()
        stackViewMeasures.addArrangedSubview(emptyView)
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        stackViewMeasures.addConstraint(emptyView.heightAnchor.constraint(equalToConstant: 0))
        
        measures?.measures.forEach { measure in
            let measureView = MeasureView()
            measureView.measure = measure
            stackViewMeasures.addArrangedSubview(measureView)
        }
        
        buttonSendMeasures.isHidden = false
    }
    
    @IBAction func sendMeasureHandler(_ sender: Any) {
        
//        guard let measures = measures else {
//            return
//        }
//
//        ServiceLayer.shared.sendMeasures(measures) {
//
//        }
    }
    
    @IBAction func payHandler(_ sender: Any) {
        
        guard let electSum = textFieldPayElectricity.text?.rubValue, electSum >= 0, let electSoiSum = textFieldPayElectricitySoi.text?.rubValue, electSoiSum >= 0, electSum + electSoiSum > 0 else {
            return
        }
        
        buttonPay.isEnabled = false
        
        ServiceLayer.shared.payRequest(electSum: electSum, electSoiSum: electSoiSum, email: userInfo?.email, sendEmailCheque: switchPaySendEmailCheque.isOn) { [weak self] url in
            DispatchQueue.main.async {
                guard let _self = self else { return }
                _self.buttonPay.isEnabled = true
                
                if let url = url {
                    UIApplication.shared.open(url)
                }
            }
        }
    }
}

extension ViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
