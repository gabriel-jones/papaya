//
//  Club.swift
//  Papaya
//
//  Created by Gabriel Jones on 5/1/18.
//  Copyright © 2018 Papaya. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Club: BaseObject {
    
    public let id: Int
    public let name: String
    public let specialStatus: String?
    public let blurb: String
    public let isMember: Bool
    
    private let imageId: String?
    
    public var img: URL? {
        get {
            guard let imageId = imageId else {
                return nil
            }
            return URL(string: C.URL.main + imageId)
        }
    }
    
    public init?(dict: JSON) {
        guard
            let _id = dict["id"].int,
            let _name = dict["name"].string,
            let _blurb = dict["blurb"].string,
            let _isMember = dict["is_member"].bool
        else {
            return nil
        }
        
        id = _id
        name = _name
        blurb = _blurb
        specialStatus = dict["special_status"].string
        imageId = dict["img_url"].string
        isMember = _isMember
    }
}
