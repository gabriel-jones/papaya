//
//  MeVC.swift
//  Papaya
//
//  Created by Gabriel Jones on 11/11/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MeVC_ViewModel {
    var lists = Variable<[List]>([])
    
    let disposeBag = DisposeBag()
    
    public func getLists(_ completion: @escaping ([List]) -> Void, _ failure: @escaping (RequestError) -> Void) {
        Request.shared.getAllLists()
        .subscribe(onNext: { lists in
            self.lists.value = lists
            completion(self.lists.value)
        }, onError: { error in
            failure(error as? RequestError ?? .unknown)
        }, onCompleted: {
            print("Completed")
        }, onDisposed: {
            print("Disposed")
        })
        .disposed(by: disposeBag)
    }
}

class MeVC: TabChildVC {
    
    let model = MeVC_ViewModel()
    
    var lists = [List]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildViews()
        buildConstraints()
        
        model.getLists({ lists in
            if let row = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? GroupTableViewCell {
                row.collectionView.reloadData()
            }
        }, { error in
            switch error {
            case .networkOffline:
                print("offline")
            default:
                print("Generic error")
            }
        })
    }
    
    private func buildViews() {
        
        tableView.register(GroupTableViewCell.classForCoder(), forCellReuseIdentifier: C.ViewModel.CellIdentifier.listGroupCell.rawValue)
        
        // Settings Button
        let settingsButton = UIBarButtonItem(image: #imageLiteral(resourceName: "Settings"), style: .plain, target: self, action: #selector(openSettings(_:)))
        settingsButton.tintColor = UIColor(named: .green)
        navigationItem.leftBarButtonItem = settingsButton
    }
    
    private func buildConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }
    }
    
    @objc func openSettings(_ sender: UIBarButtonItem) {
        print("Open Settings")
    }
}

extension MeVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: C.ViewModel.CellIdentifier.listGroupCell.rawValue, for: indexPath) as! GroupTableViewCell
        cell.set(title: "Lists")
        cell.delegate = self
        
        cell.collectionView.register(ListCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: ListCollectionViewCell.identifier)
        
        model.lists
        .asObservable()
        .bind(to: cell.collectionView.rx.items(cellIdentifier: ListCollectionViewCell.identifier, cellType: ListCollectionViewCell.self)) { row, list, listCell in
                listCell.load(list: list)
        }
        
        cell.collectionView
            .rx.itemSelected
            .subscribe { indexPath in
                //self.open(list: self.model.lists.value[indexPath.element!.row])
            }
            .disposed(by: disposeBag)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }
}

extension MeVC: ViewAllDelegate {
    func viewAll(sender: Any) {
        print("View all for sender: \(sender)")
    }
}

protocol ViewAllDelegate: class {
    func viewAll(sender: Any)
}
