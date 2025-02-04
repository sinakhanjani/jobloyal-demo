//
//  IdentifierHandler.swift
//  JobLoyal
//
//  Created by Sina khanjani on 4/7/1400 AP.
//

import Foundation
import RestfulAPI

struct IdentifierHandler {
    
    private var authentication: Authentication
    
    init(authentication: Authentication) {
        self.authentication = authentication
    }
    
    private var inMemoryVCIdentifier: [String] = []
    
    func isContain(currentVCDescription: String) -> Bool {
        print("isContain: \(inMemoryVCIdentifier) currentIdentifier: \(currentVCDescription)")
        return inMemoryVCIdentifier.contains(currentVCDescription)
    }
        
    mutating func append(identifier: String) {
        if !inMemoryVCIdentifier.contains(identifier) {
            inMemoryVCIdentifier.append(identifier)
        }
    }
    
    mutating func remove(identifier: String) {
        let index = inMemoryVCIdentifier.lastIndex { (i) -> Bool in
            i == identifier
        }
        
        if let index = index {
            inMemoryVCIdentifier.remove(at: index)
        }
    }
    
    mutating func reset() {
        self.inMemoryVCIdentifier = []
    }
}
