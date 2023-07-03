//
//  UserService.swift
//  mangakingdom-ios-mock
//
//  Created by Kim Cortez on 5/30/22.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

protocol UserServiceAPI {
    func login(completion: @escaping (Result<String, Error>) -> Void)
    func setLastLogin(for userId: String, completion: @escaping (Error?) -> Void)
}

class UserService: UserServiceAPI {
    let store: Firestore = .firestore()
    
    func login(completion: @escaping (Result<String, Error>) -> Void) {
        Auth.auth().signInAnonymously { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let result = result {
                completion(.success(result.user.uid))
            }
        }
    }
    
    func setLastLogin(for userId: String, completion: @escaping (Error?) -> Void) {
        let ref = store.document("users/\(userId)")
        
        ref.setData(["last_login_date": FieldValue.serverTimestamp()], merge: true) { error in
            completion(error)
        }
    }
}
