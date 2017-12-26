//
//  AppDelegate.swift
//  PrePacked
//
//  Created by Gabriel Jones on 11/07/2016.
//  Copyright © 2016 Fireminds Ltd. All rights reserved.
//

import UIKit
import SwiftyJSON

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, URLSessionDelegate {

    var window: UIWindow?
    
    func setupUI() {
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedStringKey.font: UIFont(name: "GothamRounded-Medium", size: 20)!
        ]
        UITabBarItem.appearance().setTitleTextAttributes(
            [NSAttributedStringKey.font: UIFont(name: "GothamRounded-Medium", size: 11)!], for: .normal
        )
        UITabBarItem.appearance().setTitleTextAttributes(
            [NSAttributedStringKey.font: UIFont(name: "GothamRounded-Bold", size: 11)!], for: .selected
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
        
        //TODO: remove in production
        NSSetUncaughtExceptionHandler { exception in
            print(exception)
            print(exception.callStackSymbols)
        }
        
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
