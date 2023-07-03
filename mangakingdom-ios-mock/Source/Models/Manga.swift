//
//  Manga.swift
//  mangakingdom-ios-mock
//
//  Created by Kim Cortez on 5/13/22.
//

import Foundation
import FirebaseFirestoreSwift

struct Manga {
    @DocumentID var id: String!
    let title: String
    let author: String
    let likes: Int
    let chapterCount: Int
    let coverImageUrl: URL
    let isEnabled: Bool
    
    // Not decoded
    var chapters: [Chapter] = []
}

extension Manga: Decodable {
    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case author
        case likes
        case chapterCount = "chapter_count"
        case coverImageUrl = "cover_image_url"
        case isEnabled = "is_enabled"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(DocumentID<String>.self, forKey: .id).wrappedValue
        title = try container.decode(String.self, forKey: .title)
        author = try container.decode(String.self, forKey: .author)
        likes = (try? container.decode(Int.self, forKey: .likes)) ?? 0
        chapterCount = (try? container.decode(Int.self, forKey: .chapterCount)) ?? 0
        coverImageUrl = try container.decode(URL.self, forKey: .coverImageUrl)
        isEnabled = (try? container.decode(Bool.self, forKey: .isEnabled)) ?? false
    }
}

extension Manga: Hashable {
    static func == (lhs: Manga, rhs: Manga) -> Bool {
        return lhs.id == rhs.id
    }
}

