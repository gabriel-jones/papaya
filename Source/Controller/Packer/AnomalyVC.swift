//
//  AnomalyVC.swift
//  PrePacked
//
//  Created by Gabriel Jones on 31/07/2017.
//  Copyright © 2017 Fireminds Ltd. All rights reserved.
//

import UIKit

protocol AnomalyDelegate {
    func didDismiss(_ reduceTo: Int?)
}

class AnomalyVC: UIViewController {
    
    //MARK: - Properties
    var item: PackItem!
    var order_id: Int!
    var delegate: AnomalyDelegate!
    
    //MARK: - Outlets
    @IBOutlet weak var anomalyStock: AnomalyStockTextField!
    @IBOutlet weak var reduceButton: LargeButton!
    @IBOutlet weak var closeButton: LargeButton!
    @IBOutlet weak var quantityLabel: UILabel!
    
    //MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        quantityLabel.text = "\(self.item.quantity)"
        
        closeButton.action = { self.close(nil) }
        
        reduceButton.action = {
            self.view.endEditing(true)
            if self.anomalyStock.text == "" { return }
            let val = Int(self.anomalyStock.text!)!
            /*
            let a = alert(actions: [
                AlertButton("OK")
            ])
            
            if val == 0 {
                a.showWarning("Cannot reduce", subTitle: "To collect 0, select the \"None\" button on the previous page.")
                return
            } else if val >= self.item.quantity {
                a.showWarning("Cannot reduce", subTitle: "If you have collected all requested of this item, then select the \"All\" button on the previous page.")
                return
            }*/
            self.close(val)
        }
        
        let t = UITapGestureRecognizer(target: self, action: #selector(tap))
        self.view.addGestureRecognizer(t)
    }
    
    //MARK: - Methods
    @objc func tap() {
        self.view.endEditing(true)
    }
    
    func close(_ reduceTo: Int? = nil) {
        self.view.endEditing(true)
        self.delegate.didDismiss(reduceTo)
        self.dismiss(animated: true, completion: nil)
    }
    
}

//UPDATE current_orders SET status = 'sent', packer = NULL;

class AnomalyStockTextField: UITextField {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func becomeFirstResponder() -> Bool {
        super.becomeFirstResponder()
        bottomBorder.backgroundColor = Color.red
        return true
    }
    
    override func resignFirstResponder() -> Bool {
        super.resignFirstResponder()
        bottomBorder.backgroundColor = Color.grey.3
        return true
    }
    
    var bottomBorder: UIView!
    
    override func draw(_ rect: CGRect) {
        bottomBorder = UIView(frame: CGRect(x: 0, y: self.bounds.height-1, width: self.bounds.width, height: 1))
        bottomBorder.backgroundColor = Color.grey.3
        self.addSubview(bottomBorder)
    }
    
}
