//
//  AddressDetailViewController.swift
//  Papaya
//
//  Created by Gabriel Jones on 1/18/18.
//  Copyright © 2018 Papaya. All rights reserved.
//

import UIKit

struct AddressDetailField {
    var title: String
    var value: String?
}

class AddressDetailViewController: UIViewController {
    
    public var address: Address?
    
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private var saveButton: UIBarButtonItem!
    private var closeButton: UIBarButtonItem?
    
    private var fields = [AddressDetailField]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buildViews()
        self.buildConstraints()
        
        fields = [
            AddressDetailField(title: "Street Address", value: address?.street),
            AddressDetailField(title: "Zip Code", value: address?.zip)
        ]
        
        tableView.reloadData()
    }
    
    private func buildViews() {
        view.backgroundColor = UIColor(named: .backgroundGrey)
        navigationItem.title = "\(address == nil ? "Add" : "Edit") Address"
        
        saveButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(save(_:)))
        saveButton.tintColor = UIColor(named: .green)
        saveButton.setTitleTextAttributes([.font: Font.gotham(size: 17)], for: .normal)
        saveButton.setTitleTextAttributes([.font: Font.gotham(size: 17)], for: .highlighted)
        navigationItem.rightBarButtonItem = saveButton
        
        if address == nil {
            closeButton = UIBarButtonItem(image: #imageLiteral(resourceName: "Close").tintable, style: .done, target: self, action: #selector(close(_:)))
            closeButton?.tintColor = UIColor(named: .green)
            navigationItem.leftBarButtonItem = closeButton
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.backgroundColor = .clear
        tableView.register(SettingsInputTableViewCell.classForCoder(), forCellReuseIdentifier: SettingsInputTableViewCell.identifier)
        tableView.register(SettingsLargeInputTableViewCell.classForCoder(), forCellReuseIdentifier: SettingsLargeInputTableViewCell.identifier)
        view.addSubview(tableView)
    }
    
    private func buildConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func showError(message: String) {
        let alert = UIAlertController(title: "Cannot save address", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @objc private func save(_ sender: UIBarButtonItem) {
        guard
            let streetCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? SettingsInputTableViewCell, let street = streetCell.textField.text,
            let zipCell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? SettingsInputTableViewCell, let zip = zipCell.textField.text
        else {
            return
        }
        
        if street.isEmpty || zip.isEmpty {
            showError(message: "Please fill out all the fields")
            return
        }
        
        address?.street = street
        address?.zip = zip
        
        if let a = address {
            Request.shared.updateAddress(address: a) { result in
                switch result {
                case .success(_):
                    self.dismiss(animated: true, completion: nil)
                case .failure(let error):
                    self.showError(message: "Please try again")
                }
            }
        } else {
            Request.shared.addAddress(street: street, zipCode: zip) { result in
                switch result {
                case .success(_):
                    self.dismiss(animated: true, completion: nil)
                case .failure(let error):
                    self.showError(message: "Please try again")
                }
            }
        }
    }
    
    @objc private func close(_ sender: UIBarButtonItem) {
        view.endEditing(true)
        navigationController?.dismiss(animated: true, completion: nil)
    }
}

extension AddressDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? fields.count : 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 55 : 150
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: SettingsInputTableViewCell.identifier, for: indexPath) as! SettingsInputTableViewCell
            cell.textField.placeholder = fields[indexPath.row].title
            cell.textField.text = fields[indexPath.row].value
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: SettingsLargeInputTableViewCell.identifier, for: indexPath) as! SettingsLargeInputTableViewCell
            cell.textView.placeholder = String(repeating: " ", count: 8) + "Delivery Instructions, e.g. call number or knock (optional)"
            //cell.textValue = address?.instructions
            return cell
        default: return UITableViewCell()
        }
    }
}
