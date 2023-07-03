//
//  MangaService.swift
//  mangakingdom-ios-mock
//
//  Created by Kim Cortez on 5/13/22.
//

import Foundation
import FirebaseFirestore

struct PagedMangaResult {
    let lastPageSnapshot: DocumentSnapshot?
    let manga: [Manga]
}

protocol MangaServiceAPI {
    func getManga(after snapshot: DocumentSnapshot?, completion: @escaping (Result<PagedMangaResult, Error>) -> Void)
    func getChapters(for manga: Manga, completion: @escaping (Result<[Chapter], Error>) -> Void)
}

class MangaService {
    let store: Firestore = .firestore()
}

extension MangaService: MangaServiceAPI {
    
    func getManga(after snapshot: DocumentSnapshot?, completion: @escaping (Result<PagedMangaResult, Error>) -> Void) {
        // Move limit as param
        var query = store.collection("manga").limit(to: 10)
        
        if let snapshot = snapshot {
            query = query.start(afterDocument: snapshot)
        }
        
        query.getDocuments(completion: { snapshot, error in
            if let snapshot = snapshot {
                let documents = snapshot.documents
                let decodedDocuments = documents.compactMap({ try? $0.data(as: Manga.self) })
                completion(.success(PagedMangaResult(lastPageSnapshot: documents.last, manga: decodedDocuments)))
            }
            else if let error = error {
                completion(.failure(error))
                return
            }
        })
    }
    
    func getChapters(for manga: Manga, completion: @escaping (Result<[Chapter], Error>) -> Void) {
        let query = store.collection("manga").document(manga.id)
        let chapterCount = manga.chapterCount
        
        var chapters: [Chapter] = []
        
        for chapterIndex in 0..<chapterCount {
            let chapterId = "ch\(chapterIndex + 1)"
            query.collection(chapterId).document("info").getDocument(as: Chapter.self, completion: { result in
                switch result {
                case .success(var chapter):
                    // Manually set id and order since this is async
                    chapter.id = chapterId
                    chapter.sortOder = chapterIndex
                    chapters.append(chapter)
                    
                    if chapters.count == chapterCount {
                        completion(.success(chapters.sorted(by: { $0.sortOder < $1.sortOder })))
                    }
                case .failure:
                    break
                }
            })
        }
    }
    
}
