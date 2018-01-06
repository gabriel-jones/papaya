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
        if let request = URLRequest.get(path: "/address/all") {
            return Request.shared.fetch(request: request)
                .observeOn(MainScheduler.instance)
                .flatMap(json2Addresses)
        }
        return Observable.error(RequestError.unknown)
    }
    
    func get(address id: Int) -> Observable<Address> {
        if let request = URLRequest.get(path: "/address/get/\(id)") {
            return Request.shared.fetch(request: request)
                .observeOn(MainScheduler.instance)
                .flatMap(json2Address)
        }
        return Observable.error(RequestError.unknown)
    }
    
    func add(street: String, zipCode: String) -> Observable<JSON> {
        let body = [
            "street": street,
            "zip_code": zipCode
        ]
        if let request = URLRequest.post(path: "/address/all", body: body) {
            return Request.shared.fetch(request: request)
                .observeOn(MainScheduler.instance)
        }
        return Observable.error(RequestError.unknown)
    }
    
    func update(address: Address) -> Observable<JSON> {
        let body = [
            "street": address.street,
            "zip_code": address.zip
        ]
        if let request = URLRequest.put(path: "/address/get/\(address.id)/update", body: body) {
            return Request.shared.fetch(request: request)
                .observeOn(MainScheduler.instance)
        }
        return Observable.error(RequestError.unknown)
    }
    
    func delete(address: Address) -> Observable<JSON> {
        if let request = URLRequest.delete(path: "/address/get/\(address.id)/delete") {
            return Request.shared.fetch(request: request)
                .observeOn(MainScheduler.instance)
        }
        return Observable.error(RequestError.unknown)
    }
}
