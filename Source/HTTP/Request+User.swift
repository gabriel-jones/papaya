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
    func getUserDetails(completion: @escaping (Result<User>) -> ()) throws -> URLSessionDataTask {
        do {
            guard let request = URLRequest.requestWithAuthorisation(path: "/user", method: .get, token: "")
            else { throw RequestError.cannotBuildRequest }
            
            let handler = { (data: Data?, response: URLResponse?, error: Error?) -> Result<User> in
                return Result(from: Response(data: data, urlResponse: response), optional: error)
                .flatMap(response2Data)
                .flatMap(data2Json)
                .flatMap(json2User)
            }
            
            return execute(request: request, handleResponse: handler, completion: completion)
        } catch {
            throw error
        }
    }
    
}
