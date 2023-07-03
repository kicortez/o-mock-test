//
//  UserMangaInfo.swift
//  mangakingdom-ios-mock
//
//  Created by Kim Cortez on 5/30/22.
//

import Foundation
import FirebaseFirestoreSwift

struct UserMangaInfo {
    @DocumentID var id: String!
    let liked: Bool?
    let readInfo: ReadInfo?
}

struct ReadInfo: Codable {
    let chapter: String
    let page: Int
//    let last_read: Date
}

extension UserMangaInfo: Codable {
    private enum CodingKeys: String, CodingKey {
        case id
        case liked
        case readInfo = "read_info"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(DocumentID<String>.self, forKey: .id).wrappedValue
        liked = try? container.decode(Bool.self, forKey: .liked)
        readInfo = try? container.decode(ReadInfo.self, forKey: .readInfo)
    }
}
