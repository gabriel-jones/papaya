//
//  ItemVC.swift
//  Papaya
//
//  Created by Gabriel Jones on 11/16/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import UIKit

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

class ItemVC: UIViewController {
    
    //MARK: - Properties
    var item: Item? {
        didSet {
            
        }
    }
    
    var indexPath: IndexPath?
    
    var closeButton = UIBarButtonItem()
    var tableView = UITableView(frame: .zero)
    var toolbar = UIView(frame: .zero)
    var toolbarBorder = UIView()
    var addToCart = UIButton(frame: .zero)
    
    //MARK: - Outlets
    
    
    //MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buildViews()
        self.buildConstraints()
    }
    
    private func buildViews() {
        isHeroEnabled = true
        
        // Close button
        closeButton = UIBarButtonItem(image: #imageLiteral(resourceName: "Close").withRenderingMode(.alwaysTemplate), style: .done, target: self, action: #selector(close(_:)))
        closeButton.tintColor = UIColor(named: .green)
        navigationItem.leftBarButtonItem = closeButton
        
        // Table view
        tableView.allowsSelection = false
        tableView.register(ItemDetailTableViewCell.classForCoder(), forCellReuseIdentifier: C.ViewModel.CellIdentifier.itemDetailCell.rawValue)
        tableView.register(GroupTableViewCell.classForCoder(), forCellReuseIdentifier: C.ViewModel.CellIdentifier.itemGroupCell.rawValue)
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        
        // Toolbar
        toolbar.backgroundColor = UIColorFromRGB(0xf7f7f7)
        view.addSubview(toolbar)
        
        // Toolbar border
        toolbarBorder.backgroundColor = UIColor(red: 0.796, green: 0.796, blue: 0.812, alpha: 0.5)
        toolbar.addSubview(toolbarBorder)
        
        // Add to cart
        addToCart.backgroundColor = UIColor(named: .green)
        addToCart.cornerRadius = 5
        addToCart.setTitle("Add to cart", for: .normal)
        addToCart.titleLabel?.textColor = .white
        addToCart.titleLabel?.font = Font.gotham(size: 17)
        addToCart.addTarget(self, action: #selector(addToCart(_:)), for: .touchUpInside)
        toolbar.addSubview(addToCart)
    }
    
    private func buildConstraints() {
        toolbar.snp.makeConstraints { make in
            make.bottom.equalTo(0)
            make.right.equalTo(0)
            make.left.equalTo(0)
            make.height.equalTo(60)
        }
        
        toolbarBorder.snp.makeConstraints { make in
            make.top.equalTo(0)
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.height.equalTo(1)
        }
        
        addToCart.snp.makeConstraints { make in
            make.right.equalTo(-8)
            make.top.equalTo(8)
            make.bottom.equalTo(-8)
            make.width.equalToSuperview().multipliedBy(0.5).offset(-8)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(0)
            make.bottom.equalTo(toolbar.snp.top)
            make.left.equalTo(0)
            make.right.equalTo(0)
        }
    }
    
    @objc func close(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func addToCart(_ sender: UIButton) {
        print("add Item to cart")
    }
    
    
}

extension ItemVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: C.ViewModel.CellIdentifier.itemDetailCell.rawValue, for: indexPath) as! ItemDetailTableViewCell
            cell.set(item: self.item!, indexPath: self.indexPath!)
            print(cell.itemImage.heroID)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return [250][indexPath.row]
    }
}
