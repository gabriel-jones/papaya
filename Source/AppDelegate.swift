//
//  AppDelegate.swift
//  PrePacked
//
//  Created by Gabriel Jones on 11/07/2016.
//  Copyright © 2016 Fireminds Ltd. All rights reserved.
//

import UIKit
import SwiftyJSON
import RxSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, URLSessionDelegate {

    var window: UIWindow?
    
    func setupUI() {
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedStringKey.font: UIFont(name: "GothamRounded-Medium", size: 17)!
        ]
        /*
        UITabBarItem.appearance().setTitleTextAttributes(
            [NSAttributedStringKey.font: UIFont(name: "GothamRounded-Medium", size: 14)!], for: .normal
        )*/
        UITabBarItem.appearance().setTitleTextAttributes(
            [NSAttributedStringKey.font: UIFont(name: "GothamRounded-Bold", size: 14)!], for: .selected
        )
    }
    
    func j() -> Bool {
        #if arch(i386) || arch(x86_64)
            return false
        #else
            return FileManager.default.fileExistsAtPath("/private/var/lib/apt")
        #endif
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        setupUI()
        
        _ = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
            .subscribe { _ in
                //print("Resource count \(RxSwift.Resources.total)")
            }
        
        //TODO: remove in production
        /**/
        NSSetUncaughtExceptionHandler { exception in
            print(exception)
            print(exception.callStackSymbols)
        }
        /**/
        
        if UserDefaults.standard.object(forKey: "useLessData") == nil {
            UserDefaults.standard.set(true, forKey: "useLessData")
            UserDefaults.standard.synchronize()
        }
        
        do {
            Network.reachability = try Reachability(hostname: "www.google.com")
            do {
                try Network.reachability?.start()
            } catch let error as Network.Error {
                print(error)
            } catch {
                print(error)
            }
        } catch {
            print(error)
        }
        
        NotificationRouter.shared.setupObservers()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        let loadingVC = LoadingVC()
        window?.rootViewController = loadingVC
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
