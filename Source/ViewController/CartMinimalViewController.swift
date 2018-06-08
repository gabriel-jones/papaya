//
//  CartMinimalViewController.swift
//  Papaya
//
//  Created by Gabriel Jones on 3/22/18.
//  Copyright © 2018 Papaya. All rights reserved.
//

import UIKit

class CartMinimalViewController: UIViewController {
    
    public var cart: Cart!
    
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private var closeButton: UIBarButtonItem?
    private var itemCount: UIBarButtonItem?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.buildViews()
        self.buildConstraints()
    }
    
    private func buildViews() {
        navigationItem.title = "Cart"
        view.backgroundColor = .white
        
        closeButton = UIBarButtonItem(image: #imageLiteral(resourceName: "Close").tintable, style: .done, target: self, action: #selector(close(_:)))
        closeButton?.tintColor = UIColor(named: .green)
        navigationItem.leftBarButtonItem = closeButton
        
        itemCount = UIBarButtonItem(title: "\(cart.items.count) items", style: .plain, target: nil, action: nil)
        itemCount?.tintColor = .black
        itemCount?.setTitleTextAttributes([.font: Font.gotham(size: 15)], for: .normal)
        navigationItem.rightBarButtonItem = itemCount
        
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 0.01))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: C.ViewModel.CellIdentifier.cartItemCell.rawValue)
        view.addSubview(tableView)
    }
    
    @objc private func close(_ sender: UIBarButtonItem) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    private func buildConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension CartMinimalViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cart.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: C.ViewModel.CellIdentifier.cartItemCell.rawValue)
        let item = cart.items[indexPath.row]
        cell.textLabel?.text = "(\(item.quantity))  " + item.item.name
        cell.textLabel?.textColor = .black
        cell.textLabel?.font = Font.gotham(size: 14)
        cell.detailTextLabel?.text = (Double(item.quantity) * item.item.price).currencyFormat
        cell.detailTextLabel?.textColor = .gray
        cell.detailTextLabel?.font = Font.gotham(size: 14)
        cell.selectionStyle = .none
        cell.separatorInset = UIEdgeInsets.zero
        return cell
    }
}
