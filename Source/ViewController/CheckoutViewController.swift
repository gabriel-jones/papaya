//
//  CheckoutViewController.swift
//  Papaya
//
//  Created by Gabriel Jones on 2/6/18.
//  Copyright © 2018 Papaya. All rights reserved.
//

import UIKit
import SwiftyJSON // todo: remove

class CheckoutViewController: UIViewController {

    private let tableView = UITableView(frame: .zero, style: .grouped)
    private let toolbar = UIView()
    private let toolbarBorder = UIView()
    private let checkoutButton = LoadingButton()
    private let orderType = UISegmentedControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buildViews()
        self.buildConstraints()
    }
    
    private func buildViews() {
        view.backgroundColor = UIColor(named: .backgroundGrey)
        navigationItem.title = "Review"
        
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.register(CheckoutMapTableViewCell.classForCoder(), forCellReuseIdentifier: CheckoutMapTableViewCell.identifier)
        tableView.register(CheckoutCartTableViewCell.classForCoder(), forCellReuseIdentifier: CheckoutCartTableViewCell.identifier)
        view.addSubview(tableView)
        
        // Toolbar
        toolbar.backgroundColor = UIColor(named: .backgroundGrey)
        view.addSubview(toolbar)
        
        // Toolbar border
        toolbarBorder.backgroundColor = UIColor(red: 0.796, green: 0.796, blue: 0.812, alpha: 0.5)
        toolbar.addSubview(toolbarBorder)
        
        // Add to cart
        checkoutButton.backgroundColor = UIColor(named: .green)
        checkoutButton.layer.cornerRadius = 5
        checkoutButton.setTitle("Place order", for: .normal)
        checkoutButton.setTitleColor(.white, for: .normal)
        checkoutButton.titleLabel?.font = Font.gotham(weight: .bold, size: 17)
        checkoutButton.addTarget(self, action: #selector(placeOrder(_:)), for: .touchUpInside)
        toolbar.addSubview(checkoutButton)
        
        orderType.backgroundColor = .white
        orderType.selectedSegmentIndex = 0
        orderType.insertSegment(withTitle: "Delivery", at: 0, animated: false)
        orderType.insertSegment(withTitle: "Pickup", at: 1, animated: false)
        orderType.tintColor = UIColor(named: .green)
        orderType.setTitleTextAttributes([NSAttributedStringKey.font: Font.gotham(size: 15)], for: .normal)
        orderType.addTarget(self, action: #selector(changeOrderType(_:)), for: .valueChanged)
        orderType.selectedSegmentIndex = 0
    }
    
    private func buildConstraints() {
        tableView.snp.makeConstraints { make in
            make.top.right.left.equalToSuperview()
            make.bottom.equalTo(toolbar.snp.top)
        }
        
        toolbar.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(65)
        }
        
        toolbarBorder.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        checkoutButton.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }
    }
    
    @objc private func placeOrder(_ sender: LoadingButton) {
        
    }
    
    @objc private func changeOrderType(_ sender: UISegmentedControl) {
        
    }
    

}

extension CheckoutViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return [0: 2, 1: 1, 2: 2, 3: 4][section] ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let cell = UITableViewCell(style: .value1, reuseIdentifier: C.ViewModel.CellIdentifier.deliveryTimeCell.rawValue)
                cell.textLabel?.text = "Delivery Friday at 1pm – 2pm"
                cell.textLabel?.font = Font.gotham(size: 15)
                cell.accessoryType = .disclosureIndicator
                cell.detailTextLabel?.text = "Edit"
                cell.detailTextLabel?.font = Font.gotham(size: 13)
                cell.detailTextLabel?.textColor = .gray
                cell.imageView?.image = #imageLiteral(resourceName: "Notification").tintable
                cell.imageView?.tintColor = .gray
                cell.separatorInset = .zero
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: CheckoutMapTableViewCell.identifier, for: indexPath) as! CheckoutMapTableViewCell
                cell.load(address: Address(dict: JSON(["id": 6, "street": "32 Highwood Lane", "zip_code": "PG05"]))!)
                return cell
            default: break
            }
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: CheckoutCartTableViewCell.identifier, for: indexPath) as! CheckoutCartTableViewCell
            //cell.load(cart: cart)
            return cell
        case 2:
            let cell = UITableViewCell(style: .value1, reuseIdentifier: C.ViewModel.CellIdentifier.checkoutTotalCell.rawValue)
            cell.detailTextLabel?.textColor = .gray
            cell.detailTextLabel?.font = Font.gotham(size: 14)
            switch indexPath.row {
            case 0: // payment method
                let attr = NSMutableAttributedString(string: "Payment Method: Card")
                attr.addAttribute(.foregroundColor, value: UIColor.gray, range: NSMakeRange(0, 15))
                cell.textLabel?.attributedText = attr
                cell.textLabel?.font = Font.gotham(size: 15)
                let arrow = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
                arrow.image = #imageLiteral(resourceName: "Right Arrow").tintable
                arrow.tintColor = .gray
                arrow.transform = arrow.transform.rotated(by: .pi / 2)
                cell.accessoryView = arrow
            case 1: // payment detail
                cell.imageView?.image = #imageLiteral(resourceName: "Card").tintable
                cell.imageView?.tintColor = .gray
                cell.textLabel?.text = "**** **** **** 1234"
                cell.textLabel?.font = Font.gotham(size: 15)
                cell.accessoryType = .disclosureIndicator
                cell.detailTextLabel?.text = "Edit"
                cell.separatorInset = .zero
            default: break
            }
            return cell
        case 3:
            let cell = UITableViewCell(style: .value1, reuseIdentifier: C.ViewModel.CellIdentifier.checkoutTotalCell.rawValue)
            cell.detailTextLabel?.textColor = .gray
            cell.detailTextLabel?.font = Font.gotham(size: 14)
            switch indexPath.row {
            case 0...3:
                cell.textLabel?.text = ["Cart Subtotal", "Service Fee", "Tip", "Total"][indexPath.row]
                cell.textLabel?.textColor = indexPath.row == 3 ? .black : .gray
                cell.textLabel?.font = Font.gotham(size: 14)
                cell.detailTextLabel?.text = "$99.99"
                cell.imageView?.image = indexPath.row == 3 ? nil : UIImage()
            default: break
            }
            return cell
        default: break
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                return 50
            } else if indexPath.row == 1 {
                return 125
            }
        } else if indexPath.section == 1 {
            return 125
        }
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 && indexPath.row == 0 {
            // edit delivery time
        }
        if indexPath.section == 2 {
            if indexPath.row == 0 {
                // edit payment type
            } else if indexPath.row == 1 {
                // edit payment selected
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section != 0 {
            return nil
        }
        let container = UIView()
        container.backgroundColor = .clear
        container.addSubview(orderType)
        orderType.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }
        return container
    }
}
