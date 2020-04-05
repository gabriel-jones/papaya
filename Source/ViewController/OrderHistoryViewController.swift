//
//  OrderHistoryViewController.swift
//  Papaya
//
//  Created by Gabriel Jones on 8/28/18.
//  Copyright © 2018 Papaya Ltd. All rights reserved.
//

import UIKit

class OrderHistoryViewController: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private let retryButton = UIButton()
    private let activityIndicator = LoadingView()
    
    private var orders = PaginatedResults<OrderHistory>(isLast: false, results: [])
    private var isLoading = true
    private var page = 1

    public var isModal: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buildViews()
        self.buildConstraints()
        self.initialLoad()
    }
    
    private func loadOrders(_ completion: ((PaginatedResults<OrderHistory>?, Error?) -> Void)? = nil) {
        isLoading = true
        activityIndicator.startAnimating()
        Request.shared.getAllOrderHistory(page: self.page) { result in
            self.isLoading = false
            self.activityIndicator.stopAnimating()
            switch result {
            case .success(let paginatedResults):
                self.hideMessage()
                self.orders = paginatedResults
                self.tableView.isHidden = false
                completion?(paginatedResults, nil)
            case .failure(let error):
                self.retryButton.isHidden = false
                self.showMessage("Can't fetch orders", type: .error, options: [
                    .autoHide(false),
                    .hideOnTap(false)
                ])
                completion?(nil, error)
            }
        }
    }
    
    @objc private func initialLoad() {
        tableView.isHidden = true
        retryButton.isHidden = true
        page = 1
        self.loadOrders { result, error in
            guard let paginatedResults = result, error == nil else {
                self.tableView.isHidden = true
                self.retryButton.isHidden = false
                return
            }
            self.orders.combine(with: paginatedResults)
            self.tableView.reloadData()
            self.tableView.isUserInteractionEnabled = true
            self.page += 1
        }
    }
    
    func load() {
        self.loadOrders { paginatedResults, error in
            guard let paginatedResults = paginatedResults, !paginatedResults.results.isEmpty else {
                self.tableView.finishInfiniteScroll()
                return
            }
            self.tableView.performBatchUpdates({
                let (start, end) = (self.orders.results.count, self.orders.results.count + paginatedResults.results.count)
                let indexPaths = (start..<end).map { IndexPath(row: $0, section: 0)}
                self.orders.combine(with: paginatedResults)
                self.tableView.insertRows(at: indexPaths, with: .top)
            }, completion: { finished in
                self.page += 1
                self.tableView.finishInfiniteScroll()
            })
        }
    }
    
    private func buildViews() {
        view.backgroundColor = UIColor(named: .backgroundGrey)
        
        navigationItem.title = "Order History"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .done, target: self, action: nil)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.alwaysBounceVertical = true
        tableView.register(EmptyTableViewCell.classForCoder(), forCellReuseIdentifier: EmptyTableViewCell.identifier)
        view.addSubview(tableView)
        
        tableView.addInfiniteScroll { [unowned self] collectionView in
            self.load()
        }
        
        tableView.setShouldShowInfiniteScrollHandler { [unowned self] _ -> Bool in
            return !self.orders.isLast
        }
        
        activityIndicator.color = .gray
        view.addSubview(activityIndicator)
        
        retryButton.setTitle("Retry", for: .normal)
        retryButton.setImage(#imageLiteral(resourceName: "Replace").tintable, for: .normal)
        retryButton.setTitleColor(.black, for: .normal)
        retryButton.tintColor = .black
        retryButton.titleLabel?.font = Font.gotham(size: 15)
        retryButton.addTarget(self, action: #selector(initialLoad), for: .touchUpInside)
        retryButton.alignVertical()
        retryButton.isHidden = true
        view.addSubview(retryButton)
    }
    
    @objc private func refreshTable() {
        self.loadOrders()
    }
    
    private func buildConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.width.height.equalTo(35)
            make.center.equalToSuperview()
        }
        
        retryButton.snp.makeConstraints { make in
            make.width.height.equalTo(50)
            make.center.equalToSuperview()
        }
    }
    
}

extension OrderHistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading { return 0 }
        return orders.results.isEmpty ? 1 : orders.results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if orders.results.isEmpty {
            tableView.separatorStyle = .none
            let cell = tableView.dequeueReusableCell(withIdentifier: EmptyTableViewCell.identifier, for: indexPath) as! EmptyTableViewCell
            cell.buttonText = "Add an order"
            cell.emptyText = "You have no previous orders."
            cell.img = #imageLiteral(resourceName: "Cart Full").tintable
            cell.delegate = self
            return cell
        }
        tableView.separatorStyle = .singleLine
        let order = orders.results[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: C.ViewModel.CellIdentifier.addressCell.rawValue)
        cell.textLabel?.text = order.timeClosed?.format("MMMM dd, yyyy") ?? ""
        cell.textLabel?.font = Font.gotham(size: 16)
        cell.detailTextLabel?.text = "\(order.status.rawValue.capitalizingFirstLetter()) • \(order.total?.currencyFormat ?? "Order #\(order.id)")"
        cell.detailTextLabel?.font = Font.gotham(size: 14)
        cell.detailTextLabel?.textColor = .lightGray
        cell.imageView?.image = #imageLiteral(resourceName: "History").tintable
        cell.imageView?.tintColor = .lightGray
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return orders.results.isEmpty ? 300 : 65
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if orders.results.isEmpty { return }
        let order = orders.results[indexPath.row]
        /*
        let vc = AddressDetailViewController()
        vc.address = address
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
         */
    }
}

extension OrderHistoryViewController: EmptyTableViewCellDelegate {
    func tappedButton() {
        
    }
}
