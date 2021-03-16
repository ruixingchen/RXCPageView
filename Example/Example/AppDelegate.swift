//
//  AppDelegate.swift
//  Example
//
//  Created by ruixingchen on 2021/3/17.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        self.window = UIWindow.init()
        let nav = UINavigationController.init(rootViewController: ViewController.init())
        self.window?.rootViewController = nav
        self.window?.makeKeyAndVisible()
        
        return true
    }

}

