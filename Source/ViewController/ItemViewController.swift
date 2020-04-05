//
//  ItemVC.swift
//  Papaya
//
//  Created by Gabriel Jones on 11/16/17.
//  Copyright © 2018 Papaya Ltd. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol CartItemDelegate: class {
    /*
    func didUpdateQuantity(forItem: CartItem, toQuantity: Int)
    func didDelete(cartItem: CartItem)
    func didAddToCart(cartItem: CartItem)
     */
    func didUpdateCart()
}

protocol LikedDelegate: class {
    func didUpdateLikedStatus(toLiked: Bool, forItem: Item)
}

class ItemViewController: UIViewController {
    
    //MARK: - Properties
    public var item: Item?
    public var imageId: String?
    public var isOnNavigationStack = false
    public var cartDelegate: CartItemDelegate?
    public var likedDelegate: LikedDelegate?
    
    private var isLoading = true
    
    private let activityIndicator = LoadingView()
    private var closeButton: UIBarButtonItem!
    private var shareButton: UIBarButtonItem!
    private let tableView = UITableView()
    
    private let toolbar = UIView()
    private let toolbarContentView = UIView()
    private let toolbarBorder = UIView()
    private let addToCart = LoadingButton()
    private let stepper = Stepper()
    
    private var isLiked: Bool?
    private var isInCart: Bool?
    private var numberInCart: Int?
    private var disclaimer: String?
    
    private var similarItems = [Item]()
    private var featuredItems = [Item]()
    
    //MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buildViews()
        self.buildConstraints()
        
        DispatchQueue.main.async { self.addToCart.showLoading() }

        let group = DispatchGroup()
        
        group.enter()
        Request.shared.getDetail(item: self.item!) { result in
            if case .success(let detail) = result {
                self.isLiked = detail["item"]["is_liked"].bool
                self.isInCart = detail["item"]["in_cart"].bool
                self.numberInCart = detail["item"]["number_in_cart"].int
                self.disclaimer = detail["item"]["disclaimer"].string
                self.item?.pack = Item(dict: detail["item"]["pack_item"])
                self.item?.packLabel = detail["item"]["pack_item"]["label"].string
            }
            group.leave()
        }
        
        group.enter()
        Request.shared.getSimilarItems(toItem: self.item!) { result in
            if case .success(let paginatedResult) = result {
                self.similarItems = paginatedResult.results
            }
            group.leave()
        }
        
        group.enter()
        Request.shared.getFeaturedItems(forCategory: self.item!.category!) { result in
            if case .success(let paginatedResult) = result {
                self.featuredItems = paginatedResult.results
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
        
        addToCart.tag = inCart ? 1 : 0
        addToCart.isEnabled = !inCart
        addToCart.alpha = inCart ? 0.75 : 1
        addToCart.setTitle(inCart ? "In cart" : "Add to cart", for: .normal)
        stepper.shouldDelete = inCart
        
        if let n = numberInCart, n > 0 {
            stepper.value = n
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let isPastTop = tableView.contentOffset.y > 0
        self.navigationController?.navigationBar.shadowImage = isPastTop ? nil : UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(isPastTop ? nil : UIImage(), for: .default)
        self.navigationItem.title = isPastTop ? self.item?.name : nil
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
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        view.addSubview(tableView)
        
        // Toolbar
        toolbar.backgroundColor = UIColorFromRGB(0xf7f7f7)
        view.addSubview(toolbar)
        
        toolbar.addSubview(toolbarContentView)
        
        // Toolbar border
        toolbarBorder.backgroundColor = UIColor(red: 0.796, green: 0.796, blue: 0.812, alpha: 1.0)
        toolbarContentView.addSubview(toolbarBorder)
        
        // Add to cart
        addToCart.backgroundColor = UIColor(named: .green)
        addToCart.layer.cornerRadius = 5
        addToCart.titleLabel?.textColor = .white
        addToCart.titleLabel?.font = Font.gotham(size: 17)
        addToCart.addTarget(self, action: #selector(addToCart(_:)), for: .touchUpInside)
        toolbarContentView.addSubview(addToCart)
        
        stepper.backgroundColor = .white
        stepper.delegate = self
        stepper.shouldDelete = false
        toolbarContentView.addSubview(stepper)
        
        activityIndicator.lineWidth = 3
        activityIndicator.color = .lightGray
        DispatchQueue.main.async { self.activityIndicator.startAnimating() }
    }
    
    private func buildConstraints() {
        toolbar.snp.makeConstraints { make in
            make.right.left.bottom.equalToSuperview()
        }
        
        toolbarContentView.snp.makeConstraints { make in
            make.top.right.left.equalToSuperview()
            if #available(iOS 11, *) {
                make.bottom.equalTo(self.view.safeAreaLayoutGuide)
            } else {
                make.bottom.equalToSuperview()
            }
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
            make.height.equalTo(44)
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
        self.stepper.isUserInteractionEnabled = false
        Request.shared.addToCart(item: self.item!, quantity: self.stepper.value) { result in
            self.addToCart.hideLoading()
            self.stepper.isUserInteractionEnabled = true
            if case .success(let cartItem) = result {
                //self.cartDelegate?.didAddToCart(cartItem: cartItem)
                self.cartDelegate?.didUpdateCart()
                self.updateCartButtons()
                self.tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
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

extension ItemViewController: GroupDelegateAction {
    func open(item: Item, imageId: String) {
        if item.id == self.item!.id {
            return
        }
        let vc = ItemViewController()
        vc.item = item
        vc.isOnNavigationStack = true
        navigationController?.pushViewController(vc, animated: true)
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
                    self.stepper.hideLoading()
                    if case .success(let cartItem) = result {
                        self.cartDelegate?.didUpdateCart()
                        //self.cartDelegate?.didUpdateQuantity(forItem: cartItem, toQuantity: to)
                    }
                }
            }
        }
    }
    
    func delete() {
        self.stepper.showLoading()
        Request.shared.deleteCartItem(item: self.item!) { result in
            self.stepper.hideLoading()
            if case .success(_) = result {
                self.isInCart = false
                self.updateCartButtons()
                self.tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
                self.cartDelegate?.didUpdateCart()
            }
        }
    }
}

extension ItemViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = scrollView.contentOffset.y
        UIView.animate(withDuration: 0.3) {
            let isPastTop = y > 0
            self.navigationController?.navigationBar.shadowImage = isPastTop ? nil : UIImage()
            self.navigationController?.navigationBar.setBackgroundImage(isPastTop ? nil : UIImage(), for: .default)
            self.navigationItem.title = isPastTop ? self.item?.name : nil
        }
        self.checkDismissingCondition(withScrollOffset: y)
    }
    
    private func checkDismissingCondition(withScrollOffset y: CGFloat) {
        if y < -130 {
            self.tableView.isScrollEnabled = false
            self.tableView.setContentOffset(self.tableView.contentOffset, animated: false)
            self.tableView.contentOffset = CGPoint(x: 0, y: y)
            if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ItemDetailTableViewCell {
                cell.itemImage.heroID = nil
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension ItemViewController: ItemActionDelegate {
    internal func set(liked: Bool) {
        if let item = self.item {
            Request.shared.setLiked(item: item, to: liked)
            isLiked = liked
            self.likedDelegate?.didUpdateLikedStatus(toLiked: liked, forItem: item)
            tableView.reloadData()
        }
    }
    
    internal func addToList() {
        /*let vc = ListListViewController()
        vc.isModal = true
        vc.delegate = self
        let nav = UINavigationController(rootViewController: vc)
        nav.navigationBar.tintColor = UIColor(named: .green)
        present(nav, animated: true, completion: nil)*/
    }
    
    internal func addInstructions() {
        let vc = InstructionsViewController()
        vc.rawItem = self.item
        vc.delegate = self
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true, completion: nil)
    }
}

extension ItemViewController: InstructionsViewControllerDelegate {
    func didMakeChanges(toCartItem: CartItem) {
        //TODO: something here
    }
}

/*extension ItemViewController: ListModalDelegate {
    func chose(list: List) {
        Request.shared.addToList(item: self.item!)
    }
}*/

protocol ItemActionDelegate {
    func set(liked: Bool)
    func addToList()
    func addInstructions()
}

extension ItemViewController: ViewAllDelegate {
    internal func viewAll(identifier: Int?) {
        guard let id = identifier else {
            return
        }
        let vc = ItemGroupViewController()
        if id == 3 { // Featured Items
            vc.items = ItemGroupRequestType.featured(from: self.item!.category!)
            vc.groupTitle = "Featured from \(self.item!.category!.name)"
        } else { // Similar Items
            vc.items = .similar(to: item!)
            vc.groupTitle = "Similar to \(item!.name)"
        }
        vc.isModal = true
        navigationController?.pushViewController(vc, animated: true)
    }
}

@objc protocol ItemImageDelegate {
    func openImage(_ sender: Any)
    func openItem(item: Any)
}

extension ItemViewController: ItemImageDelegate {
    func openItem(item: Any) {
        guard let item = item as? Item else {
            return
        }
        let vc = ItemViewController()
        vc.item = item
        vc.isOnNavigationStack = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func openImage(_ sender: Any) {
        let vc = ItemImageViewController()
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ItemDetailTableViewCell, let img = cell.itemImage.image {
            if !cell.didLoadImage {
                return
            }
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
            var actions: [ItemActionTableViewCell.ItemActions] = [(isLiked ?? false) ? .liked : .like]
            if isInCart ?? false {
                actions.append(.instructions)
            }
            cell.load(actions: actions)
            cell.separatorInset = UIEdgeInsets.zero
            return cell
        } else if indexPath.row == 2 || indexPath.row == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: GroupTableViewCell.identifier, for: indexPath) as! GroupTableViewCell
            cell.set(title: indexPath.row == 2 ? "Similar" : "Featured")
            cell.register(class: ItemCollectionViewCell.self, identifier: ItemCollectionViewCell.identifier)
            cell.delegate = self
            cell.backgroundColor = UIColor(named: .backgroundGrey)
            cell.separatorInset = UIEdgeInsets(top: 0, left: tableView.bounds.size.width, bottom: 0, right: 0)
            cell.model = ItemGroupModel(items: indexPath.row == 2 ? self.similarItems : self.featuredItems)
            cell.model?.delegate = self
            cell.model?.identifier = indexPath.row
            return cell
        } else if indexPath.row == 4 {
            let cell = UITableViewCell(style: .default, reuseIdentifier: "disclaimerCell")
            cell.backgroundColor = UIColor(named: .backgroundGrey)
            cell.textLabel?.text = (disclaimer ?? "") + "\n"
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
                make.centerX.equalToSuperview()
                make.top.equalTo(24)
                make.width.height.equalTo(30)
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
