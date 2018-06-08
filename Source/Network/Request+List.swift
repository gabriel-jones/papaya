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
    public func getAllLists(completion: (CompletionHandler<[List]>)? = nil) -> URLSessionDataTask? {
        guard let request = URLRequest.get(path: "/list/all") else {
            completion?(Result(error: .cannotBuildRequest))
            return nil
        }
        
        return self.execute(request: request, parseMethod: parse.json2Lists, completion: completion)
    }
    
    @discardableResult
    public func getList(listId: Int, completion: (CompletionHandler<List>)? = nil) -> URLSessionDataTask? {
        guard let request = URLRequest.get(path: "/list/get/\(listId)") else {
            completion?(Result(error: .cannotBuildRequest))
            return nil
        }
        
        return self.execute(request: request, parseMethod: parse.json2List, completion: completion)
    }
    
    @discardableResult
    public func addListToCart(listId: Int, completion: (CompletionHandler<JSON>)? = nil) -> URLSessionDataTask? {
        guard let request = URLRequest.get(path: "/list/get/\(listId)/add_to_cart") else {
            completion?(Result(error: .cannotBuildRequest))
            return nil
        }
        
        return self.execute(request: request, completion: completion)
    }
    
    @discardableResult
    public func addList(name: String, completion: (CompletionHandler<JSON>)? = nil) -> URLSessionDataTask? {
        let body = [
            "name": name
        ]
        guard let request = URLRequest.post(path: "/list/add", body: body) else {
            completion?(Result(error: .cannotBuildRequest))
            return nil
        }
        
        return self.execute(request: request, completion: completion)
    }
    
    @discardableResult
    public func addToList(item: Item, completion: (CompletionHandler<JSON>)? = nil) -> URLSessionDataTask? {
        let body = [
            "item_id": item.id
        ]
        guard let request = URLRequest.post(path: "/list/item/add", body: body) else {
            completion?(Result(error: .cannotBuildRequest))
            return nil
        }
        
        return self.execute(request: request, completion: completion)
    }
    
    @discardableResult
    public func deleteListItem(item: Item, completion: (CompletionHandler<JSON>)? = nil) -> URLSessionDataTask? {
        let urlParameters = [
            "item_id": String(item.id)
        ]
        guard let request = URLRequest.delete(path: "/list/item/delete", body: [:], urlParameters: urlParameters) else {
            completion?(Result(error: .cannotBuildRequest))
            return nil
        }
        
        return self.execute(request: request, completion: completion)
    }
    
    @discardableResult
    public func updateList(list: List, completion: (CompletionHandler<JSON>)? = nil) -> URLSessionDataTask? {
        let body = [
            "name": list.name
        ]
        guard let request = URLRequest.put(path: "/list/get/\(list.id)/update", body: body) else {
            completion?(Result(error: .cannotBuildRequest))
            return nil
        }
        
        return self.execute(request: request, completion: completion)
    }
    
    @discardableResult
    public func deleteList(list: List, completion: (CompletionHandler<JSON>)? = nil) -> URLSessionDataTask? {
        guard let request = URLRequest.delete(path: "/list/delete") else {
            completion?(Result(error: .cannotBuildRequest))
            return nil
        }
        
        return self.execute(request: request, completion: completion)
    }
}
