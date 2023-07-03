//
//  MangaManager.swift
//  mangakingdom-ios-mock
//
//  Created by Kim Cortez on 5/13/22.
//

import Foundation
import FirebaseFirestore
import Combine

class MangaManager {
    
    static let shared = MangaManager(service: MangaService())

    private var service: MangaServiceAPI
    
    init(service: MangaServiceAPI) {
        self.service = service
    }
    
    private var lastMangaSnapshot: DocumentSnapshot?
    var mangaPublisher: PassthroughSubject<[Manga], Error> = PassthroughSubject()
    var mangaCollection: [Manga] = []
    
    private var mangaCount = 0
    
    func getManga() {
        if !mangaCollection.isEmpty, lastMangaSnapshot == nil {
            mangaPublisher.send(mangaCollection)
            
            if self.mangaCollection.count == self.mangaCount {
                mangaPublisher.send(completion: .finished)
            }
            // All manga fetched
            return
        }
        
        service.getManga(after: lastMangaSnapshot, completion: { [weak self] result in
            switch result {
            case .success(let mangaResult):
                self?.lastMangaSnapshot = mangaResult.lastPageSnapshot
                self?.getChapters(for: mangaResult.manga)
                self?.mangaCount += mangaResult.manga.count
                // Recursively fetches all -> Move to user based fetching
                self?.getManga()
            case .failure(let error):
                // Handle error
                print(">>> \(error.localizedDescription)")
            }
        })
    }
    
    private func getChapters(for mangas: [Manga]) {
        let group = DispatchGroup()
        group.notify(queue: .main) {
            self.mangaPublisher.send(self.mangaCollection)
            
            if self.mangaCollection.count == self.mangaCount {
                self.mangaPublisher.send(completion: .finished)
            }
        }
        
        for var manga in mangas {
            group.enter()
            
            service.getChapters(for: manga) { result in
                switch result {
                case .success(let chapters):
                    manga.chapters = chapters
                    self.mangaCollection.append(manga)
                case .failure(let error):
                    print(">>> \(error)")
                }
                
                group.leave()
            }
        }
    }
    
}
