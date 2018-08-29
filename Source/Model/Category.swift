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
    public let isSpecial: Bool
    public let imageId: String?
    public let specialClubId: Int?
    
    public var imageURL: URL? {
        get {
            guard let imageId = imageId else { return nil }
            return URL(string: C.URL.main + imageId)
        }
    }
    
    init?(dict: JSON) {
        guard
            let _id = dict["category_id"].int,
            let _name = dict["category_name"].string,
            let _isSpecial = dict["is_special"].bool
        else {
            return nil
        }
        id = _id
        name = _name
        isSpecial = _isSpecial
        imageId = dict["img_url"].string
        specialClubId = dict["special_club_id"].int
    }
}
