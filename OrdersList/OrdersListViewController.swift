//
//  OrdersListViewController.swift
//  ros
//
//  Created by Margarita Zherikhova on 18.06.2019.
//  Copyright © 2019 rosprom. All rights reserved.
//

import Foundation

class OrdersListViewController : BaseViewController {
    var presenter: OrdersListPresenter?
    
    var tableView : UITableView!
    var refreshControl : UIRefreshControl!
    weak var delegate : OrdersListView?
    var ordersListType : OrdersListType!
    var noItemsLabel : UILabel!
    
    var items = [OrderLikeListForm]() {
        didSet {
            stopRefreshControl()
        }
    }
    
    override func loadView() {
        super.loadView()
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 168
        tableView.clipsToBounds = false
        tableView.backgroundColor = .paleGrey
        tableView.backgroundView?.isHidden = true
        tableView.separatorStyle = .none
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (snp) in
            snp.edges.equalToSuperview()
        }
        
        refreshControl = UIRefreshControl(frame: .zero)
        refreshControl.addTarget(self, action: #selector(reloadForced), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        noItemsLabel = UILabel()
        noItemsLabel.reapplyStyle(TextStyle.description)
        noItemsLabel.textAlignment = .center
        noItemsLabel.numberOfLines = 0
        view.addSubview(noItemsLabel)
        noItemsLabel.isHidden = true
        noItemsLabel.snp.makeConstraints { (snp) in
            snp.top.equalToSuperview().offset(149)
            snp.left.equalToSuperview().offset(15)
            snp.right.equalToSuperview().inset(15)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter?.didLoad(ordersListType)
    }
    

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func stopRefreshControl() {
        if (refreshControl != nil && refreshControl.isRefreshing) {
            refreshControl.endRefreshing()
        }
    }
    
    @objc
    func reloadForced() {
        presenter?.requestOrdersType(ordersListType)
    }
}


extension OrdersListViewController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellID = "OrdersListCellID"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellID) as? TenderListCell
        if cell == nil {
            cell = TenderListCell(style: .default, reuseIdentifier: cellID)
        }
        let item = itemAtIndexPath(indexPath)
        cell?.tender = item
        return cell!
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 40
    }
    
    func itemAtIndexPath(_ indexPath : IndexPath) -> OrderLikeListForm {
        return items[indexPath.row]
    }
}

extension OrdersListViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let order = itemAtIndexPath(indexPath)
        self.presenter?.showDetais(order)
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if items.count > 0 {
            if indexPath.row == items.count - 3 {
                presenter?.loadNextPage(type: ordersListType)
            }
        }
    }
}

extension OrdersListViewController : OrdersListView {
    
    
    func showEmptyListStub(_ type: OrdersListType) {
        
    }
    
    func showListItems(_ items: [OrderLikeListForm], type: OrdersListType) {
        self.items.append(contentsOf: items)
        guard self.isViewLoaded else {
            return
        }
        if items.count > 0 {
            noItemsLabel.isHidden = true
        } else {
            noItemsLabel.isHidden = false
            if type == .active {
                noItemsLabel.text = "У вас нет активных заказов"
            } else {
                noItemsLabel.text = "У вас нет архивных заказов"
            }
        }
        tableView.reloadData()
    }
    
    func resetItemsList(_ type: OrdersListType) {
        self.items.removeAll()
        guard self.isViewLoaded else {
            return
        }
        tableView.reloadData()
    }
}
