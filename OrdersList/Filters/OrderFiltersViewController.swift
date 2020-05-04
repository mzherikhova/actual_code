//
//  OrderFiltersViewController.swift
//  ros
//
//  Created by Margarita Zherikhova on 27/09/2019.
//  Copyright © 2019 rosprom. All rights reserved.
//

import Foundation

struct OrderStatus {
    var id: Int
    var name: String
    var status: Bool
}
class OrderFiltersViewController : BaseFormViewController {
    var presenter: OrderFiltersPresenter?
    var orderStatuses: [OrderStatus] = [] {
           didSet {
            tableView?.reloadData()
           }
    }
    var fields: [FiltersFields: MaterialInputContainer] = [:]
    var order: [FiltersFields] = [.regionLoad, .regionUnload]
    var stackView: UIStackView!
    var clearButton : UIButton!
    var submitButton: UIButton!
    var buttonContainer: UIView!
    var currentResponder: FiltersFields?
    var inputAccessory: CommonInputAccessoryView!
    var tableView : UITableView?
    var orderRepository: OrdersRepository!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Статусы заказов"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: R.image.close(), style: .plain, target: self, action: #selector(close))
        
        self.view.backgroundColor = .white
        
        scroll = UIScrollView()
        view.addSubview(scroll)
        scroll.snp.makeConstraints { (snp) in
            snp.edges.equalToSuperview()
        }
        
        let container = UIView()
        scroll.addSubview(container)
        container.snp.makeConstraints { (snp) in
            snp.edges.equalToSuperview()
            snp.width.equalToSuperview()
        }
        tableView = UITableView(frame: self.view.bounds, style: .plain)
        tableView?.dataSource = self
        tableView?.delegate = self
        tableView?.rowHeight = UITableViewAutomaticDimension
        tableView?.estimatedRowHeight = 168
        tableView?.separatorStyle = .none
        tableView?.tableFooterView = UIView()
        view.addSubview(tableView!)
        tableView?.snp.makeConstraints { (snp) in
            snp.top.equalToSuperview()
            snp.left.right.equalToSuperview()
            snp.bottom.equalToSuperview().offset(-200)
        }
        buttonContainer = UIView()
        buttonContainer.backgroundColor = UIColor.clear
        view.addSubview(buttonContainer)
        buttonContainer.snp.makeConstraints { (snp) in
            snp.left.right.equalToSuperview()
            snp.bottom.equalTo(self.view.safeArea.bottom)
        }
        
        clearButton = FramedButton()
        clearButton.setTitle(R.string.localizable.filtersClear(), for: .normal)
        clearButton.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        clearButton.addTarget(self, action: #selector(onClear), for: .touchUpInside)
        buttonContainer.addSubview(clearButton)
        clearButton.snp.makeConstraints { (snp) in
            snp.left.equalToSuperview().offset(16)
            snp.right.equalToSuperview().offset(-16)
            snp.top.equalToSuperview().offset(16)
            snp.height.equalTo(60)
        }
        
        // Button
        submitButton = BlueActionButton()
        submitButton.setTitle(R.string.localizable.filtersApply(), for: .normal)
        buttonContainer.addSubview(submitButton)
        submitButton.addTarget(self, action: #selector(onSubmit), for: .touchUpInside)
        submitButton.snp.makeConstraints { (snp) in
            snp.left.equalToSuperview().offset(16)
            snp.right.equalToSuperview().offset(-16)
            snp.bottom.equalToSuperview().offset(-16)
            snp.height.equalTo(60)
            snp.top.equalTo(clearButton.snp.bottom).offset(12)
        }
        if let orderStatuses = presenter?.module?.orderStatuses {
                   print(orderStatuses)
                   self.orderStatuses = orderStatuses
        } else {
            orderRepository.getStatusList(onSuccess: { (orderStatus) in
                self.orderStatuses = orderStatus
            }) { (Error) in
                print(Error)
            }
        }
        
    }
    
    override func defaultScrollBottomInset() -> Float {
        return 164
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter?.willAppear()
        adjustInsets()
        if let orderStatuses = presenter?.module?.orderStatuses {
            self.orderStatuses = orderStatuses
        }
    }
    
    func adjustInsets() {
        scroll.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: CGFloat(defaultScrollBottomInset()), right: 0)
    }
    
    @objc
    func close() {
        presenter?.close()
    }
    
    @objc
    fileprivate func onSubmit() {
        if let responder = currentResponder, let input = fields[responder], input.isFirstResponder {
            input.resignFirstResponder()
        }
        presenter?.closeAndApplyFilters(orderStatuses: orderStatuses)
    }
    
    @objc
    fileprivate func onClear() {
        if let responder = currentResponder, let input = fields[responder], input.isFirstResponder {
            input.resignFirstResponder()
        }
        var newOrderStatuses:[OrderStatus] = []
        for st in self.orderStatuses {
           let newOrderStatus = OrderStatus(id: st.id, name: st.name, status: false)
                newOrderStatuses.append(newOrderStatus)
        }
        self.orderStatuses = newOrderStatuses
    }
}

// MARK: - UITableViewDataSource
extension OrderFiltersViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderStatuses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "OrderFiltersCell") as? OrderFiltersCell
        if cell == nil {
            cell = OrderFiltersCell()
        }
        let item = orderStatuses[indexPath.row]
        cell?.orderStatus = item
        cell?.delegate = self
        return cell!
    }
}

extension OrderFiltersViewController : OrderFiltersCelllDelegate {
    func settingChanged(orderStatus: OrderStatus) {
        var newOrderStatuses:[OrderStatus] = []
        for st in self.orderStatuses {
            if st.id == orderStatus.id {
                let newOrderStatus = OrderStatus(id: orderStatus.id, name: orderStatus.name, status: orderStatus.status)
                newOrderStatuses.append(newOrderStatus)
            } else {
                newOrderStatuses.append(st)
            }
            
        }
        self.orderStatuses = newOrderStatuses
    }
}

// MARK: - UITableViewDelegate
extension OrderFiltersViewController: UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.rosDisabled
        return headerView
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.rosDisabled
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
}



