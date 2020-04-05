//
//  Result.swift
//  Papaya
//
//  Created by Gabriel Jones on 3/25/18.
//  Copyright © 2018 Papaya Ltd. All rights reserved.
//

import Foundation

enum Result<A> {
    case success(A)
    case failure(RequestError)
    
    public init(value: A) {
        self = .success(value)
    }
    
    public init(fromOptional: A?, error: RequestError) {
        if let value = fromOptional {
            self = .success(value)
        } else {
            self = .failure(error)
        }
    }
    
    public init(from: A, optional error: NSError?) {
        if let error = error {
            if let error = RequestError(rawValue: error.code) {
                self = .failure(error)
            }
            self = .failure(RequestError.unknown)
        } else {
            self = .success(from)
        }
    }
    
    public init(error: RequestError?) {
        if let error = error {
            self = .failure(error)
        } else {
            self = .failure(RequestError.unknown)
        }
    }
    
    func package<B>(ifSuccess: (A) -> B, ifFailure: (RequestError) -> B) -> B {
        switch self {
        case .success(let value):
            return ifSuccess(value)
        case .failure(let value):
            return ifFailure(value)
        }
    }
    
    func map<B>(_ transform: (A) -> B) -> Result<B> {
        return flatMap { .success(transform($0)) }
    }
    
    public func flatMap<B>(_ transform: (A) -> Result<B>) -> Result<B> {
        return package(
            ifSuccess: transform,
            ifFailure: Result<B>.failure)
    }
    
    public var error: RequestError? {
        switch self {
        case .failure(_):
            return self.error
        default:
            return nil
        }
    }
    
    public var value: A? {
        switch self {
        case .success(let success):
            return success
        default:
            return nil
        }
    }
}

