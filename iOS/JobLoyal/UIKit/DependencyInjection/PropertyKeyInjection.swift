//
//  PropertyKeys.swift
//  Master
//
//  Created by Sina khanjani on 11/27/1399 AP.
//

import Foundation

private struct PropertyKeys {
    static private(set) var dicts: [String: String] = [:]
    
    static func add(key: String, value: String) {
        dicts.updateValue(value, forKey: key)
    }
    
    static func value(key: String) -> String {
        if let value = dicts[key] {
            return value
        }
        fatalError("Key is not valid!")
    }
}

public protocol PropertyKeyInjection { }

public extension PropertyKeyInjection {
    func addUniqueKey(_ key: String,_ value: String) { PropertyKeys.add(key: key, value: value) }
    
    func getUniqueKey(_ key: String) -> String { PropertyKeys.value(key: key) }
}
