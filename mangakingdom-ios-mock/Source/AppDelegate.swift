//
//  AppDelegate.swift
//  mangakingdom-ios-mock
//
//  Created by Kim Cortez on 5/3/22.
//

import UIKit
import FirebaseCore
import FirebaseAuth

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var appCoordinator: AppCoordinator?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
        startApp()

        return true
    }
    
    private func startApp() {
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let coordinator = AppCoordinator(window: window!)
        coordinator.start()
        
        appCoordinator = coordinator
    }

}

