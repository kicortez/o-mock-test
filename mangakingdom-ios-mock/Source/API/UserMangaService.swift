//
//  UserMangaManager.swift
//  mangakingdom-ios-mock
//
//  Created by Kim Cortez on 5/30/22.
//

import Foundation
import FirebaseFirestore

protocol UserMangaServiceAPI {
    func likeManga(_ mangaId: String, liked: Bool, userId: String, completion: @escaping (Error?) -> Void)
    func readManga(_ mangaId: String, info: ReadInfo, userId: String, completion: @escaping (Error?) -> Void)
    func userMangaInfo(for userId: String, completion: @escaping (Result<[UserMangaInfo], Error>) -> Void) -> ListenerRegistration
}

class UserMangaService: UserMangaServiceAPI {
    
    private let store: Firestore = .firestore()
    
    func likeManga(_ mangaId: String, liked: Bool, userId: String, completion: @escaping (Error?) -> Void) {
        let ref = store.document("users/\(userId)/manga/\(mangaId)")
        ref.setData(["liked": liked], merge: true, completion: completion)
    }
    
    func readManga(_ mangaId: String, info: ReadInfo, userId: String, completion: @escaping (Error?) -> Void) {
        let ref = store.document("users/\(userId)/manga/\(mangaId)")
        ref.setData(["read_info": ["chapter": info.chapter, "page": info.page]], merge: true, completion: completion)
    }
    
    func userMangaInfo(for userId: String, completion: @escaping (Result<[UserMangaInfo], Error>) -> Void) -> ListenerRegistration {
        let ref = store.collection("users/\(userId)/manga")
        return ref.addSnapshotListener { snapshot, error in
            if let snapshot = snapshot {
                let documents = snapshot.documents
                let mangaInfo = documents.compactMap { try? $0.data(as: UserMangaInfo.self) }
                completion(.success(mangaInfo))
                return
            }
            
            if let error = error {
                completion(.failure(error))
            }
        }
    }
    
}
