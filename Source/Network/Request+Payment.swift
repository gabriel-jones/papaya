//
//  Request+Payment.swift
//  Papaya
//
//  Created by Gabriel Jones on 8/26/18.
//  Copyright © 2018 Papaya Ltd. All rights reserved.
//

import Foundation
import SwiftyJSON

extension Request {
    
    @discardableResult
    public func getFirstPayment(completion: (CompletionHandler<PaymentMethod?>)? = nil) -> URLSessionDataTask? {
        guard let request = URLRequest.get(path: "/payment/first") else {
            completion?(Result(error: .cannotBuildRequest))
            return nil
        }
        
        return self.execute(request: request, parseMethod: parse.json2PaymentMethodOptional, completion: completion)
    }
    
    @discardableResult
    public func getAllPayments(completion: (CompletionHandler<Array<PaymentMethod>>)? = nil) -> URLSessionDataTask? {
        guard let request = URLRequest.get(path: "/payment/all") else {
            completion?(Result(error: .cannotBuildRequest))
            return nil
        }
        
        return self.execute(request: request, parseMethod: parse.json2PaymentMethods, completion: completion)
    }
    
    @discardableResult
    public func getPaymentMethod(id: Int, completion: (CompletionHandler<PaymentMethod>)? = nil) -> URLSessionDataTask? {
        guard let request = URLRequest.get(path: "/payment/get/\(id)") else {
            completion?(Result(error: .cannotBuildRequest))
            return nil
        }
        
        return self.execute(request: request, parseMethod: parse.json2PaymentMethod, completion: completion)
    }
    
    @discardableResult
    public func addPaymentMethod(card: String, expirationMonth: String, expirationYear: String, securityCode: String, completion: (CompletionHandler<JSON>)? = nil) -> URLSessionDataTask? {
        let body: [String:Any] = [
            "card_number": card,
            "expiration_month": expirationMonth,
            "expiration_year": expirationYear,
            "security_code": securityCode
        ]
        guard let request = URLRequest.post(path: "/payment/add", body: body) else {
            completion?(Result(error: .cannotBuildRequest))
            return nil
        }
        
        return self.execute(request: request, completion: completion)
    }
    
    @discardableResult
    public func deletePaymentMethod(id: Int, completion: (CompletionHandler<JSON>)? = nil) -> URLSessionDataTask? {
        guard let request = URLRequest.delete(path: "/payment/get/\(id)/delete") else {
            completion?(Result(error: .cannotBuildRequest))
            return nil
        }
        
        return self.execute(request: request, completion: completion)
    }
    
    
    
}
