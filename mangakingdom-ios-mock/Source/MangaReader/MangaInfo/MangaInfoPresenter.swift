//
//  MangaInfoPresenter.swift
//  mangakingdom-ios-mock
//
//  Created by Kim Cortez on 5/27/22.
//

import Foundation

class MangaInfoPresenter {
    
    private let manga: Manga
    
    init(manga: Manga) {
        self.manga = manga
    }
    
    func getTitle() -> String {
        return manga.title
    }
    
    func getAuthor() -> String {
        return manga.author
    }
    
    func getCoverImage() -> URL {
        return manga.coverImageUrl
    }
    
    func getTotalLikes() -> String {
        // return String(manga.likes)
        return String(Int.random(in: 1000...100000)) + " likes"
    }
    
    func getDescription() -> String {
        return "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur vitae diam ultrices, venenatis neque et, ornare sapien. Cras dui augue, hendrerit ut placerat sed, pharetra id est. Integer tristique ipsum ac urna porttitor, ac rutrum dui condimentum. Etiam pulvinar mi sodales, placerat massa at, commodo purus. Quisque viverra enim a mi tincidunt, pretium bibendum purus tempor. Integer malesuada tortor leo, tristique tristique tortor tincidunt lobortis. Donec in dolor sed dolor luctus vehicula quis tristique ex. Pellentesque ac lorem eu nibh ullamcorper scelerisque sed in lectus. Nulla et bibendum ligula."
    }
    
}
