//
//  Request+List.swift
//  Papaya
//
//  Created by Gabriel Jones on 12/24/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import Foundation
import SwiftyJSON

extension Request {
    
    @discardableResult
    func getAllLists(completion: @escaping (Result<[List]>) -> ()) throws -> URLSessionDataTask {
        do {
            guard let request = URLRequest.get(path: "/list/all")
                else { throw RequestError.cannotBuildRequest }
            
            let handler = { (data: Data?, response: URLResponse?, error: NSError?) -> Result<[List]> in
                return Result(from: Response(data: data, urlResponse: response), optional: error)
                    .flatMap(response2Data)
                    .flatMap(data2Json)
                    .flatMap(json2Lists)
            }
            
            return execute(request: request, handleResponse: handler, completion: completion)
        } catch {
            throw error
        }
    }
    
    @discardableResult
    func get(list id: Int, completion: @escaping (Result<List>) -> ()) throws -> URLSessionDataTask {
        do {
            guard let request = URLRequest.get(path: "/list/get/\(id)")
                else { throw RequestError.cannotBuildRequest }
            
            let handler = { (data: Data?, response: URLResponse?, error: NSError?) -> Result<List> in
                return Result(from: Response(data: data, urlResponse: response), optional: error)
                    .flatMap(response2Data)
                    .flatMap(data2Json)
                    .flatMap(json2List)
            }
            
            return execute(request: request, handleResponse: handler, completion: completion)
        } catch {
            throw error
        }
    }
    
    @discardableResult
    func add(list name: String, items: [ListItem], completion: @escaping (Result<JSON>) -> ()) throws -> URLSessionDataTask {
        do {
            let body = [
                "name": name,
                "items": items.map { $0.rawdict }
            ] as [String : Any]
            
            guard let request = URLRequest.post(path: "/list/add", body: body)
                else { throw RequestError.cannotBuildRequest }
            
            let handler = { (data: Data?, response: URLResponse?, error: NSError?) -> Result<JSON> in
                return Result(from: Response(data: data, urlResponse: response), optional: error)
                    .flatMap(response2Data)
                    .flatMap(data2Json)
            }
            
            return execute(request: request, handleResponse: handler, completion: completion)
        } catch {
            throw error
        }
    }
    
    @discardableResult
    func addItem(to list: List, item: ListItem, completion: @escaping (Result<JSON>) -> ()) throws -> URLSessionDataTask {
        do {
            let body = item.rawdict
            
            guard let request = URLRequest.post(path: "/list/get/\(list.id)/item/add", body: body)
                else { throw RequestError.cannotBuildRequest }
            
            let handler = { (data: Data?, response: URLResponse?, error: NSError?) -> Result<JSON> in
                return Result(from: Response(data: data, urlResponse: response), optional: error)
                    .flatMap(response2Data)
                    .flatMap(data2Json)
            }
            
            return execute(request: request, handleResponse: handler, completion: completion)
        } catch {
            throw error
        }
    }
    
    @discardableResult
    func updateItem(for list: List, item: ListItem, completion: @escaping (Result<JSON>) -> ()) throws -> URLSessionDataTask {
        do {
            let body = item.rawdict
            
            guard let request = URLRequest.put(path: "/list/get/\(list.id)/item/update", body: body)
                else { throw RequestError.cannotBuildRequest }
            
            let handler = { (data: Data?, response: URLResponse?, error: NSError?) -> Result<JSON> in
                return Result(from: Response(data: data, urlResponse: response), optional: error)
                    .flatMap(response2Data)
                    .flatMap(data2Json)
            }
            
            return execute(request: request, handleResponse: handler, completion: completion)
        } catch {
            throw error
        }
    }
    
    @discardableResult
    func deleteItem(for list: List, item: ListItem, completion: @escaping (Result<JSON>) -> ()) throws -> URLSessionDataTask {
        do {
            guard let request = URLRequest.delete(path: "/list/get/\(list.id)/item/delete", body: [:], urlParameters: ["item_id": "\(item.id)"])
                else { throw RequestError.cannotBuildRequest }
            
            let handler = { (data: Data?, response: URLResponse?, error: NSError?) -> Result<JSON> in
                return Result(from: Response(data: data, urlResponse: response), optional: error)
                    .flatMap(response2Data)
                    .flatMap(data2Json)
            }
            
            return execute(request: request, handleResponse: handler, completion: completion)
        } catch {
            throw error
        }
    }
    
    @discardableResult
    func update(list: List, completion: @escaping (Result<JSON>) -> ()) throws -> URLSessionDataTask {
        do {
            let body = [
                "name": list.name
            ]
            
            guard let request = URLRequest.put(path: "/list/get/\(list.id)/update", body: body)
                else { throw RequestError.cannotBuildRequest }
            
            let handler = { (data: Data?, response: URLResponse?, error: NSError?) -> Result<JSON> in
                return Result(from: Response(data: data, urlResponse: response), optional: error)
                    .flatMap(response2Data)
                    .flatMap(data2Json)
            }
            
            return execute(request: request, handleResponse: handler, completion: completion)
        } catch {
            throw error
        }
    }
    
    @discardableResult
    func delete(list: List, completion: @escaping (Result<JSON>) -> ()) throws -> URLSessionDataTask {
        do {
            
            guard let request = URLRequest.delete(path: "/list/get/\(list.id)/delete")
                else { throw RequestError.cannotBuildRequest }
            
            let handler = { (data: Data?, response: URLResponse?, error: NSError?) -> Result<JSON> in
                return Result(from: Response(data: data, urlResponse: response), optional: error)
                    .flatMap(response2Data)
                    .flatMap(data2Json)
            }
            
            return execute(request: request, handleResponse: handler, completion: completion)
        } catch {
            throw error
        }
    }
}
