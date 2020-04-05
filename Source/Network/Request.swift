//
//  Request.swift
//  Papaya
//
//  Created by Gabriel Jones on 12/23/17.
//  Copyright © 2018 Papaya Ltd. All rights reserved.
//

import UIKit
import SwiftyJSON
import Reachability

enum ThreadType {
    case main, background
}

class Request: NSObject, URLSessionDelegate, URLSessionDataDelegate {
    
    internal var threadType: ThreadType?
    
    public init(_ thread: ThreadType) {
        threadType = thread
        super.init()
    }
    
    public static let shared: Request = Request(.main)
    //public let background: Request = Request(.background)
    
    internal let parse = Parse()
    internal let session = URLSession(configuration: .default)
    
    internal let reachability = Reachability()!
    
    internal typealias HandleResponse<T> = (_ data: Data?, _ response: URLResponse?, _ error: NSError?) -> Result<T>
    internal typealias CompletionHandler<T> = (Result<T>) -> Void
    
    internal func constructHandler<T>(parseMethod: ((JSON) -> Result<T>)?) -> ((Data?, URLResponse?, NSError?) -> Result<T>) {
        return { (data: Data?, response: URLResponse?, error: NSError?) -> Result<T> in
            return Result(from: Response(data: data, urlResponse: response), optional: error)
                .flatMap(self.parse.response2Data)
                .flatMap(self.parse.data2Json)
                .flatMap(parseMethod ?? {return Result(fromOptional: $0 as? T, error: .failedToParseJson) }) // I'm sorry for this garbage code
        }
    }
    
    internal func execute<T>(request: URLRequest, withAuth: Bool = true, parseMethod: ((JSON) -> Result<T>)? = nil, completion: (CompletionHandler<T>)? = nil) -> URLSessionDataTask? {
        print(request.papayaDescription)
        /*
        if reachability.connection == .none {
            completion?(Result(error: RequestError.networkOffline))
            return nil
        }*/
        
        let task = session.dataTask(with: request) { data, response, error in
            let handleResponse = self.constructHandler(parseMethod: parseMethod)
            let result = handleResponse(data, response, error as NSError?)
            switch result {
            case .failure(let error):
                if error == .unauthorised && withAuth {
                    self.reauthoriseAndExecute(request: request, handleResponse: handleResponse, completion: completion)
                    return
                }
                print("Failed: ", request.httpMethod!, request.url!.path, error.localizedDescription)
            default: break
            }
            if self.threadType == .main {
                DispatchQueue.main.async {
                    completion?(result)
                }
            } else {
                completion?(result)
            }
        }
        task.resume()
        return task
    }
    
    private func reauthoriseAndExecute<T>(request: URLRequest, handleResponse: @escaping HandleResponse<T>, completion: (CompletionHandler<T>)? = nil) {
        self.reauthorise { result in
            switch result {
            case .failure(let error):
                if self.threadType == .main {
                    DispatchQueue.main.async {
                        completion?(Result(error: error))
                    }
                } else {
                    completion?(Result(error: error))
                }
            case .success(let token):
                AuthenticationStore.set(token: token)
                
                var request = request
                request.setAuthorisation(token: token)
                self.session.dataTask(with: request) { data, response, error in
                    if self.threadType == .main {
                        DispatchQueue.main.async {
                            completion?(handleResponse(data, response, error as NSError?))
                        }
                    } else {
                        completion?(handleResponse(data, response, error as NSError?))
                    }
                }.resume()
            }
        }
    }
    
    public func reauthorise(_ completion: (CompletionHandler<String>)? = nil) {
        guard let email = AuthenticationStore.email, let password = AuthenticationStore.password else {
            completion?(Result(error: RequestError.unauthorised))
            return
        }
        
        login(email: email, password: password) { completion?($0) }
    }
    
    /*
     public func reauthorise(_ completion: @escaping (Result<String>) -> Void) throws {
     guard let email = AuthenticationStore.email, let password = AuthenticationStore.password else {
     completion(Result(error: RequestError.unauthorised))
     return
     }
     
     try login(email: email, password: password) { completion($0) }
     }
     */
}

