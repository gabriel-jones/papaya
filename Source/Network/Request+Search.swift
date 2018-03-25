//
//  Request+Search.swift
//  Papaya
//
//  Created by Gabriel Jones on 2/4/18.
//  Copyright © 2018 Papaya. All rights reserved.
//

import Foundation
import RxSwift
import SwiftyJSON

struct PaginatedResults<T> {
    let isLast: Bool
    let results: Array<T>
}

extension Request {
    public func search(query: String) -> Observable<PaginatedResults<Item>> {
        guard let request = URLRequest.get(path: "/search/q/\(query)") else {
            return Observable.error(RequestError.cannotBuildRequest)
        }
        return self.fetch(request: request)
            .flatMap(parse.json2Paginated<Item>)
    }
    
    public func popularSearches() -> Observable<[String]> {
        guard let request = URLRequest.get(path: "/search/popular") else {
            return Observable.error(RequestError.cannotBuildRequest)
        }
        return self.fetch(request: request)
            .flatMap(parse.json2Searches)
    }
    
    public func autocompletion() -> Observable<[String]> {
        guard let request = URLRequest.get(path: "/search/autocomplete") else {
            return Observable.error(RequestError.cannotBuildRequest)
        }
        return self.fetch(request: request)
            .flatMap(parse.json2Searches)
    }
}
