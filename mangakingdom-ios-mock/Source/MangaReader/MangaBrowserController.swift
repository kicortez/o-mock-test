//
//  MangaBrowserController.swift
//  mangakingdom-ios-mock
//
//  Created by Kim Cortez on 5/4/22.
//

import UIKit

class MangaBrowserController: UIPageViewController {
    
    var currentIndex = 0
    
    private let queuer = MangaQueueManager(userManga: UserMangaManager.shared.userMangaInfo.map({ $0.value }))
    
    weak var readerDataSource: MangaReaderControllerDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        setupUI()
        
        if let manga = queuer.getMangaToDisplay(at: currentIndex) {
            let controller = readerController(for: manga)
            setViewControllers([controller], direction: .forward, animated: false, completion: nil)
        }
    }
    
    private func setupUI() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped)))
    }
    
    @objc private func viewTapped() {
        NotificationCenter.default.post(name: .MangaTappedNotification, object: nil)
    }
}

extension MangaBrowserController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if currentIndex == 0 {
            return nil
        }
        
        guard let manga = queuer.getMangaToDisplay(at: currentIndex - 1) else { return nil }
        
        return readerController(for: manga)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let manga = queuer.getMangaToDisplay(at: currentIndex + 1) else { return nil }

        return readerController(for: manga)
    }
    
    private func readerController(for manga: Manga) -> MangaReaderController {
        let controller = MangaReaderController(transitionStyle: .scroll, navigationOrientation: .vertical, options: nil)
        controller.manga = manga
        controller.readerDataSource = readerDataSource
        
        return controller
    }
    
}

extension MangaBrowserController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let currentController = pageViewController.viewControllers?.first as? MangaReaderController else { return }

        currentIndex = queuer.queuedManga.firstIndex(of: currentController.manga) ?? 0

        var mangaForPrefetch = [Manga]()
        for i in currentIndex..<(currentIndex + 5) {
            if let manga = queuer.getMangaToDisplay(at: i) {
                mangaForPrefetch.append(manga)
            }
        }
    
        MangaPrefetcher.shared.fetchCovers(for: mangaForPrefetch) {

        }
    }
}
