//
//  BaseVC.swift
//  PrePacked
//
//  Created by Gabriel Jones on 15/08/2017.
//  Copyright © 2017 Fireminds Ltd. All rights reserved.
//

import UIKit

class BaseVC: UIViewController {
    
    
    //MARK: - Properties
    private var overlay: UIView!
    private var loading: LoadingIndicator!
    
    
    //MARK: - View Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overlay = UIView(frame: self.view.frame)
        overlay.backgroundColor = .black
        overlay.alpha = 0.5
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
    }
    
    func addOverlay(_ viewController: UIViewController? = nil, animated: Bool = true, completion: (() -> ())? = nil) {
        self.view.addSubview(overlay)
        if let vc = viewController {
            vc.modalPresentationStyle = .overCurrentContext
            self.present(vc, animated: animated, completion: nil)
        }
    }
    
    func closeOverlay(animated: Bool = true) {
        print("close overlay")
        self.overlay.removeFromSuperview()
    }
    
    //MARK: - Methods
    
    @objc func tap(_ sender: UITapGestureRecognizer) {
        
    }
    
    func load() {
        view.endEditing(true)
        
        overlay = UIView(frame: CGRect(x: 0, y: -50, width: view.frame.width, height: view.frame.height + 104))
        overlay.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.4)
        
        loading = LoadingIndicator(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        loading.center = overlay.center
        overlay.addSubview(loading)
        
        view.addSubview(overlay)
        loading.startAnimating()
    }
    
    func stopLoading() {
        overlay.removeFromSuperview()
        overlay = nil
        
        loading.removeFromSuperview()
        loading = nil
    }
    
}
