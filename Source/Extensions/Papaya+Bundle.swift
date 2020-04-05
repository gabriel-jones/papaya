//
//  Papaya+Bundle.swift
//  Papaya
//
//  Created by Gabriel Jones on 12/23/17.
//  Copyright © 2018 Papaya Ltd. All rights reserved.
//

import Foundation

extension Bundle {
    /**
     Returns object from default info.plist.
     
     - parameter key: key for value
     - returns: Value
     */
    class func infoValueInMainBundle(for key: String) -> AnyObject? {
        if let obj = self.main.localizedInfoDictionary?[key] {
            return obj as AnyObject
        }
        if let obj = self.main.infoDictionary?[key] {
            return obj as AnyObject
        }
        return nil
    }
}
