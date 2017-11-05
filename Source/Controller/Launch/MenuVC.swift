//
//  MenuVC.swift
//  PrePacked
//
//  Created by Gabriel Jones on 07/09/2016.
//  Copyright © 2016 Fireminds Ltd. All rights reserved.
//

import UIKit

struct MenuItem {
    var title: String
    var img: UIImage?
    var action: () -> ()
    var isSmall: Bool
    
    init(title: String, img: UIImage?, action: @escaping () -> (), isSmall: Bool = false) {
        self.title = title
        self.img = img
        self.action = action
        self.isSmall
            = isSmall
    }
}

class MenuVC: UIViewController {
    
    //MARK: - Methods
    func share() {
        DispatchQueue.main.async {
            let a = UIActivityViewController(activityItems: ["www.prepacked.bm is the Bermudian app that lets you shop online."], applicationActivities: nil)
            self.present(a, animated: true, completion: nil)
        }
    }
    
    func help() {
        UIApplication.shared.open(URL(string: "https://www.prepacked.bm/help")!, options: [:], completionHandler: nil)
    }
    
    //MARK: - Properties
    
    var options = [MenuItem]()
    
    //MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK: - View Methods
    
    func open(_ vcName: String, _ storyboard: Storyboard) {
        
        let vc = UIStoryboard(name: storyboard.rawValue, bundle: Bundle.main).instantiateViewController(withIdentifier: vcName)
        
        if vcName == "SettingsNavVC" {
            self.present(vc, animated: true, completion: nil)
            return
        }
        
        let _vc = UINavigationController(rootViewController: vc)
        _vc.isNavigationBarHidden = true
        self.present(_vc, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        options = [
            MenuItem(title: "Settings", img: #imageLiteral(resourceName: "Settings White"), action: {self.open("SettingsNavVC", .settings)}),
            MenuItem(title: "Inventory", img: #imageLiteral(resourceName: "Product White Filled"), action: {self.open("InventoryVC", .main)}),
            MenuItem(title: "Lists", img: #imageLiteral(resourceName: "Checklist White"), action: {self.open("ListsVC", .lists)}),
            MenuItem(title: "History", img: #imageLiteral(resourceName: "Clock White"), action: {self.open("ListsVC", .lists)}),
            MenuItem(title: "", img: nil, action: {}, isSmall: true)
        ]
    }
    
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
        self.revealViewController().revealToggle(animated: true)
        super.present(viewControllerToPresent, animated: flag, completion: completion)
    }
}

extension MenuVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return options.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("select \(indexPath.row)")
        options[indexPath.row].action()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let o = options[indexPath.row]
        if o.isSmall {
            let c = collectionView.dequeueReusableCell(withReuseIdentifier: "smallCell", for: indexPath) as! SmallMenuCell
            c.button1.action = share
            c.button2.action = help
            c.label1.text = "Share"
            c.label2.text = "Help"
            return c
        }
        let c = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CustomMenuCell
        c.img.image = o.img
        c.title.text = o.title
        return c
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.layer.masksToBounds = true
        cell.cornerRadius = cell.frame.width / 13
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = collectionView.frame.width - 16
        let s = options[indexPath.row].isSmall
        return CGSize(width: w, height: s ? 50 : 85)
    }
}

class CustomMenuCell: UICollectionViewCell {
    @IBOutlet weak var background: LargeButton!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var title: UILabel!
}

class SmallMenuCell: UICollectionViewCell {
    @IBOutlet weak var button1: LargeButton!
    @IBOutlet weak var button2: LargeButton!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    
}

