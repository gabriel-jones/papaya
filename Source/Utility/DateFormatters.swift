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

let timeFormatter: DateFormatter = dateFormatterFor(style: "HH:mm:ss")
let dateFormatter: DateFormatter = dateFormatterFor(style: "y-MM-dd")
let dateTimeFormatter: DateFormatter = dateFormatterFor(style: "y-MM-dd'T'HH:mm:ss")
