//
//  GroceryListViewController.swift
//  PrePacked
//
//  Created by Gabriel Jones on 13/07/2016.
//  Copyright © 2016 Fireminds Ltd. All rights reserved.
//

import UIKit
import XLActionController

class GroceryContainerVC: BaseVC {
    
    //MARK: - Properties
    
    var page: Int = 0
    var pageViewController: UIPageViewController?
    private(set) lazy var pageVCs: [GroceryVC] = {
        return [0,1].map { self.getVC(at: $0) }
    }()
    static var delegate: ShoppingGroceryDelegate!
    
    //MARK: - Outlets
    //MARK: Header
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var cartPrice: UILabel!
    
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var cartButton: LargeButton!
    @IBOutlet weak var continueShoppingButton: LargeButton!
    
    //MARK: - Actions
    
    @IBAction func back(_ sender: UIButton) {
        self.navigate(.reverse)
    }
    
    @IBAction func more(_ sender: UIButton) {
        self.more()
    }
    
    //MARK: - View Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupPageVC()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        cartButton.action = {
            if self.switchVC(to: 1) {
                self.didNavigate()
            }
        }
        
        continueShoppingButton.action = {
            if self.switchVC(to: 0) {
                self.didNavigate()
            }
        }
        
        searchField.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
    }
}

extension GroceryContainerVC: GroceryDelegate {
    func getVC(at index: Int) -> GroceryVC {
        let name = ["ShoppingVC", "CartVC"][index]
        let groceryVC = self.storyboard!.instantiateViewController(withIdentifier: name) as! GroceryVC
        groceryVC.delegate = self
        return groceryVC
    }
    
    func navigate(_ direction: UIPageViewControllerNavigationDirection) {
        self.view.endEditing(true)
        page += direction == .forward ? 1 : -1
        if page > pageVCs.count { page = pageVCs.count-1 }
        if page < 0 {
            alert(actions: [
                AlertButton("OK", backgroundColor: Color.red) {
                    self.navigationController?.popViewController(animated: true)
                },
                AlertButton("Cancel")
            ]).showWarning("Exit?", subTitle: "You will lose your current grocery list.")
            return
        }
        self.setVC(pageVCs[page], direction)
    }
    
    func didNavigate(_ completed: Bool) {
        print("did navigate")
    }
    
    func setVC(_ viewController: UIViewController, _ direction: UIPageViewControllerNavigationDirection = .forward, _ animated: Bool = true) {
        pageViewController!.setViewControllers([viewController], direction: direction, animated: animated, completion: { completed in
            DispatchQueue.main.async {
                self.didNavigate(completed)
            }
        })
    }
    
    func switchVC(to index: Int) -> Bool {
        view.endEditing(true)
        if page == index { return false }
        
        let vc = pageVCs[index]
        pageViewController!.setViewControllers([vc], direction: [.reverse , .forward][index], animated: true, completion: nil)
        return true
    }
    
    func didNavigate() {
        page = page == 0 ? 1 : 0
        
        UIView.animate(withDuration: 0.3) {
            self.searchView.isHidden = self.page != 0
            self.continueShoppingButton.isHidden = self.page != 1
        }
    }
    
    func updateTotals() {
        print("update totals")
        self.cartPrice.text = GroceryList.current.total.currency_format
    }
    
    func addItemToCart(_ item: Item, _ quantity: Int) {
        print("add item to cart: \(item.name) \(quantity)")
        GroceryList.current.items.append((item, quantity))
        self.updateTotals()
    }
    
    func next() {
        let vc = CheckoutVC.instantiate(from: .order)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func delegateAddOverlay(_ vc: UIViewController, animated: Bool = true) {
        self.addOverlay(vc, animated: true, completion: nil)
    }
    
    func delegateRemoveOverlay() {
        self.closeOverlay(animated: true)
    }
    
    func getSearchText() -> String {
        return searchField.text!
    }
    
    func clearSearch() {
        searchField.text = ""
    }
    
    func endEditing() {
        self.view.endEditing(true)
    }
}

extension GroceryContainerVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("edn editing")
        self.view.endEditing(true)
        GroceryContainerVC.delegate.searchDidSearch(textField)
        return true
    }
    
    @objc func textDidChange(_ sender: UITextField) {
        print("Text change")
        GroceryContainerVC.delegate.searchDidChange(searchText: sender.text!, searchBar: sender)
    }
}

extension GroceryContainerVC: UIPageViewControllerDelegate  {
    
    //MARK: - View Methods
    func setupPageVC() {
        //PageVC
        let pageController = self.storyboard!.instantiateViewController(withIdentifier: "GroceryPageController") as! UIPageViewController
        pageController.delegate = self
        
        //Set current page to first VC
        if let vc = pageVCs.first {
            pageController.setViewControllers([vc], direction: .forward, animated: false, completion: nil)
        }
        
        //Set pageVC frame and add to self
        pageViewController = pageController
        addChildViewController(pageViewController!)
        pageViewController!.view.frame = CGRect(x: 0, y: headerView.frame.height, width: view.frame.width, height: view.frame.height - headerView.frame.height)
        pageViewController!.view.clipsToBounds = false
        pageViewController!.view.subviews.first?.clipsToBounds = false
        self.view.addSubview(pageViewController!.view)
        pageViewController!.didMove(toParentViewController: self)
        
        for v in pageViewController!.view.subviews {
            if let s = v as? UIScrollView {
                s.delaysContentTouches = false
            }
        }
    }
}

extension GroceryContainerVC {
    
    //MARK: - List Handling
    func didEditList() {
    }
    
    func loadList() {
    }
    
    func more() {
        let a = YoutubeActionController()
        a.addAction(Action(ActionData.init(title: "Load List", image: #imageLiteral(resourceName: "Upload Grey")), style: ActionStyle.default) { action in
            if !GroceryList.current.items.isEmpty {
                alert(actions: [
                    AlertButton("OK", action: self.loadList),
                    AlertButton("Cancel")
                ]).showWarning("Load List?", subTitle: "Any unsaved changes will be lost.")
                return
            }
            self.loadList()
        })
        a.addAction(Action(ActionData.init(title: "Save List", image: #imageLiteral(resourceName: "Save Grey")), style: ActionStyle.default) { action in
            if GroceryList.current.items.isEmpty {
                alert(actions: [AlertButton("OK")])
                .showWarning("Cannot Save List", subTitle: "Your list is empty.")
                return
            }
            
            let vc = EditDetailVC.instantiate(from: .lists)
            //vc.groceryList = GroceryList.current
            //vc.delegate = self
            self.present(vc, animated: true, completion: nil)
        })
        a.addAction(Action(ActionData.init(title: "Cancel", image: #imageLiteral(resourceName: "Cancel Grey ")), style: ActionStyle.cancel) { action in
            a.dismiss(animated: true, completion: nil)
        })
        self.present(a, animated: true, completion: nil)
    }
}
