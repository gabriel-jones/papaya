//
//  Order.swift
//  Papaya
//
//  Created by Gabriel Jones on 8/19/18.
//  Copyright © 2018 Papaya. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Transaction: BaseObject {
    public let id: Int
    public let baseAmount: Float
    public let capturedAmount: Float
    public let cartSubtotal: Float
    public let serviceFee: Float
    
    public let finalisedAmount: Float?
    public let deliveryFee: Float?
    public let priorityFee: Float?
    public let finalisedCartSubtotal: Float?
    
    init?(dict: JSON) {
        guard
            let _id = dict["id"].int,
            let _baseAmount = dict["base_amount"].float,
            let _capturedAmount = dict["captured_amount"].float,
            let _cartSubtotal = dict["cart_subtotal"].float,
            let _serviceFee = dict["service_fee"].float
        else {
            return nil
        }
        
        id = _id
        baseAmount = _baseAmount
        capturedAmount = _capturedAmount
        cartSubtotal = _cartSubtotal
        serviceFee = _serviceFee
        
        finalisedAmount = dict["finalised_amount"].float
        deliveryFee = dict["delivery_fee"].float
        priorityFee = dict["priority_fee"].float
        finalisedCartSubtotal = dict["finalised_cart_subtotal"].float
    }
}

struct OrderItem: BaseObject {
    
    enum ReplaceOption: String {
        case skip
        case replaceBest = "replace_best"
        case replaceSpecific = "replace_specific"
    }
    
    typealias ReplaceSpecific = (id: Int, name: String)?
    typealias ReplacedWith = (id: Int, name: String, quantity: Int)?
    
    public let id: Int
    public let orderItemId: Int
    public let isPacked: Bool
    public let name: String
    public let price: Float
    public let quantity: Int
    public let quantityCollected: Int?
    public let replaceOption: ReplaceOption
    public let size: String?
    public let replaceSpecific: ReplaceSpecific
    public let replacedWith: ReplacedWith
    
    init?(dict: JSON) {
        guard
            let _id = dict["id"].int,
            let _orderItemId = dict["order_item_id"].int,
            let _isPacked = dict["is_packed"].bool,
            let _name = dict["name"].string,
            let _price = dict["price"].float,
            let _quantity = dict["quantity"].int,
            let _replaceOptionString = dict["replace_option"].string,
            let _replaceOption = ReplaceOption(rawValue: _replaceOptionString),
            let _size = dict["size"].string
        else {
            return nil
        }
        
        id = _id
        orderItemId = _orderItemId
        isPacked = _isPacked
        name = _name
        price = _price
        quantity = _quantity
        quantityCollected = dict["quantity_collected"].int
        replaceOption = _replaceOption
        size = _size
        
        if dict["replace_specific"] != JSON.null {
            replaceSpecific = (id: dict["replace_specific"]["id"].intValue, name: dict["replace_specific"]["name"].stringValue)
        } else {
            replaceSpecific = nil
        }
        
        if dict["replaced_with"] != JSON.null {
            replacedWith = (id: dict["replaced_with"]["id"].intValue, name: dict["replaced_with"]["name"].stringValue, quantity: dict["replaced_with"]["quantity"].intValue)
        } else {
            replacedWith = nil
        }
    }
}

struct Delivery: BaseObject {
    public let id: Int
    public let address: Address
    
    public let deliveryNotes: String?
    public let timeDelivered: Date?
    public let timeLoaded: Date?
    public let timeStarted: Date?
    public let driverId: Int?
    public let driverName: String?
    
    init?(dict: JSON) {
        guard
            let _id = dict["id"].int,
            let _address = Address(dict: dict["address"])
        else {
            return nil
        }
        
        id = _id
        address = _address
        timeDelivered = dateTimeFormatter.date(from: dict["time_delivered"].string)
        timeLoaded = dateTimeFormatter.date(from: dict["time_loaded"].string)
        timeStarted = dateTimeFormatter.date(from: dict["batch"]["time_started"].string)
        driverId = dict["batch"]["employee"]["id"].int
        driverName = dict["batch"]["employee"]["name"].string
        deliveryNotes = dict["notes"].string
    }
}

struct Order: BaseObject {
    
    enum Status: String {
        case new, packing, packed, delivery, finished, declined
    }
    
    struct Time: BaseObject {
        internal let id: Int
        
        public let submitted: Date
        public let requestWindowStart: Date?
        public let requestWindowEnd: Date?
        public let packingStart: Date?
        public let packingEnd: Date?
        public let pickedUp: Date?
        public let declined: Date?
        public let closed: Date?
        
        init?(dict: JSON) {
            guard
                let _submit = dateTimeFormatter.date(from: dict["submit"].string)
            else {
                return nil
            }
            
            id = 0
            submitted = _submit
            requestWindowStart = dateTimeFormatter.date(from: dict["request_window_start"].string)
            requestWindowEnd = dateTimeFormatter.date(from: dict["request_window_end"].string)
            packingStart = dateTimeFormatter.date(from: dict["packing_start"].string)
            packingEnd = dateTimeFormatter.date(from: dict["packing_end"].string)
            pickedUp = dateTimeFormatter.date(from: dict["picked_up"].string)
            declined = dateTimeFormatter.date(from: dict["declined"].string)
            closed = dateTimeFormatter.date(from: dict["closed"].string)
        }
    }
    
    public let id: Int
    public let status: Status
    
    public let isAsap: Bool
    public let isDelivery: Bool
    public let isPriority: Bool
    
    public let percentPacked: Double?
    public let bags: Int?
    
    public let transaction: Transaction
    public let delivery: Delivery?
    public let items: [OrderItem]
    public let time: Time
    
    public var changesCount: Int {
        get {
            return items.filter { $0.quantityCollected ?? $0.quantity < $0.quantity }.count
        }
    }
    
    init?(dict: JSON) {
        guard
            let _id = dict["id"].int,
            let _isAsap = dict["is_asap"].bool,
            let _isDelivery = dict["is_delivery"].bool,
            let _isPriority = dict["is_priority"].bool,
            let _statusRawValue = dict["status"].string,
            let _status = Status(rawValue: _statusRawValue),
            let _transaction = Transaction(dict: dict["transaction"]),
            let _items = dict["items"].array,
            let _time = Time(dict: dict["time"])
        else {
            return nil
        }
        
        id = _id
        status = _status
        isAsap = _isAsap
        isDelivery = _isDelivery
        isPriority = _isPriority
        transaction = _transaction
        delivery = Delivery(dict: dict["delivery"])
        time = _time
        
        percentPacked = dict["percent_item_packed"].double
        bags = dict["bags"].int
        
        var _itemsArray = [OrderItem]()
        for _item in _items {
            guard let item = OrderItem(dict: _item) else {
                return nil
            }
            _itemsArray.append(item)
        }
        items = _itemsArray
        
    }
}

struct OrderStatus: BaseObject {
    public let id: Int
    public let status: Order.Status
    
    init?(dict: JSON) {
        guard
            let _id = dict["id"].int,
            let _statusString = dict["status"].string,
            let _status = Order.Status(rawValue: _statusString)
            else {
                return nil
        }
        
        id = _id
        status = _status
    }
}

