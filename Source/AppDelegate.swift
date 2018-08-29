//
//  AppDelegate.swift
//  PrePacked
//
//  Created by Gabriel Jones on 11/07/2016.
//  Copyright © 2016 Fireminds Ltd. All rights reserved.
//

import UIKit
import SwiftyJSON
import Reachability

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, URLSessionDelegate {

    var window: UIWindow?
    
    func setupUI() {
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedStringKey.font: UIFont(name: "GothamRounded-Medium", size: 17)!
        ]
        let defaultSize = UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes[NSAttributedStringKey.font.rawValue] as? CGFloat
        let attributes = [NSAttributedStringKey.font.rawValue: Font.gotham(size: defaultSize ?? 16.0)]
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = attributes
//        UITabBarItem.appearance().setTitleTextAttributes(
//            [NSAttributedStringKey.font: UIFont(name: "GothamRounded-Medium", size: 14)!], for: .normal
//        )
        UITabBarItem.appearance().setTitleTextAttributes(
            [NSAttributedStringKey.font: UIFont(name: "GothamRounded-Bold", size: 14)!], for: .selected
        )
        UITabBarItem.appearance().titlePositionAdjustment.vertical = -4
    }
    
    func j() -> Bool {
        #if arch(i386) || arch(x86_64)
            return false
        #else
            return FileManager.default.fileExists(atPath: "/private/var/lib/apt")
        #endif
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        setupUI()
        
        //TODO: remove in production
        /**/
        NSSetUncaughtExceptionHandler { exception in
            print(exception.callStackSymbols)
            print(exception.name)
        }
        /**/
                
        window = UIWindow(frame: UIScreen.main.bounds)
        let initialVC = LoadingViewController()
        window?.rootViewController = initialVC
        window?.makeKeyAndVisible()
        return !j()
    }
}

/*
 
 ,'``.._   ,'``.
 :,--._:)\,:,._,.:       All Glory to
 :`--,''   :`...';\      the HYPNO TOAD!
 `,'       `---'  `.
 /                 :
 /                   \
 ,'                     :\.___,-.
 `...,---'``````-..._    |:       \
 (                 )   ;:    )   \  _,-.
 `.              (   //          `'    \
 :               `.//  )      )     , ;
 ,-|`.            _,'/       )    ) ,' ,'
 (  :`.`-..____..=:.-':     .     _,' ,'
 `,'\ ``--....-)='    `._,  \  ,') _ '``._
 _.-/ _ `.       (_)      /     )' ; / \ \`-.'
 `--(   `-:`.     `' ___..'  _,-'   |/   `.)
 `-. `.`.``-----``--,  .'
 |/`.\`'        ,','); SSt
               (/  (/
 */
