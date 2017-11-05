//
//  CompareVC.swift
//  PrePacked
//
//  Created by Gabriel Jones on 17/07/2017.
//  Copyright © 2017 Fireminds Ltd. All rights reserved.
//

import UIKit
import SwiftyJSON

class CompareVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var delegate: DetailDelegate!
    var item: Item!
    var similars = [Item]()
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var closeButton: LargeButton!
    @IBOutlet weak var likeLabel: UILabel!
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.likeLabel.text = "Items like: \(item.name)"
        closeButton.action = {
            self.dismiss(animated: true) {
                self.delegate.didFinishDetail()
            }
        }
        
        self.collectionView.alpha = 0.0
        let a = ActivityIndicator(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        a.center = self.view.center
        a.colorType = .Grey
        a.draw()
        a.startAnimating()
        
        R.get("/scripts/Inventory/similar_items.php", parameters: ["item_id": self.item.id]) { json, error in
            guard !error, let j = json else {
                return
            }
        
            self.similars = []
            for item in j.arrayValue {
                self.similars.append(Item(dict: item))
            }
            a.removeFromSuperview()
            self.collectionView.alpha = self.similars.isEmpty ? 0.0 : 1.0
            self.collectionView.reloadData()
            
            if self.similars.isEmpty {
                let lbl = UILabel(frame: CGRect(x: 0, y: 50, width: self.contentView.frame.width, height: 25))
                lbl.text = "NO SIMILAR ITEMS"
                lbl.textAlignment = .center
                lbl.font = UIFont(name: "HelveticaNeue-Medium", size: 12.0)
                lbl.textColor = UIColorFromRGB(0x999999)
                self.contentView.addSubview(lbl)
            }
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? similars.filter { $0.shop_id == self.item.shop_id }.count : similars.filter { $0.shop_id != self.item.shop_id }.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 25)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let h = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! SimilarItemHeaderCell
        h.name.text = indexPath.section == 0 ? self.item.shop.name.uppercased() : "OTHER SHOPS"
        h.isHidden = (indexPath.section == 0 ? similars.filter { $0.shop_id == self.item.shop_id }.count : similars.filter { $0.shop_id != self.item.shop_id }.count) == 0
        return h
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let data = indexPath.section == 0 ? similars.filter { $0.shop_id == self.item.shop_id }[indexPath.row] : similars.filter { $0.shop_id != self.item.shop_id }[indexPath.row]
        let c = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ShoppingItemCell
        c.name.text = data.name
        var s = "\(data.price.currency_format)"
        if indexPath.section != 0 {
            s += " @ \(data.shop.name)"
        }
        c.subtitle.text = s
        
        var col = c.subtitle.textColor
        if data.price > self.item.price {
            col = Color.red
        } else if data.price < self.item.price {
            col = Color.green
        }
        c.subtitle.textColor = col
        
        c.image.image = #imageLiteral(resourceName: "Picture Grey")
        c.image.contentMode = .center
        
        return c
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let data = indexPath.section == 0 ? similars.filter { $0.shop_id == self.item.shop_id }[indexPath.row] : similars.filter { $0.shop_id != self.item.shop_id }[indexPath.row]
            self.dismiss(animated: true) {
                self.delegate.didFinishDetailWith(item: data)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let c = cell as? ShoppingItemCell {
            let data = indexPath.section == 0 ? similars.filter { $0.shop_id == self.item.shop_id }[indexPath.row] : similars.filter { $0.shop_id != self.item.shop_id }[indexPath.row]
            
            if !data.hasImage! {
                return
            }
            
            
            if let img = R.itemImages[data.id] {
                c.image.image = img
                c.image.contentMode = .scaleAspectFit
                return
            }
            
            R.loadImageAsync(img: URL(string: C.URL.main + "/scripts/Inventory/get_image.php?id=\(data.id)&res=low")!, itemId: data.id) { img in
                if let i = img {
                    R.itemImages[data.id] = i
                    if R.itemImages.count > MAX_IMAGE_COUNT {
                        R.itemImages.remove(at: R.itemImages.startIndex)
                    }
                    
                    UIView.animate(withDuration: 0.15, animations: {
                        c.image.alpha = 0.0
                    }, completion: { _ in
                        c.image.contentMode = .scaleAspectFit
                        c.image.image = i
                        UIView.animate(withDuration: 0.15) {
                            c.image.alpha = 1.0
                        }
                    })
                }
            }
        }
    }

}

class SimilarItemHeaderCell: UICollectionReusableView {
    @IBOutlet weak var name: UILabel!
}
