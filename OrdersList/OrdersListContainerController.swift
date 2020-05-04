//
//  OrdersListContainerController.swift
//  ros
//
//  Created by Margarita Zherikhova on 18.06.2019.
//  Copyright © 2019 rosprom. All rights reserved.
//

import Foundation

class OrdersListContainerController : BaseViewController {
    var searchController : UISearchController?
    var searchBar : UISearchBar?
    var presenter: OrdersListPresenter? {
        didSet {
            activeOrdersController.presenter = presenter
            archievedOrdersController.presenter = presenter
        }
    }
    
    var segmentedControl : SegmentedControl!
    var currentController : OrdersListViewController? {
        didSet {
            setupActiveController(oldValue)
        }
    }
    
    var activeOrdersController : OrdersListViewController
    var archievedOrdersController : OrdersListViewController
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        activeOrdersController = OrdersListViewController()
        activeOrdersController.ordersListType = .active
        archievedOrdersController = OrdersListViewController()
        archievedOrdersController.ordersListType = .archived
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.title = R.string.localizable.ordersTitle()
        self.tabBarItem?.title = R.string.localizable.ordersTitle()
        self.tabBarItem.image = R.image.tabbar2Off()?.withRenderingMode(.alwaysOriginal)
        self.tabBarItem.selectedImage = R.image.tabbar2On()?.withRenderingMode(.alwaysOriginal)
        
        self.edgesForExtendedLayout = UIRectEdge(rawValue: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        segmentedControl = SegmentedControl(items: [R.string.localizable.activeOrders(), R.string.localizable.archievedOrders()])
        segmentedControl.addTarget(self, action: #selector(segmentedControlChanged(_:)), for: .valueChanged)
        view.addSubview(segmentedControl)
        segmentedControl.snp.makeConstraints { (snp) in
            snp.height.equalTo(48)
            snp.top.left.right.equalToSuperview()
        }
        let listType = presenter!.currentListType
        segmentedControl.selectedSegmentIndex = listType == .active ? 0 : 1
        adjustCurrentController()
    }
    
    func setupActiveController(_ oldController : OrdersListViewController?) {
        if currentController == oldController {
            return
        }
        if oldController != nil {
            oldController?.willMove(toParentViewController: nil)
            oldController?.view.removeFromSuperview()
            oldController?.removeFromParentViewController()
            oldController?.didMove(toParentViewController: nil)
        }
        if currentController != nil {
            currentController?.willMove(toParentViewController: self)
            self.addChildViewController(currentController!)
            view.addSubview(currentController!.view)
            currentController!.view.frame = view.bounds
            currentController?.view.snp.makeConstraints({ (snp) in
                snp.top.equalTo(segmentedControl.snp.bottom)
                snp.left.right.bottom.equalToSuperview()
            })
            currentController?.didMove(toParentViewController: self)
        }
        view.bringSubview(toFront: segmentedControl)
        if let loader = activityIndicatorView {
            self.view.bringSubview(toFront: loader)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.definesPresentationContext = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: R.image.icFilter(), style: .plain, target: self, action: #selector(showFilters))
    }
    @objc
    func showFilters() {
       self.presenter?.showFilters()
    }
    override func viewWillAppear(_ animated: Bool) {
        showSearchBar()
    }
    func showSearchBar() {
        if #available(iOS 11.0, *) {
            self.navigationItem.searchController = nil
            self.navigationItem.searchController = searchController
            self.navigationItem.searchController?.obscuresBackgroundDuringPresentation = false
            self.navigationItem.hidesSearchBarWhenScrolling = false
        } else {
            showSearchButton()
        }
        definesPresentationContext = true
    }
    
    func adjustCurrentController() {
        if segmentedControl.selectedSegmentIndex == 0 {
            self.currentController = activeOrdersController
        } else {
            self.currentController = archievedOrdersController
        }
    }
    
    @objc
    func segmentedControlChanged(_ sender: SegmentedControl) {
        adjustCurrentController()
        if segmentedControl.selectedSegmentIndex == 0 {
            presenter?.module?.searchModule?.mode = .active
        } else {
            presenter?.module?.searchModule?.mode = .archived
        }
        presenter?.currentListType = segmentedControl.selectedSegmentIndex == 0 ? .active : .archived
    }
    
    
}

extension OrdersListContainerController : OrdersListView {
    
    func setLoading(_ loading: Bool) {
        if let control = self.currentController?.refreshControl,
            control.isRefreshing {
            if loading  {
                return
            } else {
                control.endRefreshing()
            }
        }
        super.setLoading(loading)
    }
    
    func showEmptyListStub(_ type: OrdersListType) {
        
    }
    
    func showListItems(_ items: [OrderLikeListForm], type: OrdersListType) {
        if type == .active {
            activeOrdersController.showListItems(items, type: type)
        } else {
            archievedOrdersController.showListItems(items, type: type)
        }
    }
    
    func resetItemsList(_ type: OrdersListType) {
        if type == .active {
            activeOrdersController.resetItemsList(.active)
        } else {
            archievedOrdersController.resetItemsList(.archived)
        }
    }
    
    @objc
    func searchPressed() {
        self.navigationItem.titleView = searchBar
        self.navigationItem.setRightBarButton(nil, animated: true)
        self.searchBar?.becomeFirstResponder()
    }
    
    func showSearchButton() {
        let searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(self.searchPressed))
        self.navigationItem.setRightBarButton(searchButton, animated: true)
        self.navigationItem.titleView = nil
    }
}

extension OrdersListContainerController : SearchModuleDelegate {
    
    func didDismissSearchController() {
        self.navigationController?.view.setNeedsLayout()
        self.navigationController?.view.layoutIfNeeded()
        if #available(iOS 11.0, *) {
            
        } else {
            self.showSearchButton()
        }
    }
    
    func showDetails(_ model: OrderLikeListForm) {
        self.presenter?.showDetais(model)
    }
    
}
