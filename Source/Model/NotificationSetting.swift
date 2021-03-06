//
//  NotificationSetting.swift
//  Papaya
//
//  Created by Gabriel Jones on 4/17/18.
//  Copyright © 2018 Papaya Ltd. All rights reserved.
//

import Foundation
import SwiftyJSON

final class NotificationSettingGroup: BaseObject {
    public let id: Int
    public let name: String
    public let settings: [NotificationSetting]
    
    init?(dict: JSON) {
        guard
            let _id = dict["id"].int,
            let _name = dict["name"].string,
            let _settingsArray = dict["settings"].array
        else {
                return nil
        }
        
        var _settings = [NotificationSetting]()
        for _setting in _settingsArray {
            if let setting = NotificationSetting(dict: _setting) {
                _settings.append(setting)
            }
        }
        
        id = _id
        name = _name
        settings = _settings
    }
}

final class NotificationSetting: BaseObject {
    public let id: Int
    public let name: String
    public let value: Bool
    
    init?(dict: JSON) {
        guard
            let _id = dict["id"].int,
            let _name = dict["name"].string,
            let _value = dict["value"].bool
        else {
                return nil
        }
        
        id = _id
        name = _name
        value = _value
    }
}
