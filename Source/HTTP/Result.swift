//
//  Result.swift
//  Papaya
//
//  Created by Gabriel Jones on 12/23/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import Foundation

enum Result<A> {
    case success(A)
    case failure(Error)
    
    public init(value: A) {
        self = .success(value)
    }
    
    public init(fromOptional: A?, error: Error) {
        if let value = fromOptional {
            self = .success(value)
        } else {
            self = .failure(error)
        }
    }
    
    public init(from: A, optional error: Error?) {
        if let error = error {
            self = .failure(error)
        } else {
            self = .success(from)
        }
    }
    
    public init(error: Error?) {
        if let error = error {
            self = .failure(error)
        } else {
            self = .failure(RequestError.unknown)
        }
    }
    
    func package<B>(ifSuccess: (A) -> B, ifFailure: (Error) -> B) -> B {
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
    
    public var error: Error? {
        switch self {
        case .failure(let error):
            return error
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
