//
//  OrdersListInteractor.swift
//  ros
//
//  Created by Margarita Zherikhova on 20.06.2019.
//  Copyright © 2019 rosprom. All rights reserved.
//

import Foundation

protocol OrdersListInteractor : class {
    var repository: OrdersRepository! { get set }
    var profileRepository: ProfileRepository! { get set }
    
    @discardableResult
    func getOrdersList(type : OrdersListType,
                       orderStatuses:[Int],
                       page: Int,
                        onSuccess: OrdersRepository.OrdersListSuccess?,
                        onFailure: CommonFailure?) -> Cancellable?
}
