//
//  AppDelegate.swift
//  GCChartSwift
//
//  Created by 古创 on 2021/2/7.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow.init(frame: UIScreen.main.bounds)
        window?.rootViewController = UINavigationController(rootViewController: GCChartMainViewController())
        window?.makeKeyAndVisible()
        
        return true
    }



}

