//
//  Ext+Alamofire.swift
//  Energosbyt
//
//  Created by Александр Смородов on 15.02.2020.
//  Copyright © 2020 Alex. All rights reserved.
//

import Alamofire
import SwiftSoup

extension Session {
    
    @discardableResult
    open func requestWithoutCache(
        _ url: URLConvertible,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        headers: HTTPHeaders? = nil)
        -> DataRequest
    {
        var originalRequest: URLRequest?
        
        do {
            originalRequest = try URLRequest(url: url, method: method, headers: headers)
            originalRequest?.cachePolicy = .reloadIgnoringCacheData
            let encodedURLRequest = try encoding.encode(originalRequest!, with: parameters)
            return request(encodedURLRequest)
        } catch {
            return request(url, method: method, parameters: parameters, encoding: encoding, headers: headers)
        }
    }
}

extension AFDataResponse where Success == String {
    
    var preparedDocument: Document? {
        guard let html = value else {
            return nil
        }
        
        do {
           return try SwiftSoup.parse(html)
        } catch Exception.Error(_, let message) {
            print(message)
        } catch {
            print("error")
        }
        return nil
    }
}

extension HTTPHeaders {
    
    mutating func appendIfKeyNotExist(_ headers: HTTPHeaders) {
        headers.forEach { header in
            if !contains(header) {
                add(header)
            }
        }
    }
}
