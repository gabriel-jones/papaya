//
//  HTTPMethod.swift
//  Papaya
//
//  Created by Gabriel Jones on 3/25/18.
//  Copyright © 2018 Papaya. All rights reserved.
//

import Foundation

public enum HTTPMethod: String {
    case get, post, put, patch, delete
    
    public var stringValue: String {
        get {
            return self.rawValue.uppercased()
        }
    }
}
