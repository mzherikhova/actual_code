//
//  OrderFiltersRouter.swift
//  ros
//
//  Created by Margarita Zherikhova on 27/09/2019.
//  Copyright © 2019 rosprom. All rights reserved.
//

import Foundation

protocol OrderFiltersRouter {
    func dismissFilters(orderStatuses: [OrderStatus])
    func dismissFilters()
}
