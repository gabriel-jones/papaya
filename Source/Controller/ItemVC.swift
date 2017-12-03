//
//  ItemVC.swift
//  Papaya
//
//  Created by Gabriel Jones on 11/16/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import UIKit

class ItemVC: UIViewController {
    
    //MARK: - Properties
    var item: Item?
    
    
    //MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var toolbar: UIView!
    
    
    //MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        toolbar.layer.addBorder(edge: .top, color: .darkGray, thickness: 0.5)
    }
    
    @IBAction func addToCart(_ sender: UIButton) {
        print("add Item to cart")
    }
    
    
}

extension CALayer {
    
    func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {
        
        let border = CALayer()
        
        switch edge {
        case UIRectEdge.top:
            border.frame = CGRect.init(x: 0, y: 0, width: frame.width, height: thickness)
            break
        case UIRectEdge.bottom:
            border.frame = CGRect.init(x: 0, y: frame.height - thickness, width: frame.width, height: thickness)
            break
        case UIRectEdge.left:
            border.frame = CGRect.init(x: 0, y: 0, width: thickness, height: frame.height)
            break
        case UIRectEdge.right:
            border.frame = CGRect.init(x: frame.width - thickness, y: 0, width: thickness, height: frame.height)
            break
        default:
            break
        }
        
        border.backgroundColor = color.cgColor;
        
        self.addSublayer(border)
    }
}

extension ItemVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
