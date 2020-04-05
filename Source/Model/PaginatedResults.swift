//
//  PaginatedResults.swift
//  Papaya
//
//  Created by Gabriel Jones on 3/25/18.
//  Copyright © 2018 Papaya Ltd. All rights reserved.
//

import Foundation

struct PaginatedResults<T> {
    public var isLast: Bool
    public var results: Array<T>
    
    mutating func combine(with: PaginatedResults<T>) {
        isLast = with.isLast
        results += with.results
    }
}
