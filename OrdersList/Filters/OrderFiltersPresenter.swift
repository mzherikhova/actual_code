//
//  OrderFiltersPresenter.swift
//  ros
//
//  Created by Margarita Zherikhova on 27/09/2019.
//  Copyright © 2019 rosprom. All rights reserved.
//

import Foundation

protocol OrderFiltersPresenter: class {
    var module: OrderFiltersModule? {get set}
    var router: OrderFiltersRouter? {get set}
    var interactor: OrderFiltersInteractor? {get set}
    var filters : FiltersForm? {get set}
    
    func didLoad()
    func willAppear()
    func closeAndApplyFilters(orderStatuses: [OrderStatus])
    func close()
}

class OrderFiltersPresenterImpl: BasePresenter<OrderFiltersViewController>, OrderFiltersPresenter {
    weak var module: OrderFiltersModule?
    var router: OrderFiltersRouter?
    var interactor: OrderFiltersInteractor?
    
    var cancelBag = CancelBag()
    internal var fieldsModels: [AnyHashable: FieldModel] = [:]
    var currentFieldsModels: [FiltersFields: FieldModel] {
        return fieldsModels.map { (key, value) in (key.base as! FiltersFields, value) }
    }
    var filters : FiltersForm?
    
    func getSortTypes() -> [FiltersSortType] {
        return FiltersSortType.allValues()
    }
    
    override func didLoad() {
        super.didLoad()
    }
    
    func setValue(_ field: FiltersFields, newValue: FieldValue?) {
        let model = fieldsModels[field]
        model?.setValue(newValue)
    }
    

    
    func close() {
        router?.dismissFilters()
    }
    
   
    func filtersFormFromFields() {
        
    }
    func closeAndApplyFilters(orderStatuses: [OrderStatus]) {
        //let filter = filtersFormFromFields()
        module?.orderStatuses = orderStatuses
        router?.dismissFilters(orderStatuses: orderStatuses)
    }
    
    override func willAppear() {}
    
}

