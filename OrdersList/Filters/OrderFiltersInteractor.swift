//
//  OrdersFiltersInteractor.swift
//  ros
//
//  Created by Margarita Zherikhova on 27/09/2019.
//  Copyright © 2019 rosprom. All rights reserved.
//

import Foundation

protocol OrderFiltersInteractor : class {
  var orderRepository: OrdersRepository! { get set }
  func loadStatus()
}

class OrderFiltersInteractorImpl: OrderFiltersInteractor {
    var orderRepository: OrdersRepository!
    var orderStatus: [OrderStatus]?
    
    func loadStatus() {
        orderRepository.getStatusList(onSuccess: { (orderStatus) in
            self.orderStatus = orderStatus
        }) { (Error) in
            print(Error)
        }
    }
}
