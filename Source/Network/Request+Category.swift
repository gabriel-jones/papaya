//
//  Request+Category.swift
//  Papaya
//
//  Created by Gabriel Jones on 1/23/18.
//  Copyright © 2018 Papaya. All rights reserved.
//

import Foundation
import SwiftyJSON

extension Request {
    
    @discardableResult
    public func getAllCategories(completion: (CompletionHandler<[Category]>)? = nil) -> URLSessionDataTask? {
        guard let request = URLRequest.get(path: "/category/all") else {
            completion?(Result(error: .cannotBuildRequest))
            return nil
        }
        
        return self.execute(request: request, parseMethod: parse.json2Categories, completion: completion)
    }
    
    @discardableResult
    public func getCategory(categoryId: Int, completion: (CompletionHandler<Category>)? = nil) -> URLSessionDataTask? {
        guard let request = URLRequest.get(path: "/category/get/\(categoryId)") else {
            completion?(Result(error: .cannotBuildRequest))
            return nil
        }
        
        return self.execute(request: request, parseMethod: parse.json2Category, completion: completion)
    }
    
    @discardableResult
    public func getSubcategories(category: Category, completion: (CompletionHandler<[Category]>)? = nil) -> URLSessionDataTask? {
        guard let request = URLRequest.get(path: "/category/get/\(category.id)") else {
            completion?(Result(error: .cannotBuildRequest))
            return nil
        }
        
        return self.execute(request: request, parseMethod: parse.json2Subcategories, completion: completion)
    }
    
    @discardableResult
    public func getItems(category: Category, completion: (CompletionHandler<[Item]>)? = nil) -> URLSessionDataTask? {
        guard let request = URLRequest.get(path: "/category/get/\(category.id)/items") else {
            completion?(Result(error: .cannotBuildRequest))
            return nil
        }
        
        return self.execute(request: request, parseMethod: parse.json2Items, completion: completion)
    }
}
