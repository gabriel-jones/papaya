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
    public func getUserDetails(completion: (CompletionHandler<User>)? = nil) -> URLSessionDataTask? {
        guard let request = URLRequest.get(path: "/user") else {
            completion?(Result(error: .cannotBuildRequest))
            return nil
        }
    
        return self.execute(request: request, parseMethod: parse.json2User, completion: completion)
    }
    
    @discardableResult
    public func getLikedItems(completion: (CompletionHandler<[Item]>)? = nil) -> URLSessionDataTask? {
        guard let request = URLRequest.get(path: "/user/liked/all") else {
            completion?(Result(error: .cannotBuildRequest))
            return nil
        }
        
        return self.execute(request: request, parseMethod: parse.json2Items, completion: completion)
    }
    
    @discardableResult
    public func checkAuthentication(completion: (CompletionHandler<JSON>)? = nil) -> URLSessionDataTask? {
        guard let request = URLRequest.get(path: "/user/auth") else {
            completion?(Result(error: .cannotBuildRequest))
            return nil
        }
        
        return self.execute(request: request, completion: completion)
    }
    
    @discardableResult
    public func updateUser(user: User, completion: (CompletionHandler<JSON>)? = nil) -> URLSessionDataTask? {
        let body = [
            "email": user.email,
            "fname": user.fname,
            "lname": user.lname,
            "phone": user.phone
        ]
        
        guard let request = URLRequest.put(path: "/user/update", body: body) else {
            completion?(Result(error: .cannotBuildRequest))
            return nil
        }
        
        return self.execute(request: request, completion: completion)
    }
    
    @discardableResult
    public func updateNotifications(values: [String: Bool], completion: (CompletionHandler<JSON>)? = nil) -> URLSessionDataTask? {
        guard let request = URLRequest.put(path: "/user/update/notifications", body: values) else {
            completion?(Result(error: .cannotBuildRequest))
            return nil
        }
        
        return self.execute(request: request, completion: completion)
    }
    
    @discardableResult
    public func login(email: String, password: String, completion: (CompletionHandler<String>)? = nil) -> URLSessionDataTask? {
        let body = [
            "email": email,
            "password": password
        ]
        
        AuthenticationStore.set(email: email)
        AuthenticationStore.set(password: password)
        
        guard let request = URLRequest.post(path: "/user/login", body: body) else {
            completion?(Result(error: .cannotBuildRequest))
            return nil
        }
        
        return self.execute(request: request, withAuth: false, parseMethod: parse.json2Token) { result in
            if case .success(let token) = result {
                AuthenticationStore.set(token: token)
            }
            completion?(result)
        }
    }
    
    @discardableResult
    public func signup(email: String, password: String, fname: String, lname: String, phone: String, completion: (CompletionHandler<JSON>)? = nil) -> URLSessionDataTask? {
        let body = [
            "email": email,
            "password": password,
            "fname": fname,
            "lname": lname,
            "phone": phone
        ]
        
        AuthenticationStore.set(email: email)
        AuthenticationStore.set(password: password)
        
        guard let request = URLRequest.post(path: "/user/signup", body: body) else {
            completion?(Result(error: .cannotBuildRequest))
            return nil
        }
        
        return self.execute(request: request, withAuth: false, completion: completion)
    }
    
    @discardableResult
    public func forgotPassword(email: String, completion: (CompletionHandler<JSON>)? = nil) -> URLSessionDataTask? {
        let body = [
            "email": email
        ]
        
        guard let request = URLRequest.get(path: "/user/forgot", urlParameters: body) else {
            completion?(Result(error: .cannotBuildRequest))
            return nil
        }
        
        return self.execute(request: request, withAuth: false, completion: completion)
    }
    
    @discardableResult
    public func logout(completion: (CompletionHandler<JSON>)? = nil) -> URLSessionDataTask? {
        guard let request = URLRequest.get(path: "/user/logout") else {
            completion?(Result(error: .cannotBuildRequest))
            return nil
        }
        
        return self.execute(request: request, completion: completion)
    }
}
