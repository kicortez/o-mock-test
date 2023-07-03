//
//  UIViewController+Extensions.swift
//  mangakingdom-ios-mock
//
//  Created by Kim Cortez on 5/4/22.
//

import Foundation
import UIKit

extension UIViewController {
    func remove(asChild viewController: UIViewController) {
        viewController.willMove(toParent: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
    }

    func add(asChild viewController: UIViewController, container: UIView) {
        addChild(viewController)
        
        container.addSubview(viewController.view)
        
        viewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        viewController.didMove(toParent: self)
    }
}
