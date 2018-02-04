//
//  Request.swift
//  Papaya
//
//  Created by Gabriel Jones on 12/23/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import UIKit
import SwiftyJSON
import RxSwift

class Request: NSObject, URLSessionDelegate, URLSessionDataDelegate {
    
    
    /* TEMP */
    //TOOD: DELETE
    
    func getAllItemsTemp() -> Observable<[Item]> {
        if let request = URLRequest.get(path: "/temp_items") {
            return Request.shared.fetch(request: request)
                .observeOn(MainScheduler.instance)
                .flatMap(parse.json2Items)
        }
        return Observable.error(RequestError.unknown)
    }

    public static let shared = Request()
    
    internal let parse = Parse()
    internal let session = URLSession(configuration: URLSessionConfiguration.default)

    public enum HTTPMethod: String {
        case get, post, put, patch, delete
        
        public var stringValue: String {
            get {
                return self.rawValue.uppercased()
            }
        }
    }
    
    internal func fetch(request: URLRequest) -> Observable<JSON> {
        return self.task(request: request)
            .catchError { error in
                switch error as? RequestError {
                case .unauthorised?:
                    return self.reauthorise()
                        .catchErrorJustReturn("")
                        .flatMap { str -> Observable<JSON> in
                            if str == "" {
                                return self.task(request: request)
                            }
                            return Observable.error(error)
                        }
                default:
                    return Observable.error(error)
                }
            }
    }
    
    internal func task(request: URLRequest) -> Observable<JSON> {
        print("TASK")
        return Observable.create { observer in
            let task = self.session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) -> Void in
                print("callback: \(error, response)")
                guard error == nil, let _ = response as? HTTPURLResponse, let data = data else {
                    observer.onError(RequestError.unknown)
                    return
                }
                
                do {
                    let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                    let json = JSON(jsonObject)
                    guard let code = json["code"].int else {
                        observer.onError(RequestError.unknown)
                        return
                    }
                    if let requestError = RequestError(rawValue: code) {
                        if requestError == .success {
                            observer.onNext(json)
                            observer.onCompleted()
                            return
                        }
                        observer.onError(requestError)
                    }
                } catch {
                    observer.onError(RequestError.failedToParseJson)
                }
            }
            task.resume()
            return Disposables.create(with: task.cancel)
        }
    }
    
    internal func reauthorise() -> Observable<String> {
        print("reauth")
        guard let email = AuthenticationStore.email, let password = AuthenticationStore.password else {
            return Observable.error(RequestError.unknown)
        }
        print("reauth task")
        return self.login(email: email, password: password)
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

