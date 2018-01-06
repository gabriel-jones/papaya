//
//  AisleVC.swift
//  Papaya
//
//  Created by Gabriel Jones on 11/12/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import UIKit

class AisleVC: TabChildVC {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sectionBar: UIView!
    let sections = ["Vegetables", "Fruits", "Pickled Goods and Name"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: C.ViewModel.Nib.itemGroupCell.rawValue, bundle: nil), forCellReuseIdentifier: C.ViewModel.CellIdentifier.itemGroupCell.rawValue)
        
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = CGSize(width: 200, height: sectionBar.frame.height - 16)
        
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: sectionBar.frame.width, height: sectionBar.frame.height), collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: -16)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = true
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: C.ViewModel.CellIdentifier.aisleSectionBarCell.rawValue)
        
        sectionBar.addSubview(collectionView)
        
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect(x: 0, y: sectionBar.frame.height, width: sectionBar.frame.width, height: 0.5)
        bottomBorder.backgroundColor = UIColor.lightGray.cgColor
        sectionBar.layer.addSublayer(bottomBorder)
        
        sectionBar.layer.zPosition = 100
        
    }
    
}

extension AisleVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + sections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: C.ViewModel.CellIdentifier.itemGroupCell.rawValue, for: indexPath) as! GroupTableViewCell
        cell.set(title: indexPath.row == 0 ? "Featured" : sections[indexPath.row-1])
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 225
    }
}

extension AisleVC: ViewAllDelegate {
    func viewAll(sender: Any) {
        print("View all from sender: \(sender)")
    }
}

extension AisleVC {
    @objc func openSection(_ sender: UIButton) {
        print("open section")
    }
}

extension AisleVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: C.ViewModel.CellIdentifier.aisleSectionBarCell.rawValue, for: indexPath)
        cell.backgroundColor = .groupTableViewBackground
        cell.cornerRadius = cell.frame.height / 2
        
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: cell.frame.width, height: cell.frame.height))
        button.setTitle(sections[indexPath.row], for: .normal)
        button.setTitleColor(UIColor(named: .green), for: .normal)
        button.addTarget(self, action: #selector(openSection(_:)), for: .touchUpInside)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = Font.gotham(size: 14)
        cell.addSubview(button)
        
        button.snp.makeConstraints { make in
            make.left.equalTo(cell).offset(16)
            make.right.equalTo(cell).offset(-16)
            make.top.equalTo(cell)
            make.height.equalTo(34)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("open section: \(sections[indexPath.row])")
    }
}
