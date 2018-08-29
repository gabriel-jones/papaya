//
//  TokenRepository.swift
//  Papaya
//
//  Created by Gabriel Jones on 12/24/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import Foundation

class AuthenticationStore {
    static private let store = KeychainStore()
    
    static var token: String? {
        get {
            return self.store.get(key: C.KeychainStore.user_auth_token)
        }
    }
    
    static var email: String? {
        get {
            return self.store.get(key: C.KeychainStore.user_email)
        }
    }
    
    static var password: String? {
        get {
            return self.store.get(key: C.KeychainStore.user_password)
        }
    }
    
    static func set(token: String) {
        self.store.set(key: C.KeychainStore.user_auth_token, value: token)
    }
    
    static func set(email: String) {
        self.store.set(key: C.KeychainStore.user_email, value: email)
    }
    
    static func set(password: String) {
        self.store.set(key: C.KeychainStore.user_password, value: password)
    }
    
    static func logout(_ completion: @escaping (Bool) -> Void) -> URLSessionDataTask? {
        return Request.shared.logout() { result in
            switch result {
            case .success(_):
                do {
                    try self.store.delete(key: C.KeychainStore.user_email)
                    try self.store.delete(key: C.KeychainStore.user_password)
                    try self.store.delete(key: C.KeychainStore.user_auth_token)
                } catch {
                    print(error.localizedDescription)
                }
                completion(true)
            case .failure(_):
                completion(false)
            }
        }
    }
}
