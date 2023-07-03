//
//  Uploader.swift
//  mangakingdom-ios-mock
//
//  Created by Kim Cortez on 5/12/22.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

class Uploader {
    static let shared = Uploader()
    
    // Fetches data from Storage then uploads to Firestore
    // Expects a structure of /manga/en/<manga_id>/<chapter_folder>/<page_image>
    // Sets the cover_image_url of manga to the first page of a chapter
    func uploadFromStorageToFirestore() {
        let store = Firestore.firestore()
        var ref = Storage.storage().reference()
        ref = ref.child("manga/en/")

        ref.listAll { result in
            switch result {
            case .success(let list):
                let mangaFolders = list.prefixes
                
                for manga in mangaFolders {
                    
                    let mangaRef = store.document("manga/\(manga.name)")
                    let data: [String: Any] = ["author": "<author>",
                                "title": "<title>",
                                "is_enabled": true,
                                "chapter_count": 0,
                                "cover_image_url": "",
                                "likes": 0]
                    mangaRef.setData(data, merge: true)
                    
                    manga.listAll { result in
                        switch result {
                        case .success(let chapterResults):
                            let chapterFolders = chapterResults.prefixes
                            mangaRef.setData(["chapter_count": chapterFolders.count], merge: true)
                            
                            for (i, chapter) in chapterFolders.enumerated() {
                                let chapterInfoRef = mangaRef.collection("ch\(i+1)").document("info")
                                
                                chapter.listAll { result in
                                    switch result {
                                    case .success(let pageResults):
                                        var pageURLS = pageResults.items.map({
                                            return "https://storage.googleapis.com/manga-dev-313513.appspot.com/\($0.fullPath)"
                                        })
                                        let cover = pageURLS.first(where: { $0.contains("cover.") }) ?? pageURLS.first ?? ""
                                        pageURLS.removeAll(where: { $0.contains("cover.") })
                                        mangaRef.setData(["cover_image_url": cover], merge: true)
                                        chapterInfoRef.setData(["page_count": pageURLS.count,
                                                                "pages": pageURLS], merge: true)
                                        
                                    case .failure:
                                        break
                                    }
                                }
                            }
                            
                        case .failure:
                            break
                        }
                    }
                }
            case .failure:
                break
            }
        }
    }
    
}
