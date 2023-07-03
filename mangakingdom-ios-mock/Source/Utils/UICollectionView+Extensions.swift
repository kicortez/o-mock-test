//
//  UICollectionView+Extensions.swift
//  mangakingdom-ios-mock
//
//  Created by Kim Cortez on 5/3/22.
//

import Foundation
import UIKit

extension UICollectionReusableView {

    static var reuseIdentifier: String {
        return String(describing: self)
    }

}

extension UICollectionView {

    func register<T: UICollectionViewCell>(cell: T.Type) {
        register(T.self, forCellWithReuseIdentifier: cell.reuseIdentifier)
    }

}
