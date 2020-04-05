//
//  KeychainStore.swift
//  Papaya
//
//  Created by Gabriel Jones on 12/23/17.
//  Copyright © 2018 Papaya Ltd. All rights reserved.
//

import Foundation

class KeychainStore {
    func get(key: String) -> String? {
        return keychain[key]
    }
    
    func set(key: String, value: String) {
        keychain[key] = value
    }
    
    func delete(key: String) throws {
        try keychain.remove(key)
    }
}
