//
//  ReachabilityManager.swift
//  NetworkLayer
//
//  Created by Ahmad on 05/02/2025.
//

import SystemConfiguration
import Foundation

@MainActor
class ReachabilityManager {
    
    // Shared instance
     static let shared = ReachabilityManager()
    
    // Check if network is reachable
    func isNetworkReachable() -> Bool {
        return checkReachability(host: "www.apple.com")
    }
    
    // Check if network is reachable via Wi-Fi
    func isNetworkReachableViaWiFi() -> Bool {
        return checkReachability(host: "www.apple.com") && isWiFi()
    }
    
    // Check if network is reachable via Cellular
    func isNetworkReachableViaCellular() -> Bool {
        return checkReachability(host: "www.apple.com") && !isWiFi()
    }
    
    private func checkReachability(host: String) -> Bool {
        guard let reachability = SCNetworkReachabilityCreateWithName(nil, host) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        let success = SCNetworkReachabilityGetFlags(reachability, &flags)
        
        guard success else { return false }
        
        // Check if the network is reachable
        return flags.contains(.reachable) && !flags.contains(.connectionRequired)
    }
    
    private func isWiFi() -> Bool {
        // Check if the network is Wi-Fi
        var flags: SCNetworkReachabilityFlags = []
        guard let reachability = SCNetworkReachabilityCreateWithName(nil, "www.apple.com") else { return false }
        SCNetworkReachabilityGetFlags(reachability, &flags)
        
        return flags.contains(SCNetworkReachabilityFlags.reachable) == false
    }
}
