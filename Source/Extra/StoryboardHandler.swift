//
//  StoryboardHandler.swift
//  PrePacked
//
//  Created by Gabriel Jones on 09/09/2017.
//  Copyright © 2017 Fireminds Ltd. All rights reserved.
//

import UIKit

enum Storyboard: String {
    case login

    case main
    case order
    case status
    
    case settings
    case lists

    case packer
    
    var instance: UIStoryboard {
        return UIStoryboard(name: self.rawValue, bundle: Bundle.main)
    }
    
    func viewController<T: UIViewController>(class: T.Type) -> T {
        return self.instance.instantiateViewController(withIdentifier: `class`.storyboardID) as! T
    }
    
    func viewController(name: String) -> UIViewController {
        return self.instance.instantiateViewController(withIdentifier: name)
    }
    
    func initialViewController() -> UIViewController? {
        return instance.instantiateInitialViewController()
    }
}

extension UIViewController {
    class var storyboardID : String {
        return "\(self)"
    }
    
    static func instantiate(from storyboard: Storyboard) -> Self {
        return storyboard.viewController(class: self)
    }
}
