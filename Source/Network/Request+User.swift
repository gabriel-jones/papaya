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

extension Request {
    func getUserDetails() -> Observable<User> {
        guard let request = URLRequest.get(path: "/user") else {
            return Observable.error(RequestError.cannotBuildRequest)
        }
    
        return self.fetch(request: request)
            .flatMap(parse.json2User)
    }
    
    func getLikedItems() -> Observable<[Item]> {
        guard let request = URLRequest.get(path: "/user/liked/all") else {
            return Observable.error(RequestError.cannotBuildRequest)
        }
        return self.fetch(request: request)
            .flatMap(parse.json2Items)
    }
    
    func checkAuthentication() -> Observable<JSON> {
        print("check auth")
        guard let request = URLRequest.get(path: "/user/auth") else {
            return Observable.error(RequestError.cannotBuildRequest)
        }
        
        return self.fetch(request: request)
    }
    
    func update(user: User) -> Observable<JSON> {
        let body = [
            "email": user.email,
            "fname": user.fname,
            "lname": user.lname,
            "phone": user.phone
        ]
        
        guard let request = URLRequest.put(path: "/user/update", body: body) else {
            return Observable.error(RequestError.cannotBuildRequest)
        }
        
        return self.task(request: request)
    }
    
    func updateNotifications(values: [String: Bool]) -> Observable<JSON> {
        guard let request = URLRequest.post(path: "/user/update/notification", body: values) else {
            return Observable.error(RequestError.cannotBuildRequest)
        }
        
        return self.task(request: request)
    }
    
    func login(email: String, password: String) -> Observable<String> {
        let body = [
            "email": email,
            "password": password
        ]
        
        guard let request = URLRequest.post(path: "/user/login", body: body) else {
            return Observable.error(RequestError.cannotBuildRequest)
        }
        
        return self.task(request: request)
            .flatMap { json -> Observable<String> in
                if let token = json["auth_token"].string {
                    AuthenticationStore.set(token: token)
                    return Observable.just(token)
                }
                return Observable.error(RequestError.failedToParseJson)
            }
    }
    
    func signup(email: String, password: String, fname: String, lname: String) -> Observable<JSON> {
        let body = [
            "email": email,
            "password": password,
            "fname": fname,
            "lname": lname
        ]
        
        guard let request = URLRequest.post(path: "/user/signup", body: body) else {
            return Observable.error(RequestError.cannotBuildRequest)
        }
        
        return self.task(request: request)
    }
    
    func forgotPassword(email: String) -> Observable<JSON> {
        let urlParameters = [
            "email": email
        ]
        
        guard let request = URLRequest.get(path: "/user/forgot", urlParameters: urlParameters) else {
            return Observable.error(RequestError.cannotBuildRequest)
        }

        return self.task(request: request)
    }
    
    func logout() -> Observable<JSON> {
        guard let request = URLRequest.get(path: "/user/logout") else {
            return Observable.error(RequestError.cannotBuildRequest)
        }
        
        return self.task(request: request)
    }
}
