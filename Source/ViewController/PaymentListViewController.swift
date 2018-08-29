//
//  PaymentListViewController.swift
//  Papaya
//
//  Created by Gabriel Jones on 8/26/18.
//  Copyright © 2018 Papaya. All rights reserved.
//

import UIKit
import GSMessages

protocol PaymentListModal {
    func chose(paymentMethod: PaymentMethod)
}

class PaymentListViewController: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private var addButton: UIBarButtonItem!
    private var closeButton: UIBarButtonItem?
    private let retryButton = UIButton()
    private let activityIndicator = LoadingView()
    
    private var payments = [PaymentMethod]()
    private var isLoading = true
    
    public var isModal: Bool = false
    public var delegate: PaymentListModal?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buildViews()
        self.buildConstraints()
        self.initialLoad()
    }
    
    @objc private func add(_ sender: UIBarButtonItem?) {
        let vc = PaymentDetailViewController()
        vc.delegate = self
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true, completion: nil)
    }
    
    @objc private func loadPayments() {
        isLoading = true
        retryButton.isHidden = true
        tableView.reloadData()
        DispatchQueue.main.async { self.activityIndicator.startAnimating() }
        self.hideMessage()

        Request.shared.getAllPayments { result in
            self.isLoading = false
            self.activityIndicator.stopAnimating()
            switch result {
            case .success(let payments):
                self.hideMessage()
                self.payments = payments
                self.tableView.isHidden = false
                self.tableView.reloadData()
            case .failure(_):
                self.retryButton.isHidden = false
                self.showMessage("Can't fetch payment methods", type: .error, options: [
                    .autoHide(false),
                    .hideOnTap(false)
                ])
            }
        }
    }
    
    private func initialLoad() {
        tableView.isHidden = true
        self.loadPayments()
    }
    
    private func buildViews() {
        view.backgroundColor = UIColor(named: .backgroundGrey)
        
        navigationItem.title = "Payments"
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
        
        activityIndicator.color = .lightGray
        view.addSubview(activityIndicator)
        
        retryButton.setTitle("Retry", for: .normal)
        retryButton.setImage(#imageLiteral(resourceName: "Replace").tintable, for: .normal)
        retryButton.setTitleColor(.black, for: .normal)
        retryButton.tintColor = .black
        retryButton.titleLabel?.font = Font.gotham(size: 15)
        retryButton.addTarget(self, action: #selector(loadPayments), for: .touchUpInside)
        retryButton.alignVertical()
        retryButton.isHidden = true
        view.addSubview(retryButton)
        
        if isModal {
            closeButton = UIBarButtonItem(image: #imageLiteral(resourceName: "Close").tintable, style: .done, target: self, action: #selector(close(_:)))
            closeButton?.tintColor = UIColor(named: .green)
            navigationItem.leftBarButtonItem = closeButton
            
            navigationItem.title = "Select a Payment Method"
        }
    }
    
    @objc private func close(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func refreshTable() {
        self.loadPayments()
    }
    
    private func buildConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(35)
        }
        
        retryButton.snp.makeConstraints { make in
            make.width.height.equalTo(50)
            make.center.equalToSuperview()
        }
    }
}

extension PaymentListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading { return 0 }
        return payments.isEmpty ? 1 : payments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if payments.isEmpty {
            tableView.separatorStyle = .none
            let cell = tableView.dequeueReusableCell(withIdentifier: EmptyTableViewCell.identifier, for: indexPath) as! EmptyTableViewCell
            cell.buttonText = "Add a payment method"
            cell.emptyText = "You have no saved payment methods."
            cell.img = #imageLiteral(resourceName: "Card")
            cell.delegate = self
            return cell
        }
        tableView.separatorStyle = .singleLine
        let payment = payments[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: C.ViewModel.CellIdentifier.addressCell.rawValue)
        cell.textLabel?.text = payment.formattedCardNumber
        cell.textLabel?.font = Font.gotham(size: 16)
        if let expirationDate = payment.formattedExpirationDate {
            cell.detailTextLabel?.text = "Expires " + expirationDate
        }
        cell.detailTextLabel?.font = Font.gotham(size: 14)
        cell.detailTextLabel?.textColor = .lightGray
        cell.imageView?.image = payment.image
        cell.imageView?.tintColor = .lightGray
        if !isModal {
            cell.accessoryType = .disclosureIndicator
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return payments.isEmpty ? 300 : 65
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if payments.isEmpty { return }
        let payment = payments[indexPath.row]
        
        if isModal {
            delegate?.chose(paymentMethod: payment)
            navigationController?.dismiss(animated: true, completion: nil)
            return
        }
        
        let vc = PaymentDetailViewController()
        vc.paymentMethod = payment
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
}

protocol PaymentListDelegate: class {
    func refresh()
}

extension PaymentListViewController: PaymentListDelegate {
    func refresh() {
        self.loadPayments()
    }
}

extension PaymentListViewController: EmptyTableViewCellDelegate {
    func tappedButton() {
        self.add(nil)
    }
}

