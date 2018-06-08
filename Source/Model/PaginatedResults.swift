//
//  PaginatedResults.swift
//  Papaya
//
//  Created by Gabriel Jones on 3/25/18.
//  Copyright © 2018 Papaya. All rights reserved.
//

import Foundation

struct PaginatedResults<T> {
    var isLast: Bool
    var results: Array<T>
    
    mutating func combine(with: PaginatedResults<T>) {
        isLast = with.isLast
        results += with.results
    }
}
