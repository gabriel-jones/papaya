//
//  Config.swift
//  Papaya
//
//  Created by Gabriel Jones on 12/23/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import Foundation

class Config {
    static let shared = Config()
    
    let version: String
    let bundleIdentifier: String
    let buildNumber: String
    
    var userAgent: String {
        get {
            return "iOS:" + bundleIdentifier + ":v" + version
        }
    }
    
    init() {
        version =  Bundle.infoValueInMainBundle(for: "CFBundleShortVersionString") as? String ?? ""
        bundleIdentifier = Bundle.infoValueInMainBundle(for: "CFBundleIdentifier") as? String ?? ""
        buildNumber = Bundle.infoValueInMainBundle(for: "CFBundleVersion") as? String ?? ""
    }
}

