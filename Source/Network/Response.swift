//
//  Response.swift
//  Papaya
//
//  Created by Gabriel Jones on 12/23/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import Foundation

struct Response {
    let data: Data?
    let statusCode: Int
    
    init(data: Data?, urlResponse: URLResponse?) {
        self.data = data
        self.statusCode = (urlResponse as? HTTPURLResponse)?.statusCode ?? 500
    }
}
