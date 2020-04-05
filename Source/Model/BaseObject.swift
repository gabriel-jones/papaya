//
//  BaseObject.swift
//  Papaya
//
//  Created by Gabriel Jones on 12/23/17.
//  Copyright © 2018 Papaya Ltd. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol BaseObject {
    var id: Int { get }
    init?(dict: JSON)
}
