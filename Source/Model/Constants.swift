//
//  Constants.swift
//  PrePacked
//
//  Created by Gabriel Jones on 10/27/17.
//  Copyright © 2017 Fireminds Ltd. All rights reserved.
//

import Foundation
import KeychainAccess

let keychain = Keychain(server: URL(string: "https://prepacked.bm/")!, protocolType: .https)

struct C {
    struct URL {
        static let main = production
        static let production = "https://prepacked.bm"
        static let development = ""//"http://localhost/"
    }
    
    static let GMS_KEY = "AIzaSyCFy56PBJTowmL5q6cTX-d_uT6HFydP0DM"
    
    struct Notification {
        static let base = "bm.papaya"
        static let CartBadgeUpdate = base + ".cartBadgeUpdate"
    }
}
