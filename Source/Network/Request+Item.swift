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
    public func getAllItemsTemp(completion: (CompletionHandler<[Item]>)? = nil) -> URLSessionDataTask? {
        guard let request = URLRequest.get(path: "/item/all") else {
            completion?(Result(error: .cannotBuildRequest))
            return nil
        }
        
        return self.execute(request: request, parseMethod: parse.json2Items, completion: completion)
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
