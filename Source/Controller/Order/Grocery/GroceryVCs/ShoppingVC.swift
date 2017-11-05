//
//  GroceryShoppingVC.swift
//  PrePacked
//
//  Created by Gabriel Jones on 04/01/2017.
//  Copyright © 2017 Fireminds Ltd. All rights reserved.
//

import UIKit
import XLActionController

protocol InventoryItemsDelegate {
    func didUpdateShop(id: Int)
}

let MAX_IMAGE_COUNT = 250

protocol ShoppingPageDelegate {
    func getCategories() -> [String]
    func getShops() -> [String]
    func getCurrent() -> (Int,Int)
    func updateFilter(new: IndexPath?)
}

protocol ShoppingGroceryDelegate {
    func searchDidChange(searchText: String, searchBar: UITextField)
    func searchDidSearch(_ sender: UITextField)
}

class ShoppingVC: GroceryVC {
    
    //MARK: - Properties
    var page: Int = 1
    var old_page_count: Int = 1
    var categories: [String] = []
    var items: [Item] = []
    var isDownloading = false
    var inv_delegate: InventoryVCDelegate?
    var isLast = false

    var shop_id:Int! {
        didSet {
            if shop_id != -1 && self.inv_delegate == nil {
                self.categories = Shop.from(id: shop_id)!.categories
            }
        }
    }
    
    override func tap(_ sender: UITapGestureRecognizer) {
        delegate.endEditing()
    }
    
    var category: String = "" {
        didSet {
            var c = "ALL"
            if category != "" { c = category.uppercased() }
            //let liked = self.liked ? "LIKED " : ""
            let shop = self.shop_id == -1 || inv_delegate == nil ? "" : " @ " + Shop.from(id: shop_id)!.name.uppercased()
            self.filterLabel.text = "FILTER: \(c)\(shop)"
        }
    }
    
    //MARK: - Outlets
    @IBOutlet weak var itemsView: UICollectionView!
    @IBOutlet weak var filterLabel: UILabel!
    @IBOutlet weak var filterButton: LargeButton!
    @IBOutlet weak var sortButton: LargeButton!
    @IBOutlet weak var sortImage: UIImageView!
    @IBOutlet weak var sortLabel: UILabel!
    
    //MARK: - Methods
    
    
    
    //Close keyboard on touch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        self.delegate.endEditing()
    }
    
    override func viewDidLoad() {
        GroceryContainerVC.delegate = self
        
        itemsView.alwaysBounceVertical = true
        //Pull to refresh
        /*self.itemsView.alwaysBounceVertical = true
         let refresher: UIRefreshControl = UIRefreshControl()
         refresher.addSubview(RefreshControl(frame: refresher.frame))
         refresher.addTarget(self, action: #selector(refreshItems), for: .valueChanged)
         itemsView.addSubview(refresher)*/
        
        //Get first batch of items
        
        if self.inv_delegate != nil {
            self.shop_id = -1
        } else {
            self.shop_id = GroceryList.current.shop_id
        }
        
        self.categories = self.getCategories()
        
        self.getItems()
        
        
        
        filterButton.action = {
            let filterVC = self.storyboard?.instantiateViewController(withIdentifier: "FilterVC") as! FilterVC
            filterVC.delegate = self
            filterVC.modalPresentationStyle = .overCurrentContext
            if self.inv_delegate != nil {
                self.inv_delegate!.openOverlay(filterVC, animated: true)
            } else {
                self.delegate.delegateAddOverlay(filterVC, animated: true)
            }
        }
        
        sortButton.action = {
            let a = YoutubeActionController()
            a.addAction(Action(ActionData(title: "Name", image: #imageLiteral(resourceName: "Sort By Name Ascending")), style: ActionStyle.default) { _a in
                self.showSortDirection(previous: _a)
            })
            a.addAction(Action(ActionData(title: "Price", image: #imageLiteral(resourceName: "Price Tag Grey")), style: ActionStyle.default) { _a in
                self.showSortDirection(previous: _a)
            })
            a.addAction(Action(ActionData(title: "Cancel", image: #imageLiteral(resourceName: "Cancel Grey ")), style: ActionStyle.default, handler: nil))
            self.present(a, animated: true, completion: nil)
        }
    }
    
    func showSortDirection(previous: Action<ActionData>) {
        let s = previous.data!.title!.lowercased()
        
        let a = YoutubeActionController()
        a.addAction(Action(ActionData(title: "Ascending", image: s == "name" ? #imageLiteral(resourceName: "Sort By Name Ascending") : #imageLiteral(resourceName: "Ascending Grey")), style: ActionStyle.default) { _ in
            self.updateSort(s, dir: .asc)
        })
        a.addAction(Action(ActionData(title: "Descending", image: s == "name" ? #imageLiteral(resourceName: "Sort By Name Descending") : #imageLiteral(resourceName: "Descending Grey")), style: ActionStyle.default) { _ in
            self.updateSort(s, dir: .desc)
        })
        a.addAction(Action(ActionData(title: "Cancel", image: #imageLiteral(resourceName: "Cancel Grey ")), style: ActionStyle.default, handler: nil))
        self.present(a, animated: true, completion: nil)
    }
    
    func updateSort(_ s: String, dir: SortDirection) {
        self.sort = SortType(rawValue: s)!
        self.sort_dir = dir
        self.page = 1
        self.old_page_count = 1
        self.getItems()
    }
    
    func updateFilter(new: IndexPath?) {
        if self.inv_delegate != nil {
            self.inv_delegate!.closeOverlay()
        } else {
            self.delegate.delegateRemoveOverlay()
        }
        
        guard let i = new else {
            return
        }
        
        var category = 0
        var shop = 0
        
        if self.inv_delegate == nil {
            category = i.row
            shop = Shop.all.index { $0.id == GroceryList.current.shop_id }! + 1
        } else {
            if i.section == 0 {
                shop = i.row
                category = self.category == "" ? 0 : self.categories.index { $0 == self.category }! + 1
            } else {
                category = i.row
                shop = self.shop_id == -1 ? 0 : Shop.all.index { $0.id == shop_id }! + 1
            }
        }
        
        self.page = 1
        self.old_page_count = 1
        
        self.shop_id = shop == 0 ? -1 : Shop.all[shop-1].id
        self.category = category == 0 ? "" : self.categories[category-1]
        self.delegate.clearSearch()
        self.getItems()
    }
    
    func getCurrent() -> (Int,Int) {
        return (self.shop_id == -1 ? 0 : Shop.all.index { $0.id == shop_id }! + 1, self.category == "" ? 0 : self.categories.index { $0 == self.category }! + 1)
    }
    
    func getCategories() -> [String] {
        if inv_delegate != nil {
            return inv_delegate!.getCategories()
        } else {
            return self.categories
        }
    }
    
    func getShops() -> [String] {
        if inv_delegate != nil {
            return Shop.all.map { $0.name }
        } else {
            return []
        }
    }
    
    func refreshItems() {
        self.getItems()
    }
    
    func addItem(i: Item, n: Int) {
        self.delegate.addItemToCart(i, n)
        
        let l = UILabel(frame: CGRect(x: 5, y: self.view.frame.height+25, width: self.view.frame.width-10, height: 20))
        l.text = "+ \(n) \(i.name)"
        l.textColor = Color.green
        l.alpha = 0.0
        self.view.addSubview(l)
        
        UIView.animate(withDuration: 0.3, animations: {
            l.frame.origin.y = self.view.frame.height-25
            l.alpha = 1.0
            
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: 2.0, options: [], animations: {
                l.alpha = 0.0
                l.frame.origin.y = self.view.frame.height+25
            }, completion: { _ in
                
            })
        }
        
    }
    
    func didClose() {
        print("close overlay")
        if self.inv_delegate != nil {
            self.inv_delegate?.closeOverlay()
        } else {
            self.delegate.delegateRemoveOverlay()
        }
    }
    
    
    enum SortType: String {
        case name, price
    }
    
    var sort: SortType = .name {
        didSet {
            self.sortLabel.text = "SORT: \(sort.rawValue.uppercased())"
        }
    }
    
    enum SortDirection: String {
        case asc, desc
    }
    
    var sort_dir: SortDirection = .asc {
        didSet {
            var i = UIImage()
            switch sort {
            case .name:
                i = sort_dir == .asc ? #imageLiteral(resourceName: "Sort By Name Ascending") : #imageLiteral(resourceName: "Sort By Name Descending")
            case .price:
                i = sort_dir == .asc ? #imageLiteral(resourceName: "Price Tag Grey") : #imageLiteral(resourceName: "Price Tag Grey")
            }
            self.sortImage.image = i
        }
    }
    
    func getItems(_ completion: (()->())? = nil) {
        R.clearRequests()
        isDownloading = true
        
        let q = self.delegate.getSearchText()
        
        
        if q != "" {
            self.category = ""
        }
        
        let param = [
            "shop_id": "\(self.shop_id == -1 ? "null" : "\(self.shop_id!)")",
            "q": q,
            "p": "\(self.page)",
            "filter": "",
            "category": self.category,
            "user_id": "\(User.current.id)",
            "sort": self.sort.rawValue,
            "sort_dir": self.sort_dir.rawValue
        ]
        
        
        
        if page == old_page_count { self.items.removeAll() } //Remove if refreshing first page
        
        //Loading Indicator
        let ac = ActivityIndicator(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        ac.colorType = .Grey
        ac.center = self.view.center
        self.view.addSubview(ac)
        ac.draw()
        ac.startAnimating()
        
        R.get("/scripts/Inventory/inventory.php", parameters: param) { json, error in
            
            self.view.isUserInteractionEnabled = true
            ac.removeFromSuperview()
            self.isDownloading = false
            
            guard !error, let j = json else {
                return
            }
            
            for i in j["items"].arrayValue {
                self.items.append(Item(dict: i))
            }
            
            self.isLast = j["is_last"].boolValue
            
            if self.page != self.old_page_count { self.old_page_count += 1 }
            
            self.itemsView.reloadData()
            
            //For animated refresh
            /*
            self.itemsView.performBatchUpdates({
                self.itemsView.reloadSections(IndexSet(integer: 0))
            }, completion: nil)
            */
            
            if let c = completion {
                c()
            }
        }
    }
    
    
    
    func getImage(id: Int) -> UIImage? {
        return R.itemImages[id]
    }
    
    
    func openItem(item: Item, animated: Bool = true) {
        print("open item")
        let v = storyboard?.instantiateViewController(withIdentifier: "DetailItem") as! DetailItemViewController
        v.modalPresentationStyle = .overCurrentContext
        v.item = item
        v.delegate = self
        if self.inv_delegate != nil {
            v.inventoryParent = true
            self.inv_delegate?.openOverlay(v, animated: animated)
        } else {
            self.delegate.delegateAddOverlay(v, animated: animated)
        }
    }
}

extension ShoppingVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    //TODO: image caching and loading
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let c = cell as? ShoppingItemCell {
            let data = items[indexPath.row]
            
            if !data.hasImage! {
                return
            }
            
            
            if let img = R.itemImages[data.id] {
                c.image.image = img
                c.image.contentMode = .scaleAspectFit
                return
            }
            
            R.loadImageAsync(img: URL(string: C.URL.main + "/scripts/Inventory/get_image.php?id=\(data.id)&res=low")!, itemId: data.id) { img in
                if let i = img {
                    R.itemImages[data.id] = i
                    print(R.itemImages.count)
                    
                    if R.itemImages.count > MAX_IMAGE_COUNT {
                        R.itemImages.remove(at: R.itemImages.startIndex)
                    }
                    
                    UIView.animate(withDuration: 0.15, animations: {
                        c.image.alpha = 0.0
                    }, completion: { _ in
                        c.image.contentMode = .scaleAspectFit
                        c.image.image = i
                        UIView.animate(withDuration: 0.15) {
                            c.image.alpha = 1.0
                        }
                    })
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let data = items[indexPath.row]
        let c = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ShoppingItemCell
        c.name.text = data.name
        c.subtitle.text = data.price.currency_format + " | " + data.category
        
        let s = NSMutableAttributedString(attributedString: c.subtitle.attributedText!)
        s.addAttribute(NSAttributedStringKey.foregroundColor, value: Color.green, range: NSMakeRange(c.subtitle.text!.characters.count-data.category.characters.count, data.category.characters.count))
        c.subtitle.attributedText = s
        
        c.liked.isHidden = !data.isLiked
        
        c.image.image = #imageLiteral(resourceName: "Picture Grey")
        c.image.contentMode = .center
        
        c.tap = {
            print("tap!")
            self.openItem(item: data)
        }
        
        return c
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("select at \(indexPath)")
        self.view.endEditing(true)
        openItem(item: self.items[indexPath.row])
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = (collectionView.frame.width - 10) / 2
        return CGSize(width: w, height: w)
    }
}

extension ShoppingVC: ShoppingPageDelegate, InventoryItemsDelegate, ItemDetailDelegate {
    
    func changeLiked(i: Item, liked: Bool) {
        let row = self.items.index(where: { $0.id == i.id })!
        let cell = self.itemsView.cellForItem(at: IndexPath(row: row, section: 0)) as! ShoppingItemCell
        cell.liked.isHidden = !liked
    }
    
    func didCloseWith(item: Item?) {
        print("closed with item")
        self.didClose()
        self.openItem(item: item!, animated: false)
    }
    
    func didUpdateShop(id: Int) {
        self.shop_id = id
    }
}

extension ShoppingVC: ShoppingGroceryDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate.endEditing()
        if scrollView.bounds.maxY >= scrollView.contentSize.height-25 && !isDownloading && !isLast {
            if self.items.count % 16 == 0 {
                page += 1
                self.getItems()
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    func searchDidChange(searchText: String, searchBar: UITextField) {
        page = 1
        old_page_count = 1
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            if searchText == searchBar.text {
                self.getItems()
            }
        }
    }
    
    func searchDidSearch(_ sender: UITextField) {
        self.getItems()
        sender.endEditing(true)
    }
}


class ShoppingItemCell: UICollectionViewCell {
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var liked: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    
    var tap: () -> () = {}
    
    //TODO: cache images, dispose of them when scroll, etc.
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        })
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        tap()
        UIView.animate(withDuration: 0.05) {
            self.transform = CGAffineTransform.identity
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        tap()
        UIView.animate(withDuration: 0.05) {
            self.transform = CGAffineTransform.identity
        }
    }
}
