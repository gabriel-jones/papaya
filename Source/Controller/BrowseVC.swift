//
//  BrowseVC.swift
//  Papaya
//
//  Created by Gabriel Jones on 11/11/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import UIKit

class BrowseVC: TabChildVC {
    
    var aisles = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        aisles = ["Produce", "Dairy", "Frozen", "Deli", "Canned", "Meat", "Pasta", "Snacks", "Other"]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? AisleVC {
            //do something
        }
    }
}

extension BrowseVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toAisleVC", sender: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return aisles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "aisleCell", for: indexPath) as! BrowseAisleCell
        cell.aisleName.text = aisles[indexPath.row]
        cell.imageView.pin_setPlaceholder(with: #imageLiteral(resourceName: "Placeholder"))
        cell.imageView.pin_setImage(from: URL(string: C.URL.main + "/img/browse/\(aisles[indexPath.row].lowercased()).jpg")!)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.width / 2) - 12, height: 150)
    }
}

class BrowseAisleCell: UICollectionViewCell {
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var aisleName: UILabel!
    @IBOutlet weak var imageView: UIImageView!
}
