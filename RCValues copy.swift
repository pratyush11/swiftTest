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
        fetchCloudValues()
        //print(RemoteConfig.remoteConfig().configValue(forKey: "appPrimaryColor").stringValue!)
    }
    
    func loadDefaultValues() {
        let appDefaults: [String: NSObject] = [
            "appPrimaryColor" : "#FBB03B" as NSObject
        ]
        RemoteConfig.remoteConfig().setDefaults(appDefaults)
    }
    func fetchCloudValues() {
        let fetchDuration: TimeInterval = 0
        activateDebugMode()
        RemoteConfig.remoteConfig().fetch(withExpirationDuration: fetchDuration) {
            [weak self] (status, error) in
            
            guard error == nil else {
                print ("Uh-oh. Got an error fetching remote values \(error!)")
                return
            }
            RemoteConfig.remoteConfig().activateFetched()
            print ("Retrieved values from the cloud!")
            print(RemoteConfig.remoteConfig().configValue(forKey: "appPrimaryColor").stringValue!)
        }
    }
    func activateDebugMode() {
        let debugSettings = RemoteConfigSettings(developerModeEnabled: true)
        RemoteConfig.remoteConfig().configSettings = debugSettings!
    }
}

