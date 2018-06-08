//
//  ListDetailViewController.swift
//  Papaya
//
//  Created by Gabriel Jones on 2/2/18.
//  Copyright © 2018 Papaya. All rights reserved.
//

import UIKit

protocol ListDetailDelegate: class {
    func madeChanges()
}

class ListDetailViewController: UIViewController {
    
    public var list: List!
    public var delegate: ListDetailDelegate?
    
    private var collectionView: UICollectionView!
    private var moreButton: UIBarButtonItem!
    private let activityIndicator = UIActivityIndicatorView()
    private let emptyLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.buildViews()
        self.buildConstraints()
        Request.shared.getList(listId: list.id) { result in
            switch result {
            case .success(let list):
                self.list = list
                self.emptyLabel.isHidden = list.items?.count ?? -1 != 0
                self.activityIndicator.stopAnimating()
                self.collectionView.reloadData()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func buildViews() {
        view.backgroundColor = UIColor(named: .backgroundGrey)
        
        navigationItem.title = list.name
        
        moreButton = UIBarButtonItem(image: #imageLiteral(resourceName: "Notification").tintable, style: .done, target: self, action: #selector(more(_:)))
        moreButton.tintColor = UIColor(named: .green)
        navigationItem.rightBarButtonItem = moreButton
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        layout.headerReferenceSize = CGSize(width: view.frame.width, height: 100)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(ItemCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: ItemCollectionViewCell.identifier)
        collectionView.register(ListHeaderView.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: ListHeaderView.identifier)
        view.addSubview(collectionView)
        
        emptyLabel.text = "No items"
        emptyLabel.font = Font.gotham(size: 14)
        emptyLabel.textAlignment = .center
        emptyLabel.textColor = .gray
        emptyLabel.isHidden = true
        collectionView.addSubview(emptyLabel)
        
        activityIndicator.activityIndicatorViewStyle = .gray
        activityIndicator.hidesWhenStopped = true
        collectionView.addSubview(activityIndicator)
        DispatchQueue.main.async { self.activityIndicator.startAnimating() }
    }
    
    private func buildConstraints() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(150)
        }
        
        emptyLabel.snp.makeConstraints { make in
            make.top.equalTo(150)
            make.centerX.equalToSuperview()
        }
    }
    
    @objc private func more(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Edit Name", style: .default) { _ in
            let _alert = UIAlertController(title: "Enter new list name:", message: nil, preferredStyle: .alert)
            _alert.addTextField { textField in
                textField.placeholder = "List name"
                textField.text = self.list.name
            }
            _alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            _alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                self.list.name = _alert.textFields!.first!.text!
                Request.shared.updateList(list: self.list) { result in
                    self.delegate?.madeChanges()
                }
            })
            self.present(_alert, animated: true, completion: nil)
        })
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            let _alert = UIAlertController(title: "Are you sure you want to delete this list?", message: "You cannot undo this action.", preferredStyle: .alert)
            _alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            _alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
                Request.shared.deleteList(list: self.list) { result in
                    self.delegate?.madeChanges()
                    self.navigationController?.popViewController(animated: true)
                }
            })
            self.present(_alert, animated: true, completion: nil)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

}

extension ListDetailViewController: ListHeaderViewDelegate {
    func loadToCart() {
        let alert = UIAlertController(title: "Load to cart", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Add to existing cart", style: .default) { _ in
            Request.shared.addListToCart(listId: self.list.id) { result in
                switch result {
                case .success(_):
                    let vc = CartViewController()
                    let nav = UINavigationController(rootViewController: vc)
                    nav.navigationBar.tintColor = UIColor(named: .green)
                    self.present(nav, animated: true, completion: nil)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        })
        alert.addAction(UIAlertAction(title: "Create new cart", style: .default) { _ in
            let _alert = UIAlertController(title: "Create new cart with this list?", message: "Your previous cart will be wiped.", preferredStyle: .alert)
            _alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            _alert.addAction(UIAlertAction(title: "Yes", style: .default) { _ in
                Request.shared.deleteAllItemsFromCart { result in
                    switch result {
                    case .success(_):
                        Request.shared.addListToCart(listId: self.list.id) { result in
                            switch result {
                            case .success(_):
                                let vc = CartViewController()
                                let nav = UINavigationController(rootViewController: vc)
                                nav.navigationBar.tintColor = UIColor(named: .green)
                                self.present(nav, animated: true, completion: nil)
                            case .failure(let error):
                                print(error.localizedDescription)
                            }
                        }
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            })
            self.present(_alert, animated: true, completion: nil)
        })
        present(alert, animated: true, completion: nil)
    }
}

extension ListDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return list.items?.count ?? 8
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ItemCollectionViewCell.identifier, for: indexPath) as! ItemCollectionViewCell
        if let items = list.items {
            cell.load(item: items[indexPath.row])
        } else {
            cell.loadTemplate()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if list.items == nil {
            return
        }
        let vc = ItemViewController()
        vc.item = list.items![indexPath.row]
        var imageId: String?
        if let cell = collectionView.cellForItem(at: indexPath) as? ItemCollectionViewCell {
            imageId = cell.getImageId()
        }
        vc.imageId = imageId
        
        let nav = UINavigationController(rootViewController: vc)
        nav.isHeroEnabled = true
        nav.heroModalAnimationType = .selectBy(presenting: .auto, dismissing: .uncover(direction: .down))
        present(nav, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: ListHeaderView.identifier, for: indexPath) as! ListHeaderView
        header.load(list: self.list)
        header.delegate = self
        return header
    }
}
