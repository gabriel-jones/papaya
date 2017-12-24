//
//  KeychainStore.swift
//  Papaya
//
//  Created by Gabriel Jones on 12/23/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import Foundation

class KeychainStore {
    func get(key: String) -> String? {
        return keychain[key]
    }
    
    func set(key: String, value: String) {
        keychain[key] = value
    }
}
