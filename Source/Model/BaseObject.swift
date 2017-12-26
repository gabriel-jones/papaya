//
//  BaseObject.swift
//  Papaya
//
//  Created by Gabriel Jones on 12/23/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol BaseObject {
    var id: Int { get }
    init?(dict: JSON)
}
