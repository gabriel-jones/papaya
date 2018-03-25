//
//  Request+Checkout.swift
//  Papaya
//
//  Created by Gabriel Jones on 3/16/18.
//  Copyright © 2018 Papaya. All rights reserved.
//

import Foundation
import SwiftyJSON
import RxSwift

extension Request {
    public func createCheckout() -> Observable<Checkout> {
        guard let request = URLRequest.post(path: "/checkout/create") else {
            return Observable.error(RequestError.cannotBuildRequest)
        }
        
        return self.fetch(request: request)
        .flatMap(parse.json2Checkout)
    }
    
    public func getCheckout() -> Observable<Checkout> {
        guard let request = URLRequest.post(path: "/checkout") else {
            return Observable.error(RequestError.cannotBuildRequest)
        }
        
        return self.fetch(request: request)
        .flatMap(parse.json2Checkout)
    }
    
    public func updateCheckout(orderDate: Date) -> Observable<JSON> {
        let body = [
            "date": "FORMAT_REQUIRED" //TODO: formatting dates
        ]
        guard let request = URLRequest.put(path: "/checkout/update/time", body: body) else {
            return Observable.error(RequestError.cannotBuildRequest)
        }
        
        return self.fetch(request: request)
    }
    
    public func updateCheckout(address: Address) -> Observable<JSON> {
        let body = [
            "address_id": address.id
        ]
        guard let request = URLRequest.put(path: "/checkout/update/address", body: body) else {
            return Observable.error(RequestError.cannotBuildRequest)
        }
        
        return self.fetch(request: request)
    }
    
    public func updateCheckout(isDelivery: Bool) -> Observable<JSON> {
        let body = [
            "is_delivery": isDelivery
        ]
        guard let request = URLRequest.put(path: "/checkout/update/type", body: body) else {
            return Observable.error(RequestError.cannotBuildRequest)
        }
        
        return self.fetch(request: request)
    }
}

