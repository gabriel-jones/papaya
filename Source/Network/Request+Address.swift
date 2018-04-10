//
//  Request+Address.swift
//  Papaya
//
//  Created by Gabriel Jones on 12/24/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import Foundation
import SwiftyJSON

extension Request {
    
    @discardableResult
    public func getAllAddresses(completion: (CompletionHandler<[Address]>)? = nil) -> URLSessionDataTask? {
        guard let request = URLRequest.get(path: "/address/all") else {
            completion?(Result(error: .cannotBuildRequest))
            return nil
        }
        
        return self.execute(request: request, parseMethod: parse.json2Addresses, completion: completion)
    }
    
    @discardableResult
    public func getAddress(addressId: Int, completion: (CompletionHandler<Address>)? = nil) -> URLSessionDataTask? {
        guard let request = URLRequest.get(path: "/address/get/\(addressId)") else {
            completion?(Result(error: .cannotBuildRequest))
            return nil
        }
        
        return self.execute(request: request, parseMethod: parse.json2Address, completion: completion)
    }
    
    public func getAddressImage(address: Address, completion: @escaping (UIImage) -> Void) {
        guard let request = URLRequest.get(path: "/address/get/\(address.id)/img") else {
            return
        }
        
        self.session.dataTask(with: request) { data, response, error in
            if let data = data, let img = UIImage(data: data) {
                completion(img)
            }
        }.resume()
    }
    
    @discardableResult
    public func addAddress(street: String, zipCode: String, completion: (CompletionHandler<JSON>)? = nil) -> URLSessionDataTask? {
        let body = [
            "street": street,
            "zip_code": zipCode
        ]
        
        guard let request = URLRequest.post(path: "/address/add", body: body) else {
            completion?(Result(error: .cannotBuildRequest))
            return nil
        }
        
        return self.execute(request: request, completion: completion)
    }
    
    @discardableResult
    public func updateAddress(address: Address, completion: (CompletionHandler<JSON>)? = nil) -> URLSessionDataTask? {
        let body = [
            "street": address.street,
            "zip_code": address.zip
        ]
        
        guard let request = URLRequest.put(path: "/address/get/\(address.id)/update", body: body) else {
            completion?(Result(error: .cannotBuildRequest))
            return nil
        }
        
        return self.execute(request: request, completion: completion)
    }
    
    @discardableResult
    public func deleteAddress(address: Address, completion: (CompletionHandler<JSON>)? = nil) -> URLSessionDataTask? {
        guard let request = URLRequest.delete(path: "/address/get/\(address.id)/delete") else {
            completion?(Result(error: .cannotBuildRequest))
            return nil
        }
        
        return self.execute(request: request, completion: completion)
    }
}
