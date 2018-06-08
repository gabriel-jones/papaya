//
//  Country.swift
//  Papaya
//
//  Created by Gabriel Jones on 5/3/18.
//  Copyright © 2018 Papaya. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Country: BaseObject {
    public let id: Int
    public let countryCode: String
    
    public init?(dict: JSON) {
        guard
            let _countryCode = dict["country_code"].string
        else {
            return nil
        }
        
        id = -1
        countryCode = _countryCode
    }
    
    public var name: String? {
        get {
            return Locale(identifier: "en_US").localizedString(forRegionCode: countryCode)
        }
    }
    
    public var flagEmoji: String {
        get {
            let base: UInt32 = 127397
            var s = ""
            for v in countryCode.unicodeScalars {
                s.unicodeScalars.append(UnicodeScalar(base + v.value)!)
            }
            return String(s)
        }
    }
}
