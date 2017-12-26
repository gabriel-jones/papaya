//
//  Request.swift
//  PrePacked
//
//  Created by Gabriel Jones on 10/27/17.
//  Copyright © 2017 Fireminds Ltd. All rights reserved.
//

import UIKit
import SwiftyJSON
/*
class HTTP {
    static var shared = HTTP()
    
    typealias ResponseHandler = (JSON, StatusCode) -> ()
    
    enum StatusCode: Int {
        case success = 0, unauthorised, other, userNotFound, emailRequired, passwordRequired, jsonBodyRequired, streetNameRequired, zipCodeRequired, addressIdRequired, addressNotFound, categoryNotFound, likeRequired, itemNotFound, nameTooLong, emailTooLong, emailExists, nameRequired, streetNameTooLong, zipCodeTooLong, listNotFound, listNameRequired, listNameTooLong, itemsRequired, quantityRequired, cartNotFound, replaceOptionRequired, replaceSpecificRequired, replaceOptionInvalid, itemIdRequired, phoneRequired, phoneTooLong, invalidEmail, notesTooLong
    }
    
    enum HTTPMethod: String {
        case get, post, put, delete
        
        var stringValue: String {
            get {
                return self.rawValue.uppercased()
            }
        }
    }
    
    func get(url urlString: String, parameters: [String: Any] = [:], authorise: Bool = true, completion: ResponseHandler? = nil) {
        self.http(url: urlString, httpMethod: .get, parameters: parameters, authorise: authorise, completion: completion)
    }
    
    func post(url urlString: String, body: [String: Any], authorise: Bool = true, completion: ResponseHandler? = nil) {
        self.http(url: urlString, httpMethod: .post, body: body, authorise: authorise, completion: completion)
    }
    
    func put(url urlString: String, body: [String: Any], authorise: Bool = true, completion: ResponseHandler? = nil) {
        self.http(url: urlString, httpMethod: .put, body: body, authorise: authorise, completion: completion)
    }
    
    func delete(url urlString: String, parameters: [String: Any] = [:], body: [String: Any] = [:], authorise: Bool = true, completion: ResponseHandler? = nil) {
        self.http(url: urlString, httpMethod: .delete, parameters: parameters, body: body, authorise: authorise, completion: completion)
    }
    
    private func handle(data: Data?, response: URLResponse?, error: Error?, completion: ResponseHandler?) {
        guard let data = data, error == nil else {
            print(error ?? String())
            completion?(JSON.null, .other)
            return
        }
        
        let json = JSON(data: data)
        let code = StatusCode(rawValue: json["code"].intValue) ?? .other
        
        if code == .unauthorised {
            // Handle
        }
        
        completion?(json, code)
    }
    
    private func addAuthorization(request: inout URLRequest) {
        /*if let token = User.current.auth_token {
            request.addValue(token, forHTTPHeaderField: "Authorization")
        }*/
    }
    
    private func http(url urlString: String, httpMethod method: HTTPMethod, parameters: [String: Any] = [:], body: [String: Any]? = nil, authorise: Bool, completion: ResponseHandler?) {
        var url = C.URL.main + urlString
        
        if !parameters.isEmpty {
            url += "?"
            for parameter in parameters {
                url += "\(parameter.0)=\(String(describing: parameter.1).addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics)!)&"
            }
            url.removeLast()
        }
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = method.stringValue
        
        if let body = body {
            request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.httpBody = try? JSON(body).rawData()
        }
        
        if authorise {
            addAuthorization(request: &request)
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.handle(data: data, response: response, error: error, completion: completion)
            }
        }.resume()
    }
}
*/
