//
//  LoginVC_ViewModel.swift
//  Papaya
//
//  Created by Gabriel Jones on 1/13/18.
//  Copyright © 2018 Papaya. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct LoginViewModel {
    
    let disposeBag = DisposeBag()
    
    var isValid: Observable<Bool>
    var email = PublishSubject<String>()
    var password = PublishSubject<String>()
    
    init() {
        isValid = Observable.just(false)
        isValid = PublishSubject.combineLatest(email, password) { e, p in
            !e.isEmpty && !p.isEmpty && self.validate(email: e)
        }.asObservable()
    }
    
    func validate(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    func login() -> Observable<String> {
        return PublishSubject.combineLatest(email, password)
            .flatMap { e, p in
                Request.shared.login(email: e, password: p)
            }
    }
}
