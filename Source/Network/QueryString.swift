//
//  QueryString.swift
//  Papaya
//
//  Created by Gabriel Jones on 12/24/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import Foundation

private let allowedCharacterSet = CharacterSet(charactersIn: "!$&'()*+,-./0123456789:;=?@ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz~")

public protocol QueryEscapableString {
    var addPercentEncoding: String { get }
}

extension String: QueryEscapableString {
    public var addPercentEncoding: String {
        get {
            return (self as NSString).addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? self
        }
    }
}

extension Dictionary where Key: QueryEscapableString, Value: QueryEscapableString {
    var urlQueryString: String {
        get {
            return self.map({"\($0.addPercentEncoding)=\($1.addPercentEncoding)"}).joined(separator: "&")
        }
    }
}
