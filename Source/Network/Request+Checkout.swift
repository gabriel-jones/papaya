//
//  Request+Checkout.swift
//  Papaya
//
//  Created by Gabriel Jones on 3/16/18.
//  Copyright © 2018 Papaya Ltd. All rights reserved.
//

import Foundation
import SwiftyJSON

extension Request {
    @discardableResult
    public func getSchedule(days: Int = 7, completion: (CompletionHandler<[ScheduleDay]>)? = nil) -> URLSessionDataTask? {
        guard let request = URLRequest.get(path: "/checkout/schedule/\(days)") else {
            completion?(Result(error: .cannotBuildRequest))
            return nil
        }
        
        return self.execute(request: request, parseMethod: parse.json2ScheduleDays, completion: completion)
    }
    
    @discardableResult
    public func createCheckout(completion: (CompletionHandler<Checkout>)? = nil) -> URLSessionDataTask? {
        guard let request = URLRequest.post(path: "/checkout/create") else {
            completion?(Result(error: .cannotBuildRequest))
            return nil
        }
        
        return self.execute(request: request, parseMethod: parse.json2Checkout, completion: completion)
    }
    
    @discardableResult
    public func getCheckout(completion: (CompletionHandler<Checkout>)? = nil) -> URLSessionDataTask? {
        guard let request = URLRequest.get(path: "/checkout") else {
            completion?(Result(error: .cannotBuildRequest))
            return nil
        }
        
        return self.execute(request: request, parseMethod: parse.json2Checkout, completion: completion)
    }
    
    @discardableResult
    public func updateCheckout(startDate: Date, endDate: Date, completion: (CompletionHandler<JSON>)? = nil) -> URLSessionDataTask? {
        let body = [
            "request_window_start": dateTimeFormatter.string(from: startDate),
            "request_window_end": dateTimeFormatter.string(from: endDate)
        ]
        guard let request = URLRequest.put(path: "/checkout/update/time", body: body) else {
            completion?(Result(error: .cannotBuildRequest))
            return nil
        }
        
        return self.execute(request: request, completion: completion)
    }
    
    @discardableResult
    public func updateCheckout(address: Address, completion: (CompletionHandler<JSON>)? = nil) -> URLSessionDataTask? {
        let body = [
            "address_id": address.id
        ]
        guard let request = URLRequest.put(path: "/checkout/update/address", body: body) else {
            completion?(Result(error: .cannotBuildRequest))
            return nil
        }
        
        return self.execute(request: request, completion: completion)
    }
    
    @discardableResult
    public func updateCheckout(paymentMethod: PaymentMethod, completion: (CompletionHandler<JSON>)? = nil) -> URLSessionDataTask? {
        let body = [
            "payment_id": paymentMethod.id
        ]
        guard let request = URLRequest.put(path: "/checkout/update/payment", body: body) else {
            completion?(Result(error: .cannotBuildRequest))
            return nil
        }
        
        return self.execute(request: request, completion: completion)
    }
    
    @discardableResult
    public func updateCheckout(isDelivery: Bool, completion: (CompletionHandler<JSON>)? = nil) -> URLSessionDataTask? {
        let body = [
            "is_delivery": isDelivery
        ]
        guard let request = URLRequest.put(path: "/checkout/update/type", body: body) else {
            completion?(Result(error: .cannotBuildRequest))
            return nil
        }
        
        return self.execute(request: request, completion: completion)
    }
    
    @discardableResult
    public func deleteCheckout(completion: (CompletionHandler<JSON>)? = nil) -> URLSessionDataTask? {
        guard let request = URLRequest.delete(path: "/checkout/delete") else {
            completion?(Result(error: .cannotBuildRequest))
            return nil
        }
        
        return self.execute(request: request, completion: completion)
    }
    
    @discardableResult
    public func buyCheckout(purchasePriority: Bool, purchaseExpress: Bool, completion: (CompletionHandler<Int>)? = nil) -> URLSessionDataTask? {
        let body = [
            "priority": purchasePriority,
            "express": purchaseExpress
        ]
        guard let request = URLRequest.post(path: "/checkout/buy", body: body) else {
            completion?(Result(error: .cannotBuildRequest))
            return nil
        }
        
        return self.execute(request: request, parseMethod: parse.json2OrderId, completion: completion)
    }
    
    @discardableResult
    public func updateCheckout(isAsap: Bool, completion: (CompletionHandler<JSON>)? = nil) -> URLSessionDataTask? {
        let body = [
            "is_asap": isAsap
        ]
        guard let request = URLRequest.put(path: "/checkout/update/asap", body: body) else {
            completion?(Result(error: .cannotBuildRequest))
            return nil
        }
        
        return self.execute(request: request, completion: completion)
    }
    
}

