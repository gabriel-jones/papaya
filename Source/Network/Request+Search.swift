//
//  Request+Search.swift
//  Papaya
//
//  Created by Gabriel Jones on 2/4/18.
//  Copyright © 2018 Papaya. All rights reserved.
//

import Foundation
import SwiftyJSON

extension Request {
    /*
    @discardableResult
    public func search(query: String, completion: (CompletionHandler<PaginatedResults<Item>>)? = nil) -> URLSessionDataTask? {
        guard let request = URLRequest.get(path: "/search/q/\(query)") else {
            completion?(Result(error: .cannotBuildRequest))
            return nil
        }
        
        return self.execute(request: request, parseMethod: parse.json2Paginated, completion: completion)
    }*/
    
    @discardableResult
    public func popularSearches(completion: (CompletionHandler<[String]>)? = nil) -> URLSessionDataTask? {
        guard let request = URLRequest.get(path: "/search/popular") else {
            completion?(Result(error: .cannotBuildRequest))
            return nil
        }
        
        return self.execute(request: request, parseMethod: parse.json2Searches, completion: completion)
    }
    
    @discardableResult
    public func autocompletion(completion: (CompletionHandler<[String]>)? = nil) -> URLSessionDataTask? {
        guard let request = URLRequest.get(path: "/search/autocomplete") else {
            completion?(Result(error: .cannotBuildRequest))
            return nil
        }
        
        return self.execute(request: request, parseMethod: parse.json2Searches, completion: completion)
    }
}
