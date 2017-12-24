//
//  RequestError.swift
//  Papaya
//
//  Created by Gabriel Jones on 12/23/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import Foundation

public enum RequestError: Int, Error {
    case unknown
    case cannotBuildRequest
    case failedToParseJsonToObject
    
    public var _domain: String {
        return "bm.papaya"
    }
    
    public var errorUserInfo: [String : AnyObject] {
        return [:]
    }
}
