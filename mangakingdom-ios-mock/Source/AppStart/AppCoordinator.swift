//
//  AppCoordinator.swift
//  mangakingdom-ios-mock
//
//  Created by Kim Cortez on 5/3/22.
//

import Foundation
import UIKit
import Combine

class AppCoordinator {
    
    private let window: UIWindow
    
    private var cancellables = Set<AnyCancellable>()
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        let dataLoaderController = DataLoaderController()
        dataLoaderController.$minimumDataLoadFinished
            .sink { dataReady in
                if dataReady {
                    self.loadHome()
                }
            }
            .store(in: &cancellables)
        
        window.rootViewController = dataLoaderController
        window.makeKeyAndVisible()
    }
    
    private func loadHome() {
        let homeController = HomeController()
        
        window.rootViewController = homeController
        window.makeKeyAndVisible()
    }
    
}
