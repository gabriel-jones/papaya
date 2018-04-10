//
//  Request+Checkout.swift
//  Papaya
//
//  Created by Gabriel Jones on 3/16/18.
//  Copyright © 2018 Papaya. All rights reserved.
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
    public func updateCheckout(orderDate: Date, completion: (CompletionHandler<JSON>)? = nil) -> URLSessionDataTask? {
        print(orderDate)
        print(dateTimeFormatter.string(from: orderDate))
        let body = [
            "order_time": dateTimeFormatter.string(from: orderDate)
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
}

