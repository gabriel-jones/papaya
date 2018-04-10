//
//  ItemVC.swift
//  Papaya
//
//  Created by Gabriel Jones on 11/16/17.
//  Copyright © 2017 Papaya. All rights reserved.
//

import UIKit
import SwiftyJSON

class ItemViewController: UIViewController {
    
    //MARK: - Properties
    public var item: Item?
    public var imageId: String?
    public var isOnNavigationStack = false
    
    private var isLoading = true
    
    private let activityIndicator = UIActivityIndicatorView()
    private var closeButton: UIBarButtonItem!
    private var shareButton: UIBarButtonItem!
    private let tableView = UITableView()
    private let toolbar = UIView()
    private let toolbarBorder = UIView()
    private let addToCart = LoadingButton()
    private let stepper = Stepper()
    
    private var isLiked: Bool?
    private var isInCart: Bool?
    private var numberInCart: Int?
    private var items = [Item]()
    private var disclaimer: String?
    
    //MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buildViews()
        self.buildConstraints()
        
        self.addToCart.showLoading()

        let group = DispatchGroup()
        
        group.enter()
        Request.shared.getDetail(item: self.item!) { result in
            if case .success(let detail) = result {
                print("got detail, \(detail)")
                self.isLiked = detail["item"]["is_liked"].bool
                self.isInCart = detail["item"]["in_cart"].bool
                self.numberInCart = detail["item"]["number_in_cart"].int
                self.disclaimer = detail["item"]["disclaimer"].string
                
            }
            group.leave()
        }
        
        group.enter()
        Request.shared.getAllItemsTemp() { result in
            if case .success(let similarItems) = result {
                self.items = similarItems
            }
            group.leave()
        }
        
        group.notify(queue: .main) {
            self.isLoading = false
            self.updateCartButtons()
            self.addToCart.hideLoading()
            self.tableView.reloadData()
        }
    }
    
    private func updateCartButtons() {
        let inCart = isInCart ?? false
        print("calling")
        print(isInCart)
        print(inCart)
        
        addToCart.tag = inCart ? 1 : 0
        addToCart.isEnabled = !inCart
        addToCart.alpha = inCart ? 0.75 : 1
        addToCart.setTitle(inCart ? "In cart" : "Add to cart", for: .normal)
        
        if let n = numberInCart, n > 0 {
            stepper.value = n
        }
    }
    
    private func buildViews() {
        isHeroEnabled = true
        
        // Close button
        if !isOnNavigationStack {
            closeButton = UIBarButtonItem(image: #imageLiteral(resourceName: "Close").tintable, style: .done, target: self, action: #selector(close(_:)))
            closeButton.tintColor = UIColor(named: .green)
            navigationItem.leftBarButtonItem = closeButton
        }
        
        shareButton = UIBarButtonItem(image: #imageLiteral(resourceName: "Share").tintable, style: .done, target: self, action: #selector(share(_:)))
        shareButton.tintColor = UIColor(named: .green)
        navigationItem.rightBarButtonItem = shareButton
        
        navigationController?.navigationBar.tintColor = UIColor(named: .green)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .done, target: self, action: nil)

        // Table view
        tableView.allowsSelection = false
        tableView.register(ItemDetailTableViewCell.classForCoder(), forCellReuseIdentifier: ItemDetailTableViewCell.identifier)
        tableView.register(ItemActionTableViewCell.classForCoder(), forCellReuseIdentifier: ItemActionTableViewCell.identifier)
        tableView.register(GroupTableViewCell.classForCoder(), forCellReuseIdentifier: GroupTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = nil
        view.addSubview(tableView)
        
        // Toolbar
        toolbar.backgroundColor = UIColorFromRGB(0xf7f7f7)
        view.addSubview(toolbar)
        
        // Toolbar border
        toolbarBorder.backgroundColor = UIColor(red: 0.796, green: 0.796, blue: 0.812, alpha: 1.0)
        toolbar.addSubview(toolbarBorder)
        
        // Add to cart
        addToCart.backgroundColor = UIColor(named: .green)
        addToCart.layer.cornerRadius = 5
        addToCart.titleLabel?.textColor = .white
        addToCart.titleLabel?.font = Font.gotham(size: 17)
        addToCart.addTarget(self, action: #selector(addToCart(_:)), for: .touchUpInside)
        toolbar.addSubview(addToCart)
        
        stepper.backgroundColor = .white
        stepper.delegate = self
        toolbar.addSubview(stepper)
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = .gray
        DispatchQueue.main.async { self.activityIndicator.startAnimating() }
    }
    
    private func buildConstraints() {
        toolbar.snp.makeConstraints { make in
            make.bottom.right.left.equalToSuperview()
            make.height.equalTo(60)
        }
        
        toolbarBorder.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(0.33)
        }
        
        addToCart.snp.makeConstraints { make in
            make.right.equalTo(-8)
            make.top.equalTo(8)
            make.bottom.equalTo(-8)
            make.width.equalToSuperview().multipliedBy(0.5).offset(-8)
        }
        
        tableView.snp.makeConstraints { make in
            make.bottom.equalTo(toolbar.snp.top)
            make.left.right.top.equalToSuperview()
        }
        
        stepper.snp.makeConstraints { make in
            make.left.equalTo(8)
            make.top.equalTo(8)
            make.bottom.equalTo(-8)
            make.right.equalTo(addToCart.snp.left).offset(-8)
        }
    }
    
    @objc private func close(_ sender: Any) {
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ItemDetailTableViewCell {
            cell.itemImage.heroID = nil
        }
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func addToCart(_ sender: LoadingButton) {
        if sender.tag == 1 { return }
        DispatchQueue.main.async { self.addToCart.showLoading() }
        self.numberInCart = self.stepper.value
        self.isInCart = true
        Request.shared.addToCart(item: self.item!, quantity: self.stepper.value) { result in
            self.addToCart.hideLoading()
            if case .success(_) = result {
                self.updateCartButtons()
                self.close(0)
            }
        }
    }
    
    @objc private func share(_ sender: UIBarButtonItem) {
        let shareable = URL(string: C.URL.production)
        let activity = UIActivityViewController(activityItems: [item!.name, item!.img], applicationActivities: nil)
        activity.popoverPresentationController?.sourceView = self.view
        activity.excludedActivityTypes = [.airDrop]
        present(activity, animated: true, completion: nil)
    }
}

extension ItemViewController: StepperDelegate {
    func changedQuantity(to: Int) {
        if !(self.isInCart ?? false) {
            return
        }
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
            if to == self.stepper.value {
                self.stepper.showLoading()
                Request.shared.updateCartQuantity(item: self.item!, quantity: to) { result in
                    self.stepper.hideLoading() //todo: switch
                }
            }
        }
    }
    
    func delete() {
        
    }
}

extension ItemViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        UIView.animate(withDuration: 0.3) {
            let isPastTop = scrollView.contentOffset.y > 0
            self.navigationController?.navigationBar.shadowImage = isPastTop ? nil : UIImage()
            self.navigationController?.navigationBar.setBackgroundImage(isPastTop ? nil : UIImage(), for: .default)
            self.navigationItem.title = isPastTop ? self.item?.name : nil
        }
    }
}

extension ItemViewController: ItemActionDelegate {
    internal func set(liked: Bool) {
        print("like: \(liked)")
        if let item = self.item {
            Request.shared.setLiked(item: item, to: liked)
            isLiked = liked
            tableView.reloadData()
        }
    }
    
    internal func add(to list: List) {
        
    }
    
    internal func addInstructions() {
        
    }
}

protocol ItemActionDelegate {
    func set(liked: Bool)
    func add(to list: List)
    func addInstructions()
}

extension ItemViewController: ViewAllDelegate {
    internal func viewAll(identifier: Int?) {
        let vc = ItemGroupViewController()
        //vc.items = Request.shared.getAllItemsTemp()
        vc.groupTitle = "Similar to \(item!.name)"
        navigationController?.pushViewController(vc, animated: true)
    }
}

@objc protocol ItemImageDelegate {
    func openImage(_ sender: Any)
}

extension ItemViewController: ItemImageDelegate {
    func openImage(_ sender: Any) {
        print("open image")
        let vc = ItemImageViewController()
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ItemDetailTableViewCell, let img = cell.itemImage.image {
            print("found img")
            vc.image = img
        }
        vc.imageId = self.imageId
        vc.isHeroEnabled = true
        vc.heroModalAnimationType = .fade
        present(vc, animated: true, completion: nil)
    }
}

extension ItemViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //item detail
        // item action
        // similar
        // details
        // often bought with
        // featured
        // disclaimer
        return isLoading ? 1 : 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: ItemDetailTableViewCell.identifier, for: indexPath) as! ItemDetailTableViewCell
            cell.set(item: self.item!, id: self.imageId ?? "")
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
            cell.delegate = self
            return cell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: ItemActionTableViewCell.identifier, for: indexPath) as! ItemActionTableViewCell
            cell.delegate = self
            cell.load(actions: [(isLiked ?? false) ? .liked : .like, .addToList])
            cell.separatorInset = UIEdgeInsets.zero
            return cell
        } else if indexPath.row == 2 || indexPath.row == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: GroupTableViewCell.identifier, for: indexPath) as! GroupTableViewCell
            cell.set(title: "Similar Items")
            cell.register(class: ItemCollectionViewCell.self, identifier: ItemCollectionViewCell.identifier)
            cell.delegate = self
            cell.backgroundColor = UIColor(named: .backgroundGrey)
            cell.separatorInset = UIEdgeInsets(top: 0, left: tableView.bounds.size.width, bottom: 0, right: 0)
            cell.model = ItemGroupModel(items: self.items)
            cell.model?.delegate = self
            return cell
        } else if indexPath.row == 4 {
            let cell = UITableViewCell(style: .default, reuseIdentifier: "disclaimerCell")
            cell.backgroundColor = UIColor(named: .backgroundGrey)
            cell.textLabel?.text = disclaimer
            cell.textLabel?.font = Font.gotham(size: 12)
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = .gray
            cell.textLabel?.numberOfLines = 0
            let background = UIView()
            background.backgroundColor = UIColor(named: .backgroundGrey)
            background.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: cell.frame.height + 1000)
            background.layer.zPosition = -1
            cell.addSubview(background)
            cell.masksToBounds = false
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 2 || indexPath.row == 3 { return 250 }
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if isLoading {
            let container = UIView()
            container.addSubview(activityIndicator)
            activityIndicator.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
            return container
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if isLoading {
            return UITableViewAutomaticDimension
        }
        return 0.3
    }
}
//TODO: fix
/*
extension ItemViewController: GroupDelegateAction {
    internal func open(item: Item, imageId: String) {
        if item.id == self.item!.id {
            return
        }
        let vc = ItemViewController()
        vc.item = item
        vc.isOnNavigationStack = true
        navigationController?.pushViewController(vc, animated: true)
        /*let newItem = ItemVC.instantiate(from: .main)
        newItem.item = item
        navigationController?.pushViewController(newItem, animated: true)*/
        // Allow next controller to have back button
    }
}*/
