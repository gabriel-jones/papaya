//
//  Request+User.swift
//  Papaya
//
//  Created by Gabriel Jones on 12/23/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import Foundation
import SwiftyJSON
import RxSwift

func json2Object<T: BaseObject>(json: JSON, type: T.Type) -> T? {
    return T(dict: json)
}

extension Request {
    func getUserDetails() -> Observable<User> {
        if let request = URLRequest.get(path: "/user") {
            return Request.shared.fetch(request: request)
                .observeOn(MainScheduler.instance)
                .flatMap { (json: JSON) -> Observable<User> in
                    if let user = User(dict: json["user"]) {
                        return Observable.just(user)
                    }
                    return Observable<User>.error(RequestError.failedToParseJson)
                }
        }
        return Observable.error(RequestError.unknown)
    }
    
    func checkAuthentication() -> Observable<JSON> {
        if let request = URLRequest.get(path: "/search/popular") {
            return Request.shared.fetch(request: request)
                .observeOn(MainScheduler.instance)
        }
        return Observable.error(RequestError.unknown)
    }
    /*
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
        authoriseRequest.setContentType()
        session.dataTask(with: authoriseRequest) { data, response, error in
            let result = Result(value: Response(data: data, urlResponse: response))
                .flatMap(response2Data)
                .flatMap(data2Json)
                .flatMap(json2Token)
            if case .success(let token) = result {
                AuthenticationStore.set(token: token)
            }
            completion(result)
        }.resume()
    }
    
    func forgotPassword(email: String, completion: @escaping (Result<JSON>) -> Void) throws {
        guard let url = URL(string: C.URL.main + "/user/forgot?email=\(email)") else {
            throw RequestError.cannotBuildRequest
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.stringValue
        session.dataTask(with: request) { data, response, error in
            completion(
                Result(value: Response(data: data, urlResponse: response))
                    .flatMap(response2Data)
                    .flatMap(data2Json)
            )
        }.resume()
    }*/
}
