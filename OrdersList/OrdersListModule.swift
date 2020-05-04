//
//  OrdersModule.swift
//  ros
//
//  Created by Margarita Zherikhova on 18.06.2019.
//  Copyright © 2019 rosprom. All rights reserved.
//

import Foundation

import Swinject

class OrdersListModule: ViewControllerModule {
    var orderFiltersModule : OrderFiltersModule?
    let container = Container(parent: Dependencies.default())
    
    var detailsModule : OrderDetailsModule?
    var searchModule : SearchModule?
    var deeplinkHandling: DeepLinkHandling?
    var orderStatus:[OrderStatus]?
    
    init() {
        searchModule = SearchModule()
        container.register(OrdersListView.self) { (r) in
            let controller = OrdersListContainerController()
            return controller
            }.initCompleted({ (r, view) in
                view.presenter = try! r.resolveStrong(OrdersListPresenter.self)
            }).inObjectScope(.container)

        container.register(OrdersListPresenter.self) { _ in
            OrdersListPresenterImpl()
            }.initCompleted { (r, presenter) in
                (presenter as! OrdersListPresenterImpl).attachView(try! r.resolveStrong(OrdersListView.self))
                presenter.module = self
                presenter.router = self
                presenter.interactor = try! r.resolveStrong(OrdersListInteractor.self)
        }

        container.register(OrdersListInteractor.self) { r in
            OrdersListInteractorImpl()
            }.initCompleted { r, interactor in
                interactor.repository = try! r.resolveStrong(OrdersRepository.self)
                interactor.profileRepository = try! r.resolveStrong(ProfileRepository.self)
        }
    }
    
    func getEntry() -> UIViewController {
        let view = try! container.resolveStrong(OrdersListView.self)
        return view as! UIViewController
    }
}

extension OrdersListModule: OrdersListRouter {
    func showOrderDetails(_ order: OrderLikeListForm) {
        detailsModule = OrderDetailsModule(order)
        detailsModule?.delegate = self
        self.pushScreen(detailsModule!.getEntry(), animated: true)
    }
    
    func showFilters() {
        orderFiltersModule = OrderFiltersModule()
        orderFiltersModule?.delegate = self
        orderFiltersModule?.orderStatuses = searchModule?.orderStatus
        presentModalScreen(orderFiltersModule!.getEntry(), animated: true)
    }
}

extension OrdersListModule : DeepLinkHandler {
    func open(deeplink: DeepLink, animated: Bool) -> DeepLinkHandling {
        switch deeplink {
        case let deeplink as OrderDeepLink:
            let order = OrderForm(number: nil, bidAmount: nil, cargoDescription: nil, cargoWeight: nil, creationDateTime: nil, endDateTime: nil, loading: nil, unloading: nil, id: deeplink.id, pricePerKm: nil, transportTypeId: nil, transportNumber: nil, transportTypeHumanReadable: nil, type: nil, conditionType: nil,truckSemitrailerNumber: nil, driverSNP: nil, lastStatusName: nil)
            showOrderDetails(order)
            return .opened(deeplink)
        default:
            return .rejected(deeplink, nil)
        }
    }
}

extension OrdersListModule: OrderDetailsModuleDelegate {
    func updateOrdersList() {
        let view = self.getEntry() as? OrdersListView
        view?.presenter?.refresh()
    }
}


extension OrdersListModule : OrderFiltersModuleDelegate {
    func filtersModuleDidCancel() {
        dismissFiltersModule()
    }
    func filtersModuleDidSelectFilters(_ filters: [OrderStatus]) {
        //let view = try! container.resolveStrong(TendersListView.self)
       // view.presenter?.updateFilters(filters)
        dismissFiltersModule()
        searchModule?.orderStatus = filters
        var ids:[Int] = []
        
        for status in filters {
            if status.status {
               ids.append(status.id)
            }
        }
    
        let view = self.getEntry() as? OrdersListContainerController
        view?.presenter?.ids = ids
        view?.presenter?.refresh()
    }
    
    func dismissFiltersModule() {
        orderFiltersModule?.getEntry().dismiss(animated: true, completion: nil)
        orderFiltersModule = nil
    }
}
