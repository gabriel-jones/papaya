//
//  DetailItemViewController.swift
//  PrePacked
//
//  Created by Gabriel Jones on 15/07/2016.
//  Copyright © 2016 Fireminds Ltd. All rights reserved.
//

import UIKit

protocol AddGroceriesDelegate {
    func reHighlight()
}

protocol DetailDelegate: class {
    func didFinishDetail()
    func didFinishDetailWith(item toGoTo: Item?)
}

class DetailItemViewController: BaseVC, UITextFieldDelegate, DetailDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.quantity.text = ""
    }
    
    func didFinishDetailWith(item toGoTo: Item?) {
        print("did finish with item")
        self.v.removeFromSuperview()
        self.dismiss(animated: false) {
            self.delegate.didCloseWith(item: toGoTo)
        }
    }

    //MARK: - Properties
    var delegate: ItemDetailDelegate!
    var item: Item!
    var inventoryParent = false
    var n: Int = 1 {
        didSet {
            if n < 1 {
                n = 1
            }
            else if n > item.stock {
                n = item.stock
            }
            self.quantity.text = "\(n)"
        }
    }
    
    func closeVC() {
        self.delegate.didClose()
        self.dismiss(animated: true, completion: nil)
    }

    //MARK: - Outlets
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var likeButton: LargeButton!
    @IBOutlet weak var likeImage: UIImageView!
    
    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var stock: UILabel!
    
    @IBOutlet weak var buyButton: LargeButton!
    @IBOutlet weak var quantity: UITextField!
    @IBOutlet weak var plus: LargeButton!
    @IBOutlet weak var minus: LargeButton!
    
    @IBOutlet weak var compare: LargeButton!
    @IBOutlet weak var close: LargeButton!
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var shopName: UILabel!
    
    @IBOutlet weak var buyView: UIView!
    @IBOutlet weak var notifyLabel: UILabel!
    @IBOutlet weak var inventoryOK: LargeButton!
    
    override func viewDidLoad() {
        let border = CALayer()
        let width = CGFloat(2.0)
        border.borderColor = Color.green.cgColor
        border.frame = CGRect(x: 0, y: quantity.frame.size.height - width, width:  quantity.frame.size.width, height: quantity.frame.size.height)
        
        border.borderWidth = width
        
        quantity.layer.borderWidth = 0.0
        quantity.layer.borderColor = UIColor.clear.cgColor
        quantity.layer.addSublayer(border)
        quantity.layer.masksToBounds = true
        quantity.addTarget(self, action: #selector(textDidChange(_:)), for: UIControlEvents.editingChanged)
        quantity.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        let _tap = UITapGestureRecognizer(target: self, action: #selector(imageTap))
        self.image.isUserInteractionEnabled = true
        self.image.addGestureRecognizer(_tap)
        
        self.name.text = item.name
        self.likeImage.image = self.item.isLiked ? #imageLiteral(resourceName: "Heart Red Filled") : #imageLiteral(resourceName: "Heart Grey")
        
        close.action = {
            self.closeVC()
        }
        
        likeButton.action = {
            self.likeImage.image = self.item.isLiked ? #imageLiteral(resourceName: "Heart Grey") : #imageLiteral(resourceName: "Heart Red Filled")
            User.current.saveLiked(self, liked: !self.item.isLiked, item: self.item)
            self.item.isLiked = !self.item.isLiked
            self.delegate.changeLiked(i: self.item, liked: self.item.isLiked)
        }
        
        self.category.text = item.category
        self.price.text = item.price.currency_format
        self.stock.text = item.stock.comma_format
        self.quantity.text = "1"
        
        self.plus.holdRepeatFire = true
        self.plus.action = {
            self.n += 1
        }
        
        self.minus.holdRepeatFire = true
        self.minus.action = {
            self.n -= 1
        }
        
        self.buyButton.action = {
            if self.quantity.text == "" {
                self.n = 1
            }
            
            self.delegate.addItem(i: self.item, n: self.n)
            self.closeVC()
        }
        
        self.inventoryOK.action = {
            self.closeVC()
        }
        
        if self.inventoryParent {
            self.notifyLabel.isHidden = false
            self.buyView.isHidden = true
            self.inventoryOK.isHidden = false
        } else {
            self.buyView.isHidden = false
            self.notifyLabel.isHidden = true
            self.inventoryOK.isHidden = true
        }
        
        let tbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44))
        tbar.barStyle = .default
        let flex = UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let tbar_done = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneInput))
        tbar.items = [flex,tbar_done]
        
        quantity.inputAccessoryView = tbar
        
        shopName.text = "@ " + item.shop.name
        
        compare.action = compareItem
    }
    
    func compareItem() {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "CompareVC") as! CompareVC
        vc.item = self.item
        vc.delegate = self
        vc.modalPresentationStyle = .overCurrentContext
        
        v = UIView(frame: self.view.frame)
        v.backgroundColor = .black
        v.alpha = 0.9
        self.view.addSubview(v)
        
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func doneInput() {
        quantity.resignFirstResponder()
    }
    
    var imageLoaded = false
    var isDownloading = false
    
    override func viewWillAppear(_ animated: Bool) {
        guard self.item.id != 0 else {
            self.image.image = #imageLiteral(resourceName: "Picture Grey")
            self.image.contentMode = .center
            return
        }
        
        let onData = Network.reachability!.status == .wwan
        let lowDataUsage = UserDefaults.standard.bool(forKey: "useLessData") && onData
        
        let img = self.delegate.getImage(id: self.item.id)
        if img != nil && lowDataUsage {
            self.image.image = img!
            self.image.contentMode = .scaleAspectFit
            return
        }
        isDownloading = true
        R.loadImageAsync(img: URL(string: C.URL.main + "/scripts/Inventory/get_image.php?id=\(self.item.id)&res=\(lowDataUsage ? "low" : "med")")!, itemId: self.item.id) { img in
            self.isDownloading = false
            if let i = img {
                UIView.animate(withDuration: 0.15, animations: {
                    self.image.alpha = 0.0
                }, completion: { _ in
                    self.image.contentMode = .scaleAspectFit
                    self.image.image = i
                    UIView.animate(withDuration: 0.15, animations: {
                        self.image.alpha = 1.0
                    }, completion: { _ in
                        self.imageLoaded = true
                    })
                })
            }
        }
        
    }
    
    func didFinishDetail() {
        self.v.removeFromSuperview()
    }
    
    var v: UIView!
    
    @objc func imageTap() {
        if !imageLoaded && !isDownloading { return }
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "ImageDetailVC") as! ImageDetailVC
        vc.image = self.image.image
        vc.delegate = self
        vc.id = item.id
        vc.modalPresentationStyle = .overCurrentContext
        
        v = UIView(frame: self.view.frame)
        v.backgroundColor = .black
        v.alpha = 0.9
        self.view.addSubview(v)
        
        
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func textDidChange(_ sender: LoginTextField) {
        if sender.text != "" {
            n = Int(sender.text!)!
        }
    }
    
    @objc override func tap(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if view.frame.origin.y == 0{
                view.frame.origin.y -= keyboardSize.height
            }
        }
        
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if view.frame.origin.y != 0{
                view.frame.origin.y += keyboardSize.height
            }
        }
    }
    
}

