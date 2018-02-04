//
//  NotificationRouter.swift
//  Papaya
//
//  Created by Gabriel Jones on 1/29/18.
//  Copyright © 2018 Papaya. All rights reserved.
//

import Foundation
import RxSwift

class NotificationRouter {
    public static let shared = NotificationRouter()
    
    private var didSetup = false
    private let disposeBag = DisposeBag()
    
    public func setupObservers() {
        if didSetup { return }
        didSetup = true
        for notification in C.Notification.allRoutedNotifications {
            NotificationCenter.default.addObserver(self, selector: #selector(observe(notification:)), name: NSNotification.Name(rawValue: notification.value), object: nil)
        }
    }
    
    public func post(notification: C.Notification, userInfo: [AnyHashable: Any]?) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: notification.value), object: nil, userInfo: userInfo)
    }
    
    @objc private func observe(notification: Notification) {
        if let n = C.Notification.convert(name: notification.name.rawValue) {
            switch n {
            case .updateCartItem:
                self.updateCartItem(notification.userInfo)
            default: break
            }
        }
    }
    
    private func updateCartItem(_ userInfo: [AnyHashable: Any]?) {
        guard let cartItem = userInfo?["cartItem"] as? CartItem else {
            return
        }
        Request.shared.update(cartItem: cartItem)
        .subscribe()
        .disposed(by: disposeBag)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
