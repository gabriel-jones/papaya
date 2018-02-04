//
//  Category.swift
//  Papaya
//
//  Created by Gabriel Jones on 1/23/18.
//  Copyright © 2018 Papaya. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Category: BaseObject {
    public let id: Int
    public let name: String
    
    public var imageURL: URL? {
        get {
            return URL(string: C.URL.categoryImage(with: id))
        }
    }
    
    init?(dict: JSON) {
        guard let _id = dict["category_id"].int, let _name = dict["category_name"].string else {
            return nil
        }
        id = _id
        name = _name
    }
}
