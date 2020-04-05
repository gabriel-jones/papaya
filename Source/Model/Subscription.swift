//
//  Subscription.swift
//  Papaya
//
//  Created by Gabriel Jones on 8/31/18.
//  Copyright © 2018 Papaya Ltd. All rights reserved.
//

import Foundation
import SwiftyJSON

final class Subscription: BaseObject {
    public let id: Int
    public let nextPayment: Date
    public let lastPayment: Date
    public let startDate: Date
    public let paymentMethod: PaymentMethod
    public let subscriptionType: SubscriptionType
    
    final class SubscriptionType: BaseObject {
        public let id: Int
        public let amount: Double
        public let intervalInMonths: Int
        
        required init?(dict: JSON) {
            guard
                let _id = dict["id"].int,
                let _amount = dict["amount"].double,
                let _intervalInMonths = dict["month_interval"].int
            else {
                return nil
            }
            
            id = _id
            amount = _amount
            intervalInMonths = _intervalInMonths
        }
    }
    
    init?(dict: JSON) {
        guard
            let _id = dict["id"].int,
            let _nextPaymentString = dict["next_payment"].string, let _nextPayment = dateFormatter.date(from: _nextPaymentString),
            let _lastPaymentString = dict["last_payment"].string, let _lastPayment = dateFormatter.date(from: _lastPaymentString),
            let _startDateString = dict["start_date"].string, let _startDate = dateFormatter.date(from: _startDateString),
            let _paymentMethod = PaymentMethod(dict: dict["payment"]),
            let _subscriptionType = SubscriptionType(dict: dict["subscription_type"])
        else {
            return nil
        }
        
        id = _id
        nextPayment = _nextPayment
        lastPayment = _lastPayment
        startDate = _startDate
        paymentMethod = _paymentMethod
        subscriptionType = _subscriptionType
    }
}
