//
//  OrdersListInteractorImpl.swift
//  ros
//
//  Created by Margarita Zherikhova on 20.06.2019.
//  Copyright © 2019 rosprom. All rights reserved.
//

import Foundation

class OrdersListInteractorImpl : OrdersListInteractor {
    var repository: OrdersRepository!
    var profileRepository: ProfileRepository!
    
    func getOrdersList(type: OrdersListType, orderStatuses:[Int], page: Int, onSuccess: OrdersRepository.OrdersListSuccess?, onFailure: CommonFailure?) -> Cancellable? {
        func onProfileGot(_ profile: Profile) -> Cancellable? {
            if profile.isCarrier || profile.isDispatcher {
                return self.repository.getOrdersList(type: type, orderStatuses:orderStatuses, page: page, onSuccess: onSuccess, onFailure: onFailure)
            } else if profile.isDriver {
               
                return self.repository.getOrdersRFTList(type: type, orderStatuses:orderStatuses, page: page, onSuccess: onSuccess, onFailure: onFailure)
            } else {
                onSuccess?([])
                return nil
            }
        }
        if let profile = profileRepository.getStoredProfile() {
            return onProfileGot(profile)
        } else {
            return profileRepository.getProfile(onSuccess: { (profile) in
                _ = onProfileGot(profile)
            }) { (error) in
                onFailure?(error)
            }
        }
    }
}
