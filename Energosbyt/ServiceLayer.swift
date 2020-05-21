//
//  ServiceLayer.swift
//  Energosbyt
//
//  Created by Александр Смородов on 17.02.2020.
//  Copyright © 2020 Alex. All rights reserved.
//

import Foundation
import Alamofire

class ServiceLayer {
    
    var login = "72000103846"
    var phone = "89127815418"
    
    var baseURL = "https://lk.permenergosbyt.ru"
    
    var showUrl: URL {
        return URL(string: baseURL + "/personal/show")!
    }
    
    var commonHeaders: HTTPHeaders {
        return [
            "Upgrade-Insecure-Requests": "1",
            "Sec-Fetch-Dest": "document",
            "User-Agent": UIWebView(frame: .zero).stringByEvaluatingJavaScript(from: "navigator.userAgent") ?? "",
            "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9"
        ]
    }
    
    static var shared = ServiceLayer()
    
    var networkStorage = HttpRpc()
    
    let kUserInfo = "kUserInfo"
    
    var _userInfo: UserInfo?
    var userInfo: UserInfo? {
        get {
            if let userInfo = _userInfo {
                return userInfo
            }
            if let data = UserDefaults.standard.data(forKey: kUserInfo) {
                let userInfo = try? JSONDecoder().decode(UserInfo.self, from: data)
                _userInfo = userInfo
                return userInfo
            }
            return nil
        }
        set {
            _userInfo = newValue
            UserDefaults.standard.set(try? JSONEncoder().encode(newValue), forKey: kUserInfo)
        }
    }
    
    var loginLock = NSLock()
    
    func login(login: String, phone: String, completion: @escaping ((UserInfo?)->Void)) {
        
        let headers: HTTPHeaders = [
            "Origin": "https://lk.permenergosbyt.ru",
            "Content-Type": "application/x-www-form-urlencoded",
            ].merging(commonHeaders, uniquingKeysWith: { (current, _) in current })
        
        let parameters: Parameters = [
            "action": "login",
            "family": "",
            "login": login,
            "new_account_number": "",
            "phone": phone
        ]
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let _self = self else { return }
            
            if !_self.loginLock.try() {
                _self.loginLock.lock()
                
                DispatchQueue.main.async {
                    if let ui = _self.userInfo {
                        completion(ui)
                    } else {
                        _self.login(login: login, phone: phone, completion: completion)
                    }
                    _self.loginLock.unlock()
                }
            } else {
                
                DispatchQueue.main.async {
                    _self.networkStorage.call(url: _self.showUrl, method: .post, headers: headers, parameters: parameters) { data in
                        if let ui = UserInfo(data?.preparedDocument) {
                            _self.userInfo = ui
                            completion(ui)
                        } else {
                            completion(nil)
                        }
                        _self.loginLock.unlock()
                    }
                }
            }
        }
    }
    
    func loadUserInfo(completion: @escaping ((UserInfo?)->Void)) {
        
        networkStorage.call(url: showUrl, method: .get, headers: commonHeaders) { [weak self] data in
            guard let _self = self else { return }
            let document = data?.preparedDocument
            
            if document?.isAuthorized ?? false {
                if let ui = UserInfo(document) {
                    _self.userInfo = ui
                    completion(ui)
                } else {
                    completion(nil)
                }
            } else {
                _self.userInfo = nil
                _self.login(login: _self.login, phone: _self.phone, completion: completion)
            }
        }
    }
    
    func loadMeasures(completion: @escaping ((Measures?)->Void)) {
        
        let parameters: Parameters = [
            "action": "measures"
        ]
        
        networkStorage.call(url: showUrl, method: .get, headers: commonHeaders, parameters: parameters, encoding: URLEncoding.queryString) { [weak self] data in
            let document = data?.preparedDocument
            
            if document?.isAuthorized ?? false {
                completion(Measures(document))
            } else {
                guard let _self = self else { return }
                
                _self.userInfo = nil
                _self.login(login: _self.login, phone: _self.phone) { [weak _self] _ in
                    _self?.loadMeasures(completion: completion)
                }
            }
        }
    }
    
    func sendMeasures(_ measures: Measures, completion: @escaping (()->Void)) {
        
        let headers: HTTPHeaders = [
            "Origin": "https://lk.permenergosbyt.ru",
            "Content-Type": "application/x-www-form-urlencoded",
            ].merging(commonHeaders, uniquingKeysWith: { (current, _) in current })
        
        
        var parameters: Parameters = ["action": "measures"]
        
        for i in 0..<measures.measures.count {
            if let id = measures.measures[i].measureId {
                parameters["hiddenC\(i+1)"] = measures.measures[i].signsCount
                parameters["hiddenP\(i+1)"] = measures.measures[i].lastMeasure
                parameters["hiddenT\(i+1)"] = measures.measures[i].tariff
                parameters[id] = measures.measures[i].currentMeasure
            }
        }
        
        networkStorage.call(url: showUrl, method: .post, headers: headers, parameters: parameters, completion:
            { [weak self] data in
                let document = data?.preparedDocument
                
                if document?.isAuthorized ?? false {
                    completion()
                } else {
                    guard let _self = self else { return }
                    
                    _self.userInfo = nil
                    _self.login(login: _self.login, phone: _self.phone) { [weak _self] _ in
                        _self?.sendMeasures(measures, completion: completion)
                    }
                }
            }
        )
    }
    
    func payRequest(electSum: Double, electSoiSum: Double, email: String?, sendEmailCheque: Bool, completion: @escaping ((URL?)->Void)) {
        
        let headers: HTTPHeaders = [
            "Origin": "https://lk.permenergosbyt.ru",
            "Content-Type": "application/x-www-form-urlencoded",
            ].merging(commonHeaders, uniquingKeysWith: { (current, _) in current })
        
        let electSum = electSum.rounded(numberOfFraction: 2)
        let electSoiSum = electSoiSum.rounded(numberOfFraction: 2)
        let totalSum = electSum + electSoiSum
        
        if let pss1 = TextProvider.apiSumValue(electSum), let pss2 = TextProvider.apiSumValue(electSoiSum), let ps = TextProvider.apiSumValue(totalSum) {
            
            let parameters: Parameters = [
                "action": "pay",
                "email": email ?? "",
                "login": login,
                "payServiceSum_1": pss1,
                "payServiceSum_2": pss2,
                "paySum": ps,
                "select_cheque": sendEmailCheque ? "email" : "no",
                "serv_sep_count": "2",
                "serv_sep_idx_1": "on",
                "serv_sep_idx_2": "on",
                "serv_sep_kom_1": "0.00",
                "serv_sep_kom_2": "0.00",
                "serv_sep_sid_1": "1",
                "serv_sep_sid_2": "17",
                "serv_sep_sname_1": "Электроэнергия",
                "serv_sep_sname_2": "Электроэнергия на СОИ",
                "serv_sep_stype_1": "2",
                "serv_sep_stype_2": "2"
            ]
            
            networkStorage.call(url: showUrl, method: .post, headers: headers, parameters: parameters, redirect:
                { request in
                    completion(request?.url)
                }, completion:
                { [weak self] data in
                    let document = data?.preparedDocument
                    
                    if document?.isAuthorized ?? false {
                        completion(nil)
                    } else {
                        guard let _self = self else { return }
                        
                        _self.userInfo = nil
                        _self.login(login: _self.login, phone: _self.phone) { [weak _self] _ in
                            _self?.payRequest(electSum: electSum, electSoiSum: electSoiSum, email: email, sendEmailCheque: sendEmailCheque, completion: completion)
                        }
                    }
                }
            )
        }
    }
}
