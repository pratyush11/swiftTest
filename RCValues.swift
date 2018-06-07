//
//  RCValues.swift
//  
//
//  Created by Pratyush on 2/12/18.
//

import Foundation
import Firebase

class RCValues {
    
    static let sharedInstance = RCValues()
    
    private init() {
        loadDefaultValues()
    }
    
    func loadDefaultValues() {
        let appDefaults: [String: NSObject] = [
            "appPrimaryColor" : "#FBB03B" as NSObject
        ]
        FIRRemoteConfig.remoteConfig().setDefaults(appDefaults)
    }
}

