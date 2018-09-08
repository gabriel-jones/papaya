//
//  Request+Express.swift
//  Papaya
//
//  Created by Gabriel Jones on 8/29/18.
//  Copyright © 2018 Papaya. All rights reserved.
//

import Foundation
import SwiftyJSON

extension Request {
    
    @discardableResult
    public func getExpressDetails(completion: (CompletionHandler<Subscription>)? = nil) -> URLSessionDataTask? {
        guard let request = URLRequest.get(path: "/express") else {
            completion?(Result(error: .cannotBuildRequest))
            return nil
        }
        
        return self.execute(request: request, parseMethod: parse.json2Subscription, completion: completion)
    }
    
    @discardableResult
    public func joinExpress(paymentMethod: PaymentMethod, isMonthlyPlan: Bool, completion: (CompletionHandler<JSON>)? = nil) -> URLSessionDataTask? {
        let body: [String:Any] = [
            "payment_id": paymentMethod.id,
            "is_monthly": isMonthlyPlan
        ]
        
        guard let request = URLRequest.post(path: "/express/join", body: body) else {
            completion?(Result(error: .cannotBuildRequest))
            return nil
        }
        
        return self.execute(request: request, completion: completion)
    }
    
    @discardableResult
    public func cancelExpress(completion: (CompletionHandler<JSON>)? = nil) -> URLSessionDataTask? {
        guard let request = URLRequest.post(path: "/express/cancel") else {
            completion?(Result(error: .cannotBuildRequest))
            return nil
        }
        
        return self.execute(request: request, completion: completion)
    }
    
    @discardableResult
    public func updateExpress(paymentMethod: PaymentMethod, completion: (CompletionHandler<JSON>)? = nil) -> URLSessionDataTask? {
        let body = [
            "payment_id": String(paymentMethod.id)
        ]
        guard let request = URLRequest.post(path: "/express/update/payment", body: body) else {
            completion?(Result(error: .cannotBuildRequest))
            return nil
        }
        
        return self.execute(request: request, completion: completion)
    }
    
}
