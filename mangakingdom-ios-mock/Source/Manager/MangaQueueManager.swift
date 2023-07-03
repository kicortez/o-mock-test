//
//  MangaQueueManager.swift
//  mangakingdom-ios-mock
//
//  Created by Kim Cortez on 5/31/22.
//

import Foundation

class MangaQueueManager {
    
    private var manga: [Manga] {
        return MangaManager.shared.mangaCollection
    }
    
    private var unreadManga: [Manga] {
        return manga.filter { manga in
            return !userManga.contains(where: { manga.id == $0.id && $0.readInfo != nil })
        }
    }
    
    private var readManga: [Manga] {
        return manga.filter { manga in
            return userManga.contains(where: { manga.id == $0.id && $0.readInfo != nil })
        }
    }
    
    private let userManga: [UserMangaInfo]
    
    var queuedManga: [Manga] = []
    
    private var unqueuedReadManga: [Manga] {
        return readManga.filter { !queuedManga.contains($0) }
    }
    
    private var unqueuedUnreadManga: [Manga] {
        return unreadManga.filter { !queuedManga.contains($0) }
    }
    
    init(userManga: [UserMangaInfo]) {
        self.userManga = userManga
    }
    
    func getMangaToDisplay(at page: Int) -> Manga? {
        guard page < manga.count else { return nil }
        
        // If this page is previously queried, and stored in queuedManga, return the same
        if page < queuedManga.count {
            return queuedManga[page]
        }
        
        let needsReadManga = (page + 1) % 4 == 0
        
        // Display read manga every 4th manga
        // Read manga every (page + 1) % 4 == 0
        
        // Case 1: All unread -> No read (new users)
        // Unread -> Unread -> Unread -> Unread -> Unread -> Unread -> Unread -> Unread -> ...
        
        // Case 2: Some read, some unread (returning users)
        // Unread -> Unread -> Unread -> Read -> Unread -> Unread -> Unread -> Read -> ...
        
        // Case 3: All read (returning users)
        // Read -> Read -> Read -> Read -> Read -> Read -> Read -> Read -> ...
        
        if readManga.isEmpty && unreadManga.isEmpty {
            // Case 1/3 -> No un/read, return as is based on original collection
            let item = manga[page]
            queuedManga.append(item)
            return item
        }
        
        // Case 2
        if needsReadManga {
            // Get from read first, if one is available. Otherwise, get from unread
            if let manga = unqueuedReadManga.first ?? unqueuedUnreadManga.first {
                queuedManga.append(manga)
                return manga
            }
            
            // No more from unread and read, empty
            return nil
        }
        else {
            // Get from unread first, if one is available. Otherwise, get from read
            if let manga = unqueuedUnreadManga.first ?? unqueuedReadManga.first {
                queuedManga.append(manga)
                return manga
            }
            
            // No more from unread and read, empty
            return nil
        }
    }
    
}
