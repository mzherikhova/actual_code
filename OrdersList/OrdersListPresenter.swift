//
//  OrdersPresenter.swift
//  ros
//
//  Created by Margarita Zherikhova on 18.06.2019.
//  Copyright © 2019 rosprom. All rights reserved.
//

import Foundation

protocol OrdersListView : class {
    var presenter: OrdersListPresenter? {get set}
    func showWarning(_ title: String?, msg: String?)
    func setLoading(_ loading: Bool)
    func showEmptyListStub(_ type: OrdersListType)
    func showListItems(_ items: [OrderLikeListForm], type: OrdersListType)
    func resetItemsList(_ type: OrdersListType)
}

protocol OrdersListPresenter : class {
    var module: OrdersListModule? {get set}
    var router: OrdersListRouter? {get set}
    var interactor : OrdersListInteractor? {get set}
    
    var currentListType : OrdersListType {get set}
    
    func didLoad(_ type : OrdersListType)
    func willAppear()
    func deauth()
    func refresh()
    func showFilters()
    func requestOrdersType(_ type : OrdersListType)
    func showDetais(_ order: OrderLikeListForm)
    func loadNextPage(type: OrdersListType)
    var ids:[Int]{ get set }
}

class OrdersListPresenterImpl :  BasePresenter<OrdersListView>, OrdersListPresenter {
    weak var module: OrdersListModule?
    weak var router: OrdersListRouter?
    var interactor : OrdersListInteractor?
    
    var currentListType : OrdersListType = .active
    var activePagingManager : Paginator<OrderLikeListForm>!
    var archivedPagingManager : Paginator<OrderLikeListForm>!
    var cancelBag = CancelBag()
    var ids:[Int] = []
    
    override init() {
        super.init()
        
        activePagingManager = Paginator(pageSize: 10, fetchHandler: { [weak self] (paginator, page, pageSize) in
            guard let welf = self else {
                return
            }
            
            welf.interactor?.getOrdersList(type: .active,
                                           orderStatuses: welf.ids,
                                                   page: page - 1,
                                                   onSuccess: { (list) in
                                                    var total = 10 * page
                                                    if list.count < 10 {
                                                        total = 10 * (page - 1) + list.count
                                                    } else {
                                                        total = 10 * (page + 1)
                                                    }
                                                    paginator.received(results: list, total: total)
            }, onFailure: {  (error) in
                paginator.failed()
            })?.cancelled(by: welf.cancelBag)
            }, resultsHandler: { (paginator, results) in
                self.view?.setLoading(false)
                if paginator.page == 1 {
                    self.view?.resetItemsList(.active)
                }
                self.view?.showListItems(results, type: .active)
        }, resetHandler: { (paginator) in
            
            }, failureHandler: { [weak self] (paginator) in
                self?.view?.setLoading(false)
                if paginator.page == 0 {
                    self?.view?.resetItemsList(.active)
                    self?.view?.showEmptyListStub(.active)
                }
            }, completionHandler: {  (paginator) in
                
        })
        
        archivedPagingManager = Paginator(pageSize: 10, fetchHandler: { [weak self] (paginator, page, pageSize) in
            guard let welf = self else {
                return
            }
            welf.interactor?.getOrdersList(type: .archived,
                                           orderStatuses: welf.ids,
                                                   page: page - 1,
                                                   onSuccess: { (list) in
                                                    var total = 10 * page
                                                    if list.count < 10 {
                                                        total = 10 * (page - 1) + list.count
                                                    } else {
                                                        total = 10 * (page + 1)
                                                    }
                                                    paginator.received(results: list, total: total)
            }, onFailure: {  (error) in
                paginator.failed()
            })?.cancelled(by: welf.cancelBag)
            }, resultsHandler: { (paginator, results) in
                self.view?.setLoading(false)
                if paginator.page == 1 {
                    self.view?.resetItemsList(.archived)
                }
                self.view?.showListItems(results, type: .archived)
        }, resetHandler: { (paginator) in
            
            }, failureHandler: { [weak self] (paginator) in
                self?.view?.setLoading(false)
                if paginator.page == 0 {
                    self?.view?.resetItemsList(.archived)
                    self?.view?.showEmptyListStub(.archived)
                }
            }, completionHandler: {  (paginator) in
                
        })
        
    }
    
    
    func didLoad(_ type: OrdersListType) {
        super.didLoad()
        (self.view as? OrdersListContainerController)?.searchBar = self.module?.searchModule?.getSearchBar()
        self.module?.searchModule?.delegate = self.view as? OrdersListContainerController
        (self.view as? OrdersListContainerController)?.searchController = self.module?.searchModule?.getSearchController()
        currentListType = type
        getOrdersList(currentListType)
    }
    
    func deauth() {
        
    }
    func showFilters() {
           self.router?.showFilters()
    }
    func refresh() {
        self.view?.resetItemsList(.active)
        self.view?.resetItemsList(.archived)
        self.getOrdersList(.active)
        self.getOrdersList(.archived)
    }
    
    func requestOrdersType(_ type: OrdersListType) {
        getOrdersList(type)
    }
    
    private func getOrdersList(_ type: OrdersListType) {
        self.view?.setLoading(true)
        if type == .active {
            activePagingManager.fetchFirstPage()
        } else {
            archivedPagingManager.fetchFirstPage()
        }
    }
    
    func loadNextPage(type: OrdersListType) {    
        if type == .active {
            if !activePagingManager.reachedLastPage {
                self.view?.setLoading(true)
                activePagingManager.fetchNextPage()
            }
        } else {
            if !archivedPagingManager.reachedLastPage {
                archivedPagingManager.fetchNextPage()
            }
        }
    }
    
    func showDetais(_ order: OrderLikeListForm) {
        router?.showOrderDetails(order)
    }
    
}


