//
//  AddressListViewController.swift
//  Papaya
//
//  Created by Gabriel Jones on 1/18/18.
//  Copyright © 2018 Papaya. All rights reserved.
//

import UIKit
import RxSwift

protocol AddressListModal {
    func chose(address: Address)
}

class AddressListViewController: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private var addButton: UIBarButtonItem!
    private let activityIndicator = UIActivityIndicatorView()
    private let refreshControl = UIRefreshControl()
    private var closeButton: UIBarButtonItem?
    
    private var addresses = [Address]()
    private let disposeBag = DisposeBag()
    private var isLoading = false
    
    public var isModal: Bool = false
    public var delegate: AddressListModal?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.buildViews()
        self.buildConstraints()
    }
    
    @objc private func add(_ sender: UIBarButtonItem?) {
        let vc = AddressDetailViewController()
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true, completion: nil)
    }
    
    private func loadAddresses(_ completion: @escaping () -> Void) {
        isLoading = true
        Request.shared.getAllAddresses()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] addresses in
                self.isLoading = false
                self.addresses = addresses
                self.tableView.reloadData()
                completion()
            }, onError: { [unowned self] error in
                self.isLoading = false
            })
            .disposed(by: disposeBag)
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
        tableView.register(EmptyTableViewCell.classForCoder(), forCellReuseIdentifier: EmptyTableViewCell.identifier)
        view.addSubview(tableView)

        refreshControl.addTarget(self, action: #selector(refreshTable), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        activityIndicator.activityIndicatorViewStyle = .gray
        activityIndicator.hidesWhenStopped = true
        tableView.addSubview(activityIndicator)
        
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
        loadAddresses {
            self.refreshControl.endRefreshing()
            self.tableView.reloadData()
        }
    }
    
    private func buildConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(50)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        activityIndicator.startAnimating()
        self.loadAddresses {
            self.activityIndicator.stopAnimating()
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
