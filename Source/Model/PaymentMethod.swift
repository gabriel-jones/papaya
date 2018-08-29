//
//  PaymentMethod.swift
//  Papaya
//
//  Created by Gabriel Jones on 8/26/18.
//  Copyright © 2018 Papaya. All rights reserved.
//

import Foundation
import SwiftyJSON

struct PaymentMethod: BaseObject {
    
    public enum CardType: String {
        case visa = "Visa", mastercard = "Mastercard", other = ""
        
        public init(cardType: String) {
            if let type = CardType(rawValue: cardType.lowercased()) {
                self = type
            } else {
                self = .other
            }
        }
    }
    
    public let id: Int
    public let lastFour: String
    public let expirationDate: String
    public let cardType: CardType
    
    public var formattedCardNumber: String {
        get {
            return String(repeating: "**** ", count: 3) + self.lastFour
        }
    }
    
    public var formattedExpirationDate: String? {
        get {
            return anet_ExpirationDateFormatter.date(from: self.expirationDate)?.format("MMMM y")
        }
    }
    
    public var image: UIImage {
        get {
            switch cardType {
            case .visa:
                return #imageLiteral(resourceName: "Visa")
            case .mastercard:
                return #imageLiteral(resourceName: "Mastercard")
            default:
                return #imageLiteral(resourceName: "Card").tintable
            }
        }
    }
    
    init?(dict: JSON) {
        guard
            let _id = dict["id"].string,
            let _idInt = Int(_id),
            let _lastFour = dict["last_four"].string,
            let _cardTypeString = dict["card_type"].string,
            let _cardType = CardType(rawValue: _cardTypeString),
            let _expirationDate = dict["expiration_date"].string
        else {
            return nil
        }
        
        id = _idInt
        lastFour = _lastFour
        cardType = _cardType
        expirationDate = _expirationDate
    }
}
