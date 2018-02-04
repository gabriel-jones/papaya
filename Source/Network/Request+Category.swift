//
//  Request+Category.swift
//  Papaya
//
//  Created by Gabriel Jones on 1/23/18.
//  Copyright © 2018 Papaya. All rights reserved.
//

import Foundation
import SwiftyJSON
import RxSwift

extension Request {
    func getAllCategories() -> Observable<[Category]> {
        guard let request = URLRequest.get(path: "/category/all") else {
            return Observable.error(RequestError.cannotBuildRequest)
        }
        
        return self.fetch(request: request)
            .flatMap(parse.json2Categories)
    }
    
    func get(category id: Int) -> Observable<Category> {
        guard let request = URLRequest.get(path: "/category/get/\(id)") else {
            return Observable.error(RequestError.cannotBuildRequest)
        }
        
        return self.fetch(request: request)
            .flatMap(parse.json2Category)
    }
    
    func getSubcategories(category: Category) -> Observable<[Category]> {
        guard let request = URLRequest.get(path: "/category/get/\(category.id)") else {
            return Observable.error(RequestError.cannotBuildRequest)
        }
        
        return self.fetch(request: request)
            .flatMap(parse.json2Subcategories)
    }
    
    func getItems(category: Category) -> Observable<[Item]> {
        guard let request = URLRequest.get(path: "/category/get/\(category.id)/items") else {
            return Observable.error(RequestError.cannotBuildRequest)
        }
        
        return self.fetch(request: request)
            .flatMap(parse.json2Items)
    }
}
