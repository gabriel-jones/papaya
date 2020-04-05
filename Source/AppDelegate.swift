//
//  AppDelegate.swift
//  PrePacked
//
//  Created by Gabriel Jones on 11/07/2018.
//  Copyright © 2018 Ltd. All rights reserved.
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
        
        UIApplication.shared.applicationIconBadgeNumber = 0
                
        window = UIWindow(frame: UIScreen.main.bounds)
        let initialVC = LoadingViewController()
        window?.rootViewController = initialVC
        window?.makeKeyAndVisible()
        return !j()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        let token = tokenParts.joined()
        print("Got device token: \(token)")
        Request.shared.addNotification(apnsToken: token)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications with error: \(error)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let id = userInfo["order_id"] as? Int {
            let vc = StatusViewController()
            vc.orderId = id
            switch application.applicationState {
            case .active:
                window?.rootViewController?.present(vc, animated: true, completion: nil)
            case .background:
                break
            case .inactive:
                break
            }
            print(window?.rootViewController as Any)
        }
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
