//
//  URLRequest+Papaya.swift
//  Papaya
//
//  Created by Gabriel Jones on 12/23/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import Foundation
import SwiftyJSON

extension URLRequest {
    
    mutating func setAuthorisation(token: String) {
        self.setValue(token, forHTTPHeaderField: "Authorization")
    }
    
    private mutating func setUserAgent() {
        self.setValue(Config.shared.userAgent, forHTTPHeaderField: "User-Agent")
    }
    
    mutating func setContentType() {
        self.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
    }
    
    static func get(path: String, urlParameters: [String:String] = [:]) -> URLRequest? {
        return self.build(path: path, method: .get, urlParameters: urlParameters, body: [:])
    }
    
    static func post(path: String, body: [String:Any] = [:], urlParameters: [String:String] = [:]) -> URLRequest? {
        return self.build(path: path, method: .post, urlParameters: urlParameters, body: body)
    }
    
    static func put(path: String, body: [String:Any] = [:], urlParameters: [String:String] = [:]) -> URLRequest? {
        return self.build(path: path, method: .put, urlParameters: urlParameters, body: body)
    }
    
    static func patch(path: String, body: [String:Any] = [:], urlParameters: [String:String] = [:]) -> URLRequest? {
        return self.build(path: path, method: .patch, urlParameters: urlParameters, body: body)
    }
    
    static func delete(path: String, body: [String:Any] = [:], urlParameters: [String:String] = [:]) -> URLRequest? {
        return self.build(path: path, method: .delete, urlParameters: urlParameters, body: body)
    }
    
    static private func build(path: String, method: Request.HTTPMethod, urlParameters: [String:String], body: [String: Any]) -> URLRequest? {
        let parameters = urlParameters.urlQueryString
        let urlWithParameters = parameters.isEmpty ? path : path + "?" + parameters
        guard let url = URL(string: C.URL.main + urlWithParameters) else {
            return nil
        }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = method.rawValue
        request.setUserAgent()
        
        if let token = AuthenticationStore.token {
            request.setAuthorisation(token: token)
        }
        
        if !body.isEmpty {
            do {
                request.httpBody = try JSON(body).rawData()
                request.setContentType()
            } catch {
                print("Could not construct HTTP body")
            }
        }
        
        return request
    }
}
