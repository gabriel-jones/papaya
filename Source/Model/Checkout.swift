//
//  Checkout.swift
//  Papaya
//
//  Created by Gabriel Jones on 3/18/18.
//  Copyright © 2018 Papaya Ltd. All rights reserved.
//

import Foundation
import SwiftyJSON

final class Checkout: BaseObject {
    public let id: Int
    public let cart: Cart?
    public var address: Address?
    public var paymentMethod: PaymentMethod?
    
    public var isDelivery: Bool
    public var isAsap: Bool
    public var isPriority: Bool
    
    public var startDate: Date?
    public var endDate: Date?
    
    public var priorityFee: Double
    public var deliveryFee: Double?
    public var serviceFee: Double
    
    init?(dict: JSON) {
        guard
            let _id = dict["id"].int,
            let _isDelivery = dict["is_delivery"].bool,
            let _isAsap = dict["is_asap"].bool,
            let _isPriority = dict["is_priority"].bool,
            let _priorityFee = dict["fee"]["priority_fee"].double,
            let _serviceFee = dict["fee"]["service_fee"].double
        else {
            return nil
        }

        id = _id
        cart = Cart(dict: dict["cart"])
        address = Address(dict: dict["address"])
        print(dict["payment"])
        paymentMethod = PaymentMethod(dict: dict["payment"])
        isDelivery = _isDelivery
        isAsap = _isAsap
        isPriority = _isPriority
        
        priorityFee = _priorityFee
        deliveryFee = dict["fee"]["delivery_fee"].double
        serviceFee = _serviceFee

        if let _startDateString = dict["request_window_start"].string, let _startDate = dateTimeFormatter.date(from: _startDateString) {
            startDate = _startDate
        }
        
        if let _endDateString = dict["request_window_end"].string, let _endDate = dateTimeFormatter.date(from: _endDateString) {
            endDate = _endDate
        }
    }
}
