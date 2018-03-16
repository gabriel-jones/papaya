//
//  Request+Checkout.swift
//  Papaya
//
//  Created by Gabriel Jones on 3/16/18.
//  Copyright © 2018 Papaya. All rights reserved.
//

import Foundation
import SwiftyJSON
import RxSwift

extension Request {
    public func setLiked(item: Item, to: Bool) -> Observable<JSON> {
        guard let request = URLRequest.put(path: "/item/\(item.id)/like/\(to)") else {
            return Observable.error(RequestError.cannotBuildRequest)
        }
        
        return self.fetch(request: request)
    }
}

