//
//  Request+User.swift
//  Papaya
//
//  Created by Gabriel Jones on 12/23/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import Foundation
import SwiftyJSON

extension Request {
    @discardableResult
    func getUserDetails(completion: @escaping (Result<User>) -> Void) throws -> URLSessionDataTask {
        guard let request = URLRequest.get(path: "/user")
            else { throw RequestError.cannotBuildRequest }
        
        let handler = { (data: Data?, response: URLResponse?, error: NSError?) -> Result<User> in
            return Result(from: Response(data: data, urlResponse: response), optional: error)
                .flatMap(response2Data)
                .flatMap(data2Json)
                .flatMap(json2User)
        }
        
        return execute(request: request, handleResponse: handler, completion: completion)
    }
    
    @discardableResult
    func checkAuthentication(completion: @escaping (Result<JSON>) -> Void) throws -> URLSessionDataTask {
        guard let request = URLRequest.get(path: "/user/auth")
            else { throw RequestError.cannotBuildRequest }
        
        let handler = { (data: Data?, response: URLResponse?, error: NSError?) -> Result<JSON> in
            return Result(from: Response(data: data, urlResponse: response), optional: error)
                .flatMap(response2Data)
                .flatMap(data2Json)
        }
        
        return execute(request: request, handleResponse: handler, completion: completion)
    }
    
    func login(email: String, password: String, completion: @escaping (Result<String>) -> Void) throws {
        guard let url = URL(string: C.URL.main + "/user/login") else {
            throw RequestError.cannotBuildRequest
        }
        
        let parameters = [
            "email": email,
            "password": password
        ]
        
        var authoriseRequest = URLRequest(url: url)
        authoriseRequest.httpMethod = HTTPMethod.post.stringValue
        authoriseRequest.httpBody = try JSON(parameters).rawData()
        session.dataTask(with: authoriseRequest) { data, response, error in
            completion(
                Result(value: Response(data: data, urlResponse: response))
                    .flatMap(response2Data)
                    .flatMap(data2Json)
                    .flatMap(json2Token)
            )
        }.resume()
    }
}
