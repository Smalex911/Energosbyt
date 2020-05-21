//
//  HttpRpc.swift
//  Energosbyt
//
//  Created by Александр Смородов on 15.02.2020.
//  Copyright © 2020 Alex. All rights reserved.
//

import Foundation
import Alamofire
import SwiftSoup

class HttpRpc {
    
    let kCookies = "kCookies"
    
    func storeCookies() {
        let cookieDict = HTTPCookieStorage.shared.cookies?.reduce([String : AnyObject](), { (res, cookie) -> [String : AnyObject] in
            var res = res
            res[cookie.name] = cookie.properties as AnyObject?
            return res
        })
        
        UserDefaults.standard.set(cookieDict, forKey: kCookies)
    }
    
    func restoreCookies() {
        UserDefaults.standard.dictionary(forKey: kCookies)?.forEach() { args in
            if let cookie = HTTPCookie(properties: args.value as! [HTTPCookiePropertyKey : Any] ) {
                HTTPCookieStorage.shared.setCookie(cookie)
            }
        }
    }
    
    func call(url: URL, method: HTTPMethod, headers: HTTPHeaders, parameters: Parameters? = nil, encoding: ParameterEncoding = URLEncoding.default, redirect: ((URLRequest?)->Void)? = nil, completion: @escaping ((DataResponse<String>?)->Void)) {
        
        Alamofire.SessionManager.default.delegate.taskWillPerformHTTPRedirectionWithCompletion = { _, _, _, request, _ in
            
            redirect?(request)
            return
        }
        
        Alamofire.SessionManager.default.requestWithoutCache(url, method: method, parameters: parameters, encoding: encoding, headers: headers).validate().responseString { [weak self] data in
            
            #if DEBUG
            self?.debugDataResponse(data)
            #endif
            
            self?.storeCookies()
            
            switch data.result {
            case .success(_):
                completion(data)
                break
            case .failure(_):
                print(data.error?.localizedDescription ?? "error")
                completion(nil)
                break
            }
        }
    }
    
    private func debugDataResponse<T>(_ response: DataResponse<T>) {
        
        let url = "\(response.request?.url?.scheme ?? "")://\(response.request?.url?.host ?? "")\(response.request?.url?.path ?? "")"
        let method = response.request?.httpMethod ?? ""
        var bodyStr = response.request?.url?.query?.removingPercentEncoding
        if let data = response.request?.httpBody {
            bodyStr = String(data: data, encoding: .utf8)?.removingPercentEncoding
        }
        var headersStr: String?
        if let headers = response.request?.allHTTPHeaderFields,
            JSONSerialization.isValidJSONObject(headers),
            let data = try? JSONSerialization.data(withJSONObject: headers, options: []) {
            headersStr = String(data: data, encoding: .utf8)
        }
        
        var logStr = ""
        if response.result.isSuccess {
            logStr += "<<< BEGIN SUCCESS <<<"
        } else {
            logStr += "<<< BEGIN ERROR <<<"
        }
        logStr += "\nRequest method: \(method)"
        logStr += "\nRequest url: \(url)"
        logStr += (bodyStr != nil ? "\nRequest body: \(bodyStr ?? "")": "")
        logStr += "\nResponse code: \(response.response?.statusCode ?? (response.error as NSError?)?.code ?? 0)"
        logStr += "\nRequest headers: \(headersStr ?? "")"
        if response.result.isSuccess {
            logStr += "\n>>> END SUCCESS >>>"
        } else {
            logStr += "\nResponse error: \(response.error?.localizedDescription ?? "")"
            logStr += "\n>>> END ERROR >>>"
        }
        
        print(logStr)
        
    }
}
