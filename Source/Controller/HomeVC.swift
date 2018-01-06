//
//  HomeVC.swift
//  Papaya
//
//  Created by Gabriel Jones on 11/10/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxDataSources

class HomeVC_ViewModel {
    var featuredItems =  Variable<[Item]>([])
    var recommended = Variable<[Item]>([])
    
    private var disposeBag = DisposeBag()
    
    public func getFeaturedItems(_ completion: @escaping ([Item]) -> Void, _ failure: @escaping (RequestError) -> Void) {
        Request.shared.getAllItemsTemp()
            .subscribe(onNext: { items in
                self.featuredItems.value = items
                completion(self.featuredItems.value)
            }, onError: { error in
                failure(error as? RequestError ?? .unknown)
            }, onCompleted: {
                print("Request completed")
            }, onDisposed: {
                print("Request disposed")
            })
            .disposed(by: disposeBag)
    }
    
    public func getRecommendedItems(_ completion: @escaping ([Item]) -> Void, _ failure: @escaping (RequestError) -> Void) {
        Request.shared.getAllItemsTemp()
            .subscribe(onNext: { items in
                self.recommended.value = items
                completion(self.recommended.value)
            }, onError: { error in
                failure(error as? RequestError ?? .unknown)
            }, onCompleted: {
                print("Request completed")
            }, onDisposed: {
                print("Request disposed")
            })
            .disposed(by: disposeBag)
    }
}

class HomeVC: TabChildVC {
    
    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    let model = HomeVC_ViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buildViews()
        buildConstraints()
                
        model.getFeaturedItems({ items in
            if let row = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? GroupTableViewCell {
                row.collectionView.reloadData() //TODO: animate 
            }
        }, { error in
            switch error {
            case .networkOffline:
                print("something")
            default:
                print("Generic error")
            }
        })
    }
    
    func buildViews() {
        isHeroEnabled = true
        
        let hr = Calendar.current.component(.hour, from: Date())
        
        var greet = ""
        var end = ""
        switch hr {
        case 0..<5:
            greet = "Up Late"
            end = "?"
        case 5..<12:
            greet = "Good Morning"
        case 12..<17:
            greet = "Good Afternoon"
        case 17..<24:
            greet = "Good Evening"
        default: break
        }
        
        navigationItem.title = greet
        
        if let user = User.current {
            navigationItem.title = navigationItem.title! + ", \(user.fname)" + end
        } else {
            navigationItem.title = navigationItem.title! + end
        }
        
        tableView.register(GroupTableViewCell.classForCoder(), forCellReuseIdentifier: C.ViewModel.CellIdentifier.itemGroupCell.rawValue)
    }
    
    func buildConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }
    }
    
    @objc func viewAll(_ sender: UIButton) {
        print("view all for button: \(sender)")
    }
    
}

struct ItemSection: SectionModelType {
    var items: [Item]
}

extension ItemSection {
    init(original: ItemSection, items: [Item]) {
        self = original
        self.items = items
    }
}

extension HomeVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let titles = ["Today's Specials", "Recommended for You"]
        print("reloading")
        let cell = tableView.dequeueReusableCell(withIdentifier: C.ViewModel.CellIdentifier.itemGroupCell.rawValue, for: indexPath) as! GroupTableViewCell
        cell.set(title: titles[indexPath.row])
        cell.collectionView.register(ItemCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: ItemCollectionViewCell.identifier)
        
        cell.delegate = self
        
        var items: Variable<[Item]>!
        
        switch indexPath.row {
        case 0:
            items = model.featuredItems
        case 1:
            items = model.recommended
        default: return cell
        }
        
        items
            .asObservable()
            .bind(to: cell.collectionView.rx.items(cellIdentifier: ItemCollectionViewCell.identifier, cellType: ItemCollectionViewCell.self)) { row, item, itemCell in
                itemCell.load(item: item, indexPath: IndexPath(row: row, section: 0))
                print(itemCell.itemImage.heroID)
            }
            .disposed(by: disposeBag)
        
        cell.collectionView
            .rx.itemSelected
            .subscribe { indexPath in
                self.open(item: self.model.featuredItems.value[indexPath.element!.row], indexPath: indexPath.element!)
            }
            .disposed(by: disposeBag)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }
}



extension HomeVC: ViewAllDelegate {
    func viewAll(sender: Any) {
        print("View all from sender: \(sender)")
    }
}

extension HomeVC: GroupDelegateAction {
    func open(item: Item, indexPath: IndexPath) {
        let vc = ItemVC.instantiate(from: .main)
        vc.item = item
        vc.indexPath = indexPath
        heroModalAnimationType = .zoom
        
        let nav = UINavigationController(rootViewController: vc)
        nav.isHeroEnabled = true
        present(nav, animated: true, completion: nil)
    }
}

