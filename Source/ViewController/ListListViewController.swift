//
//  ListListViewController.swift
//  Papaya
//
//  Created by Gabriel Jones on 4/13/18.
//  Copyright © 2018 Papaya. All rights reserved.
//

import UIKit

protocol ListModalDelegate: class {
    func chose(list: List)
}

class ListListViewController: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private var addButton: UIBarButtonItem!
    private let refreshControl = UIRefreshControl()
    private var closeButton: UIBarButtonItem?
    
    private var lists = [List]()
    private var isLoading = true
    
    public var isModal: Bool = false
    public var delegate: ListModalDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buildViews()
        self.buildConstraints()
    }
    
    @objc private func add(_ sender: UIBarButtonItem?) {
        let vc = ListDetailViewController()
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true, completion: nil)
    }
    
    private func loadLists(_ completion: (() -> Void)? = nil) {
        self.isLoading = true
        self.refreshControl.beginRefreshing()
        Request.shared.getAllLists { result in
            self.isLoading = false
            self.refreshControl.endRefreshing()
            switch result {
            case .success(let lists):
                self.lists = lists
                self.tableView.reloadData()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func buildViews() {
        view.backgroundColor = UIColor(named: .backgroundGrey)
        
        navigationItem.title = "Lists"
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
        
        if isModal {
            closeButton = UIBarButtonItem(image: #imageLiteral(resourceName: "Close").tintable, style: .done, target: self, action: #selector(close(_:)))
            closeButton?.tintColor = UIColor(named: .green)
            navigationItem.leftBarButtonItem = closeButton
            
            navigationItem.title = "Select a List"
        }
    }
    
    @objc private func close(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func refreshTable() {
        loadLists()
    }
    
    private func buildConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadLists()
    }
}

extension ListListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading { return 0 }
        return lists.isEmpty ? 1 : lists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if lists.isEmpty {
            tableView.separatorColor = .clear
            let cell = tableView.dequeueReusableCell(withIdentifier: EmptyTableViewCell.identifier, for: indexPath) as! EmptyTableViewCell
            cell.buttonText = "Add a list"
            cell.emptyText = "You have no saved lists."
            cell.img = #imageLiteral(resourceName: "List")
            cell.delegate = self
            return cell
        }
        let list = lists[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: C.ViewModel.CellIdentifier.addressCell.rawValue)
        cell.textLabel?.text = list.name
        cell.textLabel?.font = Font.gotham(size: 16)
        cell.detailTextLabel?.text = "\(list.itemCount) items"
        cell.detailTextLabel?.font = Font.gotham(size: 14)
        cell.detailTextLabel?.textColor = .lightGray
        cell.imageView?.image = #imageLiteral(resourceName: "List").tintable
        cell.imageView?.tintColor = .lightGray
        if !isModal {
            cell.accessoryType = .disclosureIndicator
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return lists.isEmpty ? 300 : 65
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if lists.isEmpty { return }
        let list = lists[indexPath.row]
        
        if isModal {
            delegate?.chose(list: list)
            navigationController?.dismiss(animated: true, completion: nil)
            return
        }
        
        let vc = ListDetailViewController()
        vc.list = list
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ListListViewController: EmptyTableViewCellDelegate {
    func tappedButton() {
        self.add(nil)
    }
}
