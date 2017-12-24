//
//  Request.swift
//  Papaya
//
//  Created by Gabriel Jones on 12/23/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import Foundation

class Request: NSObject, URLSessionDelegate, URLSessionDataDelegate {
    
    static var shared = Request()
    
    var session = URLSession(configuration: URLSessionConfiguration.default)
    
    enum HTTPMethod: String {
        case get, post, put, delete
        
        var stringValue: String {
            get {
                return self.rawValue.uppercased()
            }
        }
    }
    
    typealias HandleResponse<T> = (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Result<T>

    func execute<T>(request: URLRequest, handleResponse: @escaping HandleResponse<T>, completion: @escaping (Result<T>) -> ()) -> URLSessionDataTask {
        let task = self.session.dataTask(with: request) { data, response, error in
            let result = handleResponse(data, response, error)
            switch result {
            case .failure(let error as NSError):
                if error.code == HTTPResponseCode.unauthorized.rawValue {
                    self.reauthoriseAndExecute(request: request, handleResponse: handleResponse, completion: completion)
                } else {
                    completion(result)
                }
            case .success:
                completion(result)
            }
        }
        task.resume()
        return task
    }
    
    func reauthoriseAndExecute<T>(request: URLRequest, handleResponse: @escaping HandleResponse<T>, completion: @escaping (Result<T>) -> ()) {
        /*self.reauthorise { result in
            switch result {
            case .failure(let error):
                // handle error
                break
            case .success(let token):
                var request = request
                self.update(request: &request, with: token)
                self.session.dataTask(with: request) { data, response, error in
                    completion(handleResponse(data, response, error))
                }.resume()
            }
        }*/
    }
}
