//
//  Request+Address.swift
//  Papaya
//
//  Created by Gabriel Jones on 12/24/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import Foundation
import SwiftyJSON
import RxSwift

extension Request {
    func getAllAddresses() -> Observable<[Address]> {
        guard let request = URLRequest.get(path: "/address/all") else {
            return Observable.error(RequestError.cannotBuildRequest)
        }
    
        return self.fetch(request: request)
            .flatMap(parse.json2Addresses)
    }
    
    func get(address id: Int) -> Observable<Address> {
        guard let request = URLRequest.get(path: "/address/get/\(id)") else {
            return Observable.error(RequestError.cannotBuildRequest)
        }
    
        return self.fetch(request: request)
            .flatMap(parse.json2Address)
    }
    
    func add(street: String, zipCode: String) -> Observable<JSON> {
        let body = [
            "street": street,
            "zip_code": zipCode
        ]
        
        guard let request = URLRequest.post(path: "/address/all", body: body) else {
            return Observable.error(RequestError.cannotBuildRequest)
        }
        
        return self.fetch(request: request)
    }
    
    func update(address: Address) -> Observable<JSON> {
        let body = [
            "street": address.street,
            "zip_code": address.zip
        ]
        
        guard let request = URLRequest.put(path: "/address/get/\(address.id)/update", body: body) else {
            return Observable.error(RequestError.cannotBuildRequest)
        }
        
        return self.fetch(request: request)
    }
    
    func delete(address: Address) -> Observable<JSON> {
        guard let request = URLRequest.delete(path: "/address/get/\(address.id)/delete") else {
            return Observable.error(RequestError.cannotBuildRequest)
        }
        
        return self.fetch(request: request)
    }
}
