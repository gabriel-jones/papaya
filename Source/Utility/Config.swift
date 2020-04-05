//
//  Config.swift
//  Papaya
//
//  Created by Gabriel Jones on 12/23/17.
//  Copyright © 2018 Papaya Ltd. All rights reserved.
//

import UIKit

class Config {
    static let shared = Config()
    
    let version: String
    let bundleIdentifier: String
    let buildNumber: String
    let deviceVendorId: String
    
    var userAgent: String {
        get {
            return "Papaya iOS/\(version)(\(bundleIdentifier))"
        }
    }
    
    init() {
        version =  Bundle.infoValueInMainBundle(for: "CFBundleShortVersionString") as? String ?? ""
        bundleIdentifier = Bundle.infoValueInMainBundle(for: "CFBundleIdentifier") as? String ?? ""
        buildNumber = Bundle.infoValueInMainBundle(for: "CFBundleVersion") as? String ?? ""
        deviceVendorId = UIDevice.current.identifierForVendor?.uuidString ?? ""
        print("Device Vendor ID: ", deviceVendorId)
    }
}

