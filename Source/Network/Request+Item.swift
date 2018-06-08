//
//  Request+Item.swift
//  Papaya
//
//  Created by Gabriel Jones on 1/31/18.
//  Copyright © 2018 Papaya. All rights reserved.
//

import Foundation
import SwiftyJSON

extension Request {
    @discardableResult
    public func getAllItemsTemp(page: Int = 1, completion: (CompletionHandler<PaginatedResults<Item>>)? = nil) -> URLSessionDataTask? {
        guard let request = URLRequest.get(path: "/item/all/\(page)") else {
            completion?(Result(error: .cannotBuildRequest))
            return nil
        }
        
        return self.execute(request: request, parseMethod: parse.json2PaginatedItems, completion: completion)
    }
    
    @discardableResult
    public func getCommonItems(page: Int = 1, completion: (CompletionHandler<PaginatedResults<Item>>)? = nil) -> URLSessionDataTask? {
        guard let request = URLRequest.get(path: "/item/common/\(page)") else {
            completion?(Result(error: .cannotBuildRequest))
            return nil
        }
        
        return self.execute(request: request, parseMethod: parse.json2PaginatedItems, completion: completion)
    }
    
    @discardableResult
    public func getRecentItems(page: Int = 1, completion: (CompletionHandler<PaginatedResults<Item>>)? = nil) -> URLSessionDataTask? {
        guard let request = URLRequest.get(path: "/item/recent/\(page)") else {
            completion?(Result(error: .cannotBuildRequest))
            return nil
        }
        
        return self.execute(request: request, parseMethod: parse.json2PaginatedItems, completion: completion)
    }
    
    @discardableResult
    public func getSimilarItems(toItem: Item, page: Int = 1, completion: (CompletionHandler<PaginatedResults<Item>>)? = nil) -> URLSessionDataTask? {
        guard let request = URLRequest.get(path: "/item/\(toItem.id)/similar/\(page)") else {
            completion?(Result(error: .cannotBuildRequest))
            return nil
        }
        
        return self.execute(request: request, parseMethod: parse.json2PaginatedItems, completion: completion)
    }
    
    @discardableResult
    public func setLiked(item: Item, to: Bool, completion: (CompletionHandler<JSON>)? = nil) -> URLSessionDataTask? {
        guard let request = URLRequest.put(path: "/item/\(item.id)/like/\(to)") else {
            completion?(Result(error: .cannotBuildRequest))
            return nil
        }
        
        return self.execute(request: request, completion: completion)
    }
    
    @discardableResult
    public func getDetail(item: Item, completion: (CompletionHandler<JSON>)? = nil) -> URLSessionDataTask? {
        guard let request = URLRequest.get(path: "/item/\(item.id)/detail") else {
            completion?(Result(error: .cannotBuildRequest))
            return nil
        }
        
        return self.execute(request: request, completion: completion)
    }
}
