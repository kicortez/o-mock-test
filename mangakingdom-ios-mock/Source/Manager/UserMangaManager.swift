//
//  UserMangaManager.swift
//  mangakingdom-ios-mock
//
//  Created by Kim Cortez on 5/30/22.
//

import Foundation
import FirebaseFirestore

class UserMangaManager {
    static let shared: UserMangaManager = UserMangaManager(service: UserMangaService())
    
    private let service: UserMangaServiceAPI
    
    private var userMangaInfoListener: ListenerRegistration?
    
    private(set) var userMangaInfo: [String: UserMangaInfo] = [:]
    
    private init(service: UserMangaServiceAPI) {
        self.service = service
    }
    
    func likeManga(_ manga: Manga, isLiked: Bool, userId: String, completion: @escaping (Error?) -> Void) {
        service.likeManga(manga.id, liked: isLiked, userId: userId) { error in
            completion(error)
        }
    }
    
    func readManga(_ manga: Manga, info: ReadInfo, userId: String, completion: @escaping (Error?) -> Void) {
        service.readManga(manga.id, info: info, userId: userId) { error in
            completion(error)
        }
    }
    
    func userMangaInfo(for userId: String, completion: @escaping (Result<[String: UserMangaInfo], Error>) -> Void) {
        let listener = service.userMangaInfo(for: userId) { result in
            switch result {
            case .success(let info):
                let dict = info.reduce([String: UserMangaInfo]()) { (result, userInfo) -> [String: UserMangaInfo] in
                    var result = result
                    result[userInfo.id] = userInfo
                    return result
                }
                
                self.userMangaInfo = dict
                completion(.success(self.userMangaInfo))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        userMangaInfoListener = listener
    }
    
    func mangaInfo(for manga: Manga) -> UserMangaInfo? {
        return userMangaInfo[manga.id]
    }
    
}
