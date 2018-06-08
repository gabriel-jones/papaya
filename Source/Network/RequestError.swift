//
//  RequestError.swift
//  Papaya
//
//  Created by Gabriel Jones on 12/23/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import Foundation

public enum RequestError: Int, Error {
    case unknown = -1
    case cannotBuildRequest = -2
    case failedToParseJson = -3
    case networkOffline = -4
    
    case /* give me the */succ = 0, unauthorised, other, userNotFound, emailRequired, passwordRequired, jsonBodyRequired, streetNameRequired, zipCodeRequired, addressIdRequired, addressNotFound, categoryNotFound, likeRequired, itemNotFound, nameTooLong, emailTooLong, emailExists, nameRequired, streetNameTooLong, zipCodeTooLong, listNotFound, listNameRequired, listNameTooLong, itemsRequired, quantityRequired, cartNotFound, replaceOptionRequired, replaceSpecificRequired, replaceOptionInvalid, itemIdRequired, phoneRequired, phoneTooLong, invalidEmail, notesTooLong, checkoutLineExists, checkoutLineNotFound, isDeliveryRequired, timeRequired, userLevelTooLow, totalTooLow
    
    public var _domain: String {
        return "bm.papaya"
    }
    
    public var errorUserInfo: [String : AnyObject] {
        return [:]
    }
}
