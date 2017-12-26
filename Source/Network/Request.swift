//
//  Request.swift
//  Papaya
//
//  Created by Gabriel Jones on 12/23/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import UIKit
import SwiftyJSON

class Request: NSObject, URLSessionDelegate, URLSessionDataDelegate {
    
    public static var shared = Request()
    
    internal var session = URLSession(configuration: URLSessionConfiguration.default)
    
    public enum HTTPMethod: String {
        case get, post, put, patch, delete
        
        public var stringValue: String {
            get {
                return self.rawValue.uppercased()
            }
        }
    }
    
    internal typealias HandleResponse<T> = (_ data: Data?, _ response: URLResponse?, _ error: NSError?) -> Result<T>
    
    internal func execute<T>(request: URLRequest, handleResponse: @escaping HandleResponse<T>, completion: @escaping (Result<T>) -> Void) -> URLSessionDataTask {
        if !Network.reachability?.isConnectedToNetwork {
            completion(Result(error: RequestError.networkOffline))
        }
        
        let task = session.dataTask(with: request) { data, response, error in
            let result = handleResponse(data, response, error as NSError?)
            switch result {
            case .failure(let error):
                if error == .unauthorised {
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
    
    private func reauthoriseAndExecute<T>(request: URLRequest, handleResponse: @escaping HandleResponse<T>, completion: @escaping (Result<T>) -> Void) {
        do {
            try self.reauthorise { result in
                switch result {
                case .failure(let error):
                    completion(Result(error: error))
                case .success(let token):
                    AuthenticationStore.set(token: token)
                    
                    var request = request
                    request.setAuthorisation(token: token)
                    self.session.dataTask(with: request) { data, response, error in
                        completion(handleResponse(data, response, error as NSError?))
                    }.resume()
                }
            }
        } catch {
            completion(Result(error: RequestError.unknown))
        }
    }
    
    public func reauthorise(_ completion: @escaping (Result<String>) -> Void) throws {
        guard let email = AuthenticationStore.email, let password = AuthenticationStore.password else {
            completion(Result(error: RequestError.unauthorised))
            return
        }
        
        try login(email: email, password: password) { completion($0) }
    }
}

