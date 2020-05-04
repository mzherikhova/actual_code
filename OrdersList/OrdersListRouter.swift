//
//  OrdersRouter.swift
//  ros
//
//  Created by Margarita Zherikhova on 18.06.2019.
//  Copyright © 2019 rosprom. All rights reserved.
//

import Foundation

protocol OrdersListRouter : class {
    func showOrderDetails(_ order : OrderLikeListForm)
    func showFilters()
}
