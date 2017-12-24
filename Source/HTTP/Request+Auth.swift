//
//  URLRequest+Papaya.swift
//  Papaya
//
//  Created by Gabriel Jones on 12/23/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import Foundation

extension URLRequest {
    
    private mutating func setAuthorisation(token: String) {
        self.setValue(token, forHTTPHeaderField: "Authorization")
    }
    
    private mutating func setUserAgent() {
        self.setValue(Config.shared.userAgent, forHTTPHeaderField: "User-Agent")
    }
    
    static func requestWithAuthorisation(path: String, method: Request.HTTPMethod, token: String) -> URLRequest? {
        guard let url = URL(string: C.URL.main + path) else {
            return nil
        }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = method.rawValue
        request.setUserAgent()
        
        return request
    }
}
