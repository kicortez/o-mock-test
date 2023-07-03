//
//  Notification+Extensions.swift
//  mangakingdom-ios-mock
//
//  Created by Kim Cortez on 5/25/22.
//

import Foundation

extension Notification.Name {
    static let MangaTappedNotification = Notification.Name("MangaTappedNotification")
    static let MangaScrolledNotification = Notification.Name("MangaScrolledNotification")
    static let BottomBarHiddenNotification = Notification.Name("BottomBarHiddenNotification")
    static let BottomBarDisplayedNotification = Notification.Name("BottomBarDisplayedNotification")
    static let ForceHideBottomBarNotification = Notification.Name("ForceHideBottomBarNotification")
    static let ForceShowBarsNotification = Notification.Name("ForceShowBarsNotification")
}
