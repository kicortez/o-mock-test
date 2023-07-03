//
//  MangaPrefetcher.swift
//  mangakingdom-ios-mock
//
//  Created by Kim Cortez on 5/16/22.
//

import Foundation
import SDWebImage

class MangaPrefetcher {
    
    static let shared = MangaPrefetcher()
    
    func fetchCovers(for manga: [Manga], completion: @escaping () -> Void) {
        SDWebImagePrefetcher.shared.prefetchURLs(manga.map({ $0.coverImageUrl })) { c, t in
            
        } completed: { c, t in
            if c > 0 {
                completion()
            }
        }
    }
    
    func fetchPages(for chapter: Chapter, from page: Int, limit: Int, completion: @escaping () -> Void) {
        let pages = chapter.pages
        let maxIndex = chapter.pageCount - 1
        let safeLimit = min(page + limit, maxIndex)
        let start = max(min(page, maxIndex), 0)
        let toFetch = pages[start...safeLimit].map { $0.url }
        
        SDWebImagePrefetcher.shared.prefetchURLs(toFetch, progress: nil) { c, _ in
            if c > 0 {
                completion()
            }
        }
    }
    
    func fetchPages(_ urls: [URL], completion: @escaping () -> Void) {
        SDWebImagePrefetcher.shared.prefetchURLs(urls, progress: nil) { c, _ in
            if c > 0 {
                completion()
            }
        }
    }
    
}
