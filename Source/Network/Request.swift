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
    
    let disposeBag = DisposeBag()
    
    /* TEMP */
    //TOOD: DELETE
    
    func getAllItemsTemp() -> Observable<[Item]> {
        if let request = URLRequest.get(path: "/search/popular") {
            return Request.shared.fetch(request: request)
                .observeOn(MainScheduler.instance)
                .flatMap(json2Items)
        }
        return Observable.error(RequestError.unknown)
    }

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

    internal func fetch(request: URLRequest) -> Observable<JSON> {
        print("Fetch: \(request.url!.absoluteString)")
        return Observable.create { observer in
            let task = self.session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) -> Void in
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
        .retryWhen { errorObservable -> Observable<Error> in
            print("retry when")
            return errorObservable.flatMap { error -> Observable<Error> in
                print("flat map \(error)")
                if case RequestError.unauthorised = error {
                    print("Handle reauthentication")
                    //TODO: reauthenticate. Possibly separate to 2 functions - one base request w/out authentication checks, the other a wrapper of that request with authentication. Then login and auth functions can call base request, and main authenticated function can use auth function with reauthentication built in so no loops are created.
                    // observable<data> flatMap to observable<json> with error checks flatMap to observable<T> ???
                    return errorObservable
                }
                return errorObservable.flatMap { Observable.error($0) }
            }
        }
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

