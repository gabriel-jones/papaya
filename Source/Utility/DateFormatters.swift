//
//  DateFormatters.swift
//  Papaya
//
//  Created by Gabriel Jones on 4/8/18.
//  Copyright © 2018 Papaya. All rights reserved.
//

import Foundation

fileprivate func dateFormatterFor(style: String) -> DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = style
    return formatter
}

extension DateFormatter {
    func date(from: String?) -> Date? {
        if let str = from {
            return date(from: str)
        }
        return nil
    }
}

extension Date {
    func format(_ format: String) -> String {
        let formatter = dateFormatterFor(style: format)
        return formatter.string(from: self)
    }
}

let timeFormatter: DateFormatter = dateFormatterFor(style: "HH:mm:ss")
let dateFormatter: DateFormatter = dateFormatterFor(style: "y-MM-dd")
let dateTimeFormatter: DateFormatter = dateFormatterFor(style: "y-MM-dd'T'HH:mm:ss")
let anet_ExpirationDateFormatter: DateFormatter = dateFormatterFor(style: "y-MM")
