//
//  Request+Order.swift
//  Papaya
//
//  Created by Gabriel Jones on 8/19/18.
//  Copyright © 2018 Papaya Ltd. All rights reserved.
//

import Foundation
import SwiftyJSON

extension Request {
    
    @discardableResult
    public func getCurrentOrder(completion: (CompletionHandler<OrderStatus>)? = nil) -> URLSessionDataTask? {
        guard let request = URLRequest.get(path: "/order/current") else {
            completion?(Result(error: .cannotBuildRequest))
            return nil
        }
        
        return self.execute(request: request, parseMethod: parse.json2OrderStatus, completion: completion)
    }
    
    @discardableResult
    public func getOrder(id: Int, completion: (CompletionHandler<Order>)? = nil) -> URLSessionDataTask? {
        guard let request = URLRequest.get(path: "/order/get/\(id)") else {
            completion?(Result(error: .cannotBuildRequest))
            return nil
        }
        
        return self.execute(request: request, parseMethod: parse.json2Order, completion: completion)
    }
    
    @discardableResult
    public func submitOrderFeedback(_ id: Int, rating: Int, comments: String, completion: (CompletionHandler<JSON>)? = nil) -> URLSessionDataTask? {
        let body: [String:Any] = [
            "rating": rating,
            "comments": comments
        ]
        
        guard let request = URLRequest.post(path: "/order/get/\(id)/feedback", body: body) else {
            completion?(Result(error: .cannotBuildRequest))
            return nil
        }
        
        return self.execute(request: request, completion: completion)
    }
    
    @discardableResult
    public func getAllOrderHistory(page: Int, completion: (CompletionHandler<PaginatedResults<OrderHistory>>)? = nil) -> URLSessionDataTask? {
        guard let request = URLRequest.get(path: "/order/history/all/\(page)") else {
            completion?(Result(error: .cannotBuildRequest))
            return nil
        }
        
        return self.execute(request: request, parseMethod: parse.json2OrderHistory, completion: completion)
    }
    
    
    
}
