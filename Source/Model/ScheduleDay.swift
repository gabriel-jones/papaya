//
//  ScheduleDay.swift
//  Papaya
//
//  Created by Gabriel Jones on 4/8/18.
//  Copyright © 2018 Papaya. All rights reserved.
//

import Foundation
import SwiftyJSON

struct ScheduleDay: BaseObject {
    public let id: Int
    public let date: Date
    public let isOpen: Bool
    public let opensAt: Date
    public let closesAt: Date
    
    init?(dict: JSON) {
        print(dict)
        print(dateFormatter.date(from: "2018-04-08"))
        print(timeFormatter.date(from: "17:00:00"))
        guard
            let _dateString = dict["date"].string,
            let _isOpen = dict["is_open"].bool,
            let _opensAtString = dict["opens_at"].string,
            let _closesAtString = dict["closes_at"].string,
            let _date = dateFormatter.date(from: _dateString),
            let _opensAt = timeFormatter.date(from: _opensAtString),
            let _closesAt = timeFormatter.date(from: _closesAtString)
        else {
            return nil
        }

        id = 0
        isOpen = _isOpen
        date = _date
        opensAt = _opensAt
        closesAt = _closesAt
    }
}
