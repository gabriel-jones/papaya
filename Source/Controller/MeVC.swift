//
//  MeVC.swift
//  Papaya
//
//  Created by Gabriel Jones on 11/11/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import UIKit

class MeVC: TabChildVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let settingsButton = UIBarButtonItem(image: #imageLiteral(resourceName: "Settings"), style: .plain, target: self, action: #selector(openSettings(_:)))
        settingsButton.tintColor = Color.green
        navigationItem.leftBarButtonItem = settingsButton
    }
    
    @objc func openSettings(_ sender: UIBarButtonItem) {
        print("Open Settings")
    }
}

extension MeVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listSectionCell", for: indexPath) as! MeListCell
        cell.sectionTitle.text = "Lists"
        cell.viewAll = {
            print("See all Lists")
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
}

class MeListCell: UITableViewCell {
    var lists = [List]()
    
    var viewAll: (() -> ())? = nil
    
    @IBAction func seeAll(_ sender: Any) {
        viewAll?()
    }
    
    @IBOutlet weak var sectionTitle: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
}

extension MeListCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return lists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "listCell", for: indexPath) as! MeListItemCell
        return cell
    }
}

class MeListItemCell: UICollectionViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var subtitle: UILabel!
}
