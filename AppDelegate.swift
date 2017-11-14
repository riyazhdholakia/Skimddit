//
//  AppDelegate.swift
//  Skimddit
//
//  Created by Riyazh Dholakia on 10/16/17.
//  Copyright © 2017 Riyazh. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if url.scheme == "skimddit" {
            finishAuth(with: url)
            return true
        } else {
            return false
        }
    }
    
    func finishAuth(with url: URL) {
        if let fragment = url.fragment {
            var accessToken: String? {
                for item in fragment.split(separator: "&") {
                    let pair = item.split(separator: "=")
                    guard pair.count == 2 else { continue }
                    if pair[0] == "access_token" { return String(pair[1]) }
                }
                return nil
            }
             UserDefaults.standard.set(accessToken, forKey: "Token")
            NotificationCenter.default.post(name: loginNotificationCenterName, object: nil)
        }
    }
}
