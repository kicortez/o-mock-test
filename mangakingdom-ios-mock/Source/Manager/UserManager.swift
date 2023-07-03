//
//  UserManager.swift
//  mangakingdom-ios-mock
//
//  Created by Kim Cortez on 5/30/22.
//

import Foundation

class UserManager {
    
    static let shared: UserManager = UserManager(service: UserService())
    
    private var _userId: String?
    var userId: String? {
        return _userId
    }
    
    private var service: UserServiceAPI
    
    init(service: UserServiceAPI) {
        self.service = service
    }
    
    func login(completion: @escaping (Result<String, Error>) -> Void) {
        service.login { [weak self] result in
            switch result {
            case .success(let userId):
                self?._userId = userId
                self?.service.setLastLogin(for: userId, completion: { error in
                    if let error = error {
                        completion(.failure(error))
                    }
                    else {
                        completion(.success(userId))
                    }
                })
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
