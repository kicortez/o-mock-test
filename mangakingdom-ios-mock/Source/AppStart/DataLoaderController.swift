//
//  DataLoaderController.swift
//  mangakingdom-ios-mock
//
//  Created by Kim Cortez on 5/14/22.
//

import UIKit
import Combine
import FirebaseAuth
import SDWebImage

class DataLoaderController: UIViewController {

    private var cancellables = Set<AnyCancellable>()
    
    @Published var minimumDataLoadFinished: Bool = false
    
    private var minCoverCountFetched = false
    private var minPageCountFetched = false
    private var prefetchingStarted = false
    private var mangaInfoFetched = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupSubscribers()
        authAndFetch()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        let imageView = UIImageView(image: UIImage(named: "ic_logo"))
        imageView.contentMode = .scaleAspectFit
        
        view.addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(150)
        }
    }
    
    private func setupSubscribers() {
        MangaManager.shared
            .mangaPublisher
            .sink { completion in
                self.proceedIfSufficientData()
            } receiveValue: { manga in
                guard manga.count > 0 else { return }
                guard !self.prefetchingStarted else { return }
                
                self.prefetchingStarted = true
                
                // Prefetch covers
                MangaPrefetcher.shared.fetchCovers(for: manga) { [weak self] in
                    self?.minCoverCountFetched = true
                    self?.proceedIfSufficientData()
                }
                
                // Prefetch pages from first chapter of each manga
                let pageLimit = 2

                var pagesForFetching: [URL] = []
                for item in manga {
                    if let chapter = item.chapters.first {
                        let pages = chapter.pages
                        let toFetch = pages[0...min(pageLimit, chapter.pageCount - 1)].map({ $0.url })
                        pagesForFetching.append(contentsOf: toFetch)
                    }
                }
                
                MangaPrefetcher.shared.fetchPages(pagesForFetching) {
                    self.minPageCountFetched = true
                    self.proceedIfSufficientData()
                }
            }
            .store(in: &self.cancellables)
    }
    
    private func authAndFetch() {
        SDWebImagePrefetcher.shared.maxConcurrentPrefetchCount = 50
        
        UserManager.shared.login { result in
            MangaManager.shared.getManga()
            
            UserMangaManager.shared.userMangaInfo(for: UserManager.shared.userId ?? "") { result in
                self.mangaInfoFetched = true
            }
        }
    }
    
    private func proceedIfSufficientData() {
        guard isViewLoaded else { return }
        guard !MangaManager.shared.mangaCollection.isEmpty else { return }
        guard !minimumDataLoadFinished else { return }
        
        minimumDataLoadFinished = minCoverCountFetched && minPageCountFetched && mangaInfoFetched
    }
    
}
