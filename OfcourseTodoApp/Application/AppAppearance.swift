//
//  AppAppearance.swift
//  OfcourseTodoApp
//
//  Created by Иван Романович on 01.11.2024.
//

import UIKit

final class AppAppearance {
    
    static func setupAppearance() {
        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
            appearance.backgroundColor = .clear
            UINavigationBar.appearance().tintColor = .black
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        } else {
            UINavigationBar.appearance().barTintColor = .black
            UINavigationBar.appearance().tintColor = .black
            UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        }
    }
}

extension UINavigationController {
    @objc override open var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
}
