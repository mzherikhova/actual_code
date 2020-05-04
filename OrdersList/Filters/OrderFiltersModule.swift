//
//  OrderFiltersModule.swift
//  ros
//
//  Created by Margarita Zherikhova on 27/09/2019.
//  Copyright © 2019 rosprom. All rights reserved.
//

import Foundation
import Swinject

protocol OrderFiltersModuleDelegate : class {
    func filtersModuleDidCancel()
    func filtersModuleDidSelectFilters(_ filters: [OrderStatus])
}

class OrderFiltersModule: ViewControllerModule {
    let container = Container(parent: Dependencies.default())
    weak var delegate : OrderFiltersModuleDelegate?
    public var orderStatuses:[OrderStatus]?
    
    init() {
        container.register(OrderFiltersViewController.self) { (r) in
            let controller = OrderFiltersViewController()
            controller.orderRepository = try! r.resolveStrong(OrdersRepository.self)
            return controller
            }.initCompleted({ (r, view) in
                view.presenter = try! r.resolveStrong(OrderFiltersPresenter.self)
            }).inObjectScope(.container)
        
        container.register(OrderFiltersPresenter.self) { _ in
            OrderFiltersPresenterImpl()
            }.initCompleted { (r, presenter) in
                (presenter as! OrderFiltersPresenterImpl).attachView(try! r.resolveStrong(OrderFiltersViewController.self))
                presenter.module = self
                presenter.router = self
                presenter.interactor = try! r.resolveStrong(OrderFiltersInteractor.self)
        }
        
        container.register(OrderFiltersInteractor.self) { _ in
            OrderFiltersInteractorImpl()
            }.initCompleted { (r, interactor) in
                interactor.orderRepository = try! r.resolveStrong(OrdersRepository.self)
        }
    }
    
    func getEntry() -> UIViewController {
        let view = try! container.resolveStrong(OrderFiltersViewController.self)
        return view 
    }
}

extension OrderFiltersModule: OrderFiltersRouter {
    func dismissFilters(orderStatuses: [OrderStatus]) {
        delegate?.filtersModuleDidSelectFilters(orderStatuses)
    }
    func dismissFilters() {
        delegate?.filtersModuleDidCancel()
    }
}
