//
//  Chapter.swift
//  mangakingdom-ios-mock
//
//  Created by Kim Cortez on 5/16/22.
//

import Foundation

struct Chapter {
    let pageCount: Int
    private var _pages: [URL]
    var pages: [Page] {
        return _pages.map({ Page(chapterId: id, url: $0) })
    }
    
    // Not decoded
    var id: String = ""
    var sortOder: Int = 0
}

extension Chapter: Decodable {
    private enum CodingKeys: String, CodingKey {
        case pageCount = "page_count"
        case pages
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        pageCount = (try? container.decode(Int.self, forKey: .pageCount)) ?? 0
        _pages = try container.decode([URL].self, forKey: .pages)
    }
}

extension Chapter: Hashable {}
