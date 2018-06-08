//
//  AddressListViewController.swift
//  Papaya
//
//  Created by Gabriel Jones on 1/18/18.
//  Copyright © 2018 Papaya. All rights reserved.
//

import UIKit
import GSMessages

protocol AddressListModal {
    func chose(address: Address)
}

class AddressListViewController: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private var addButton: UIBarButtonItem!
    private let refreshControl = UIRefreshControl()
    private var closeButton: UIBarButtonItem?
    private let retryButton = UIButton()
    
    private var addresses = [Address]()
    private var isLoading = true
    
    public var isModal: Bool = false
    public var delegate: AddressListModal?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.buildViews()
        self.buildConstraints()
        self.initialLoad()
    }
    
    @objc private func add(_ sender: UIBarButtonItem?) {
        let vc = AddressDetailViewController()
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true, completion: nil)
    }
    
    @objc private func loadAddresses() {
        isLoading = true
        retryButton.isHidden = true
        
        Request.shared.getAllAddresses { result in
            self.isLoading = false
            self.refreshControl.endRefreshing()
            switch result {
            case .success(let addresses):
                self.hideMessage()
                self.addresses = addresses
                self.tableView.isHidden = false
                self.tableView.reloadData()
            case .failure(let error):
                print(error.localizedDescription)
                self.retryButton.isHidden = false
                self.showMessage("Can't fetch addresses", type: .error, options: [
                    .autoHide(false),
                    .hideOnTap(false)
                ])
            }
        }
    }
    
    private func initialLoad() {
        refreshControl.beginRefreshing()
        tableView.isHidden = true
        self.loadAddresses()
    }
    
    private func buildViews() {
        view.backgroundColor = UIColor(named: .backgroundGrey)
        
        navigationItem.title = "Addresses"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .done, target: self, action: nil)
        
        addButton = UIBarButtonItem(title: "Add", style: .done, target: self, action: #selector(add(_:)))
        addButton.setTitleTextAttributes([.font: Font.gotham(size: 17)], for: .normal)
        addButton.setTitleTextAttributes([.font: Font.gotham(size: 17)], for: .highlighted)
        addButton.tintColor = UIColor(named: .green)
        navigationItem.rightBarButtonItem = addButton
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.alwaysBounceVertical = true
        tableView.register(EmptyTableViewCell.classForCoder(), forCellReuseIdentifier: EmptyTableViewCell.identifier)
        view.addSubview(tableView)

        refreshControl.addTarget(self, action: #selector(refreshTable), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        retryButton.setTitle("Retry", for: .normal)
        retryButton.setImage(#imageLiteral(resourceName: "Replace").tintable, for: .normal)
        retryButton.setTitleColor(.black, for: .normal)
        retryButton.tintColor = .black
        retryButton.titleLabel?.font = Font.gotham(size: 15)
        retryButton.addTarget(self, action: #selector(loadAddresses), for: .touchUpInside)
        retryButton.alignVertical()
        retryButton.isHidden = true
        view.addSubview(retryButton)
        
        if isModal {
            closeButton = UIBarButtonItem(image: #imageLiteral(resourceName: "Close").tintable, style: .done, target: self, action: #selector(close(_:)))
            closeButton?.tintColor = UIColor(named: .green)
            navigationItem.leftBarButtonItem = closeButton
            
            navigationItem.title = "Select an Address"
        }
    }
    
    @objc private func close(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func refreshTable() {
        self.loadAddresses()
    }
    
    private func buildConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        retryButton.snp.makeConstraints { make in
            make.width.height.equalTo(50)
            make.center.equalToSuperview()
        }
    }
}

extension AddressListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading { return 0 }
        return addresses.isEmpty ? 1 : addresses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if addresses.isEmpty {
            tableView.separatorColor = .clear
            let cell = tableView.dequeueReusableCell(withIdentifier: EmptyTableViewCell.identifier, for: indexPath) as! EmptyTableViewCell
            cell.buttonText = "Add an address"
            cell.emptyText = "You have no saved addresses."
            cell.img = #imageLiteral(resourceName: "Address")
            cell.delegate = self
            return cell
        }
        let address = addresses[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: C.ViewModel.CellIdentifier.addressCell.rawValue)
        cell.textLabel?.text = address.street
        cell.textLabel?.font = Font.gotham(size: 16)
        cell.detailTextLabel?.text = address.zip
        cell.detailTextLabel?.font = Font.gotham(size: 14)
        cell.detailTextLabel?.textColor = .lightGray
        cell.imageView?.image = #imageLiteral(resourceName: "Address").tintable
        cell.imageView?.tintColor = .lightGray
        if !isModal {
            cell.accessoryType = .disclosureIndicator
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return addresses.isEmpty ? 300 : 65
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if addresses.isEmpty { return }
        let address = addresses[indexPath.row]
        
        if isModal {
            delegate?.chose(address: address)
            navigationController?.dismiss(animated: true, completion: nil)
            return
        }
        
        let vc = AddressDetailViewController()
        vc.address = address
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension AddressListViewController: EmptyTableViewCellDelegate {
    func tappedButton() {
        self.add(nil)
    }
}
