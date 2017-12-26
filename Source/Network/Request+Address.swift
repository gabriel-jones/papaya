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
    func getAllAddresses(completion: @escaping (Result<[Address]>) -> ()) throws -> URLSessionDataTask {
        guard let request = URLRequest.get(path: "/address/all")
            else { throw RequestError.cannotBuildRequest }
        
        let handler = { (data: Data?, response: URLResponse?, error: NSError?) -> Result<[Address]> in
            return Result(from: Response(data: data, urlResponse: response), optional: error)
                .flatMap(response2Data)
                .flatMap(data2Json)
                .flatMap(json2Addresses)
        }
        
        return execute(request: request, handleResponse: handler, completion: completion)
    }
    
    @discardableResult
    func get(address id: Int, completion: @escaping (Result<Address>) -> ()) throws -> URLSessionDataTask {
        guard let request = URLRequest.get(path: "/address/get/\(id)")
            else { throw RequestError.cannotBuildRequest }
        
        let handler = { (data: Data?, response: URLResponse?, error: NSError?) -> Result<Address> in
            return Result(from: Response(data: data, urlResponse: response), optional: error)
                .flatMap(response2Data)
                .flatMap(data2Json)
                .flatMap(json2Address)
        }
        
        return execute(request: request, handleResponse: handler, completion: completion)
    }
    
    @discardableResult
    func add(street: String, zip: String, completion: @escaping (Result<JSON>) -> ()) throws -> URLSessionDataTask {
        let body = [
            "street": street,
            "zip_code": zip
        ]
        
        guard let request = URLRequest.post(path: "/address/add", body: body)
            else { throw RequestError.cannotBuildRequest }
        
        let handler = { (data: Data?, response: URLResponse?, error: NSError?) -> Result<JSON> in
            return Result(from: Response(data: data, urlResponse: response), optional: error)
                .flatMap(response2Data)
                .flatMap(data2Json)
        }
        
        return execute(request: request, handleResponse: handler, completion: completion)
    }
    
    @discardableResult
    func update(address: Address, completion: @escaping (Result<JSON>) -> ()) throws -> URLSessionDataTask {
        let body = [
            "street": address.street,
            "zip_code": address.zip
        ]
        
        guard let request = URLRequest.put(path: "/address/get/\(address.id)/update", body: body)
            else { throw RequestError.cannotBuildRequest }
        
        let handler = { (data: Data?, response: URLResponse?, error: NSError?) -> Result<JSON> in
            return Result(from: Response(data: data, urlResponse: response), optional: error)
                .flatMap(response2Data)
                .flatMap(data2Json)
        }
        
        return execute(request: request, handleResponse: handler, completion: completion)
    }
    
    @discardableResult
    func delete(address: Address, completion: @escaping (Result<JSON>) -> ()) throws -> URLSessionDataTask {
        guard let request = URLRequest.delete(path: "/address/get/\(address.id)/dete")
            else { throw RequestError.cannotBuildRequest }
        
        let handler = { (data: Data?, response: URLResponse?, error: NSError?) -> Result<JSON> in
            return Result(from: Response(data: data, urlResponse: response), optional: error)
                .flatMap(response2Data)
                .flatMap(data2Json)
        }
        
        return execute(request: request, handleResponse: handler, completion: completion)
    }
}
