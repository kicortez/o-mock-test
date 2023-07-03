//
//  MangaReaderController.swift
//  mangakingdom-ios-mock
//
//  Created by Kim Cortez on 5/4/22.
//

import UIKit
import SnapKit

protocol MangaReaderControllerDataSource: AnyObject {
    func mangaReaderControllerSideBarShown() -> Bool
}

class MangaReaderController: UIPageViewController {
    
    var manga: Manga!
    var currentPage = -1
    var currentChapter: Chapter?
    
    private let progressView = UIProgressView()
    private let sideBarView = SideBarView()
    private let sideBarContainerView = UIView()
    private let continueReadingView = UIView()
    private var isHidingSideBar = false
    
    private var sidebarTrailingConstraint: ConstraintMakerFinalizable!
    
    private var isLiked = false
    private var isCoverPage: Bool {
        return currentPage < 0
    }
    
    weak var readerDataSource: MangaReaderControllerDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        isLiked = UserMangaManager.shared.mangaInfo(for: manga)?.liked ?? false
        currentChapter = manga.chapters.first
        
        setupNotifications()
        setupUI()
        
        let pageInfo = PageInfo(imageSource: manga.coverImageUrl, page: currentPage, chapter: currentChapter?.id ?? "")
        let controller = pageController(with: pageInfo)
        
        MangaPrefetcher.shared.fetchPages(for: currentChapter!, from: 0, limit: 5) {
            
        }
        
        setViewControllers([controller], direction: .forward, animated: false, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshSidebar(forceDisplay: isCoverPage, forced: isCoverPage)
        
        if isCoverPage {
            NotificationCenter.default.post(name: .ForceShowBarsNotification, object: nil)
            progressView.isHidden = true
        }
    }
    
    private func setupUI() {
        setupProgressView()
        setupSidebar()
        setupScrollView()
        setupContinueReadingButton()
    }
    
    private func setupProgressView() {
        progressView.isHidden = true
        progressView.progress = 0.0
        progressView.trackTintColor = .Theme.dark
        progressView.progressTintColor = .Theme.accent
        
        view.addSubview(progressView)
        view.addSubview(sideBarContainerView)
        
        progressView.snp.makeConstraints { make in
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            make.horizontalEdges.equalToSuperview().inset(8.0)
        }
        
        sideBarContainerView.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(68.0)
        }
    }
    
    private func setupSidebar() {
        sideBarContainerView.addSubview(sideBarView)
        sideBarContainerView.backgroundColor = .clear
        
        sideBarView.config = SideBarConfig(isLiked: isLiked, infoImageURL: manga.coverImageUrl)
        sideBarView.delegate = self
        
        sideBarView.snp.makeConstraints { make in
            sidebarTrailingConstraint = make.trailing.equalToSuperview().inset(8.0).priority(.high)
            make.leading.equalTo(sideBarContainerView.snp.trailing).priority(.medium)
            make.verticalEdges.equalToSuperview()
        }
        
        sideBarContainerView.snp.makeConstraints { make in
            make.width.equalTo(sideBarView.snp.width)
        }
    }
    
    private func setupScrollView() {
        guard let scrollView = view.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView
        else { return }
        
        scrollView.delegate = self
    }
    
    private func setupContinueReadingButton() {
        continueReadingView.backgroundColor = UIColor.Theme.accent
        continueReadingView.layer.cornerRadius = 8.0
        
        let continueReadingButton = UIButton()
        continueReadingButton.backgroundColor = UIColor.Theme.accent
        continueReadingButton.setTitleColor(UIColor.Theme.dark, for: .normal)
        continueReadingButton.titleLabel?.numberOfLines = 0
        continueReadingButton.titleLabel?.textAlignment = .center
        
        continueReadingView.addSubview(continueReadingButton)
        
        continueReadingButton.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(16)
        }
        
        if isMangaPreviouslyRead() {
            view.addSubview(continueReadingView)
            
            continueReadingView.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(80)
            }
        }
        
        if let readInfo = UserMangaManager.shared.mangaInfo(for: manga)?.readInfo {
            let chapterId = readInfo.chapter
            let page = readInfo.page
            continueReadingButton.setTitle("Continue reading\nChapter \(chapterId); Page \(page)", for: .normal)
            
            continueReadingButton.addAction(UIAction(handler: { [weak self] action in
                self?.jumpToChapter(chapterId, page: page)
            }), for: .touchUpInside)
        }
    }
    
    private func toggleSideBar(displayed: Bool, forced: Bool) {
        guard !isHidingSideBar || forced else { return }
        
        self.sidebarTrailingConstraint.constraint.update(priority: displayed ? .high : .low)
        
        isHidingSideBar = true
        UIView.animate(withDuration: 0.25) {
            self.sideBarContainerView.layoutIfNeeded()
        } completion: { _ in
            self.isHidingSideBar = false
        }
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(mangaTapped),
                                               name: .MangaTappedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshSidebar),
                                               name: .MangaScrolledNotification, object: nil)
    }
    
    @objc private func mangaTapped() {
        refreshSidebar()
    }
    
    @objc private func refreshSidebar(forceDisplay: Bool = false, forced: Bool = false) {
        let showSidebar = (readerDataSource?.mangaReaderControllerSideBarShown() ?? true)
        toggleSideBar(displayed: showSidebar || forceDisplay, forced: forced)
    }
    
    private func pageController(with info: PageInfo) -> MangaPageController {
        let controller = MangaPageController()
        controller.pageInfo = info
        return controller
    }
    
    private func isMangaPreviouslyRead() -> Bool {
        return UserMangaManager.shared.mangaInfo(for: manga)?.readInfo != nil
    }
    
    private func jumpToChapter(_ id: String, page: Int) {
        guard let chapter = manga.chapters.first(where: { $0.id == id }) else { return }
        guard page < chapter.pages.count else { return }
        
        let pageInfo = PageInfo(imageSource: chapter.pages[page].url, page: page, chapter: chapter.id)
        let controller = self.pageController(with: pageInfo)
        setViewControllers([controller], direction: .forward, animated: true) { _ in
            self.currentPage = page
            self.currentChapter = chapter
            self.toggleProgressView()
        }
    }
    
    private func readManga() {
        guard let userId = UserManager.shared.userId else { return }
        UserMangaManager.shared.readManga(manga, info: ReadInfo(chapter: currentChapter?.id ?? "ch1", page: currentPage), userId: userId) { error in
            
        }
    }
    
    private func toggleProgressView() {
        progressView.progress = Float(max(0, currentPage + 1)) / Float(currentChapter?.pageCount ?? 1)
        progressView.isHidden = isCoverPage
        progressView.alpha = isCoverPage ? 0 : 1
    }
    
}

extension MangaReaderController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let currentId = currentChapter?.id ?? ""
        let currentChapterIndex = manga.chapters.firstIndex(where: { $0.id == currentId }) ?? Int.max
        
        guard currentChapterIndex < manga.chapters.count else { return nil }
        
        let chapterPageCount = currentChapter?.pageCount ?? 0
        
        var nextPage = currentPage + 1
        let nextChapterIndex = currentChapterIndex + 1
        var nextChapterId = currentChapter?.id ?? ""
        
        let hasNextChapter = nextChapterIndex < manga.chapters.count
        let hasNextPage = nextPage < chapterPageCount
        
        guard hasNextChapter || hasNextPage else { return nil }
        
        if hasNextChapter && !hasNextPage {
            nextChapterId = manga.chapters[nextChapterIndex].id
            nextPage = 0
        }
        
        let pageInfo = PageInfo(imageSource: currentChapter?.pages[nextPage].url,
                                page: nextPage,
                                chapter: nextChapterId)

        return pageController(with: pageInfo)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let currentId = currentChapter?.id ?? ""
        let currentChapterIndex = manga.chapters.firstIndex(where: { $0.id == currentId }) ?? Int.max
        
        guard currentChapterIndex < manga.chapters.count else { return nil }
        
        var prevPage = currentPage - 1
        let prevChapterIndex = currentChapterIndex - 1
        var prevChapterId = currentChapter?.id ?? ""
        
        let hasPrevChapter = prevChapterIndex > 0
        let hasPrevPage = prevPage > -2
        let isPrevPageFirstPage = prevPage < 0
        
        guard hasPrevChapter || hasPrevPage else { return nil }
        
        var imageSource: URL?
        
        if hasPrevChapter && !hasPrevPage {
            let prevChapter = manga.chapters[prevChapterIndex]
            prevChapterId = prevChapter.id
            prevPage = prevChapter.pageCount - 1
        }
        else if !hasPrevChapter && isPrevPageFirstPage {
            prevPage = -1
            imageSource = manga.coverImageUrl
        }
        else {
            imageSource = currentChapter?.pages[prevPage].url
        }
        
        let pageInfo = PageInfo(imageSource: imageSource, page: prevPage, chapter: prevChapterId)

        return pageController(with: pageInfo)
    }
    
}

extension MangaReaderController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let currentController = pageViewController.viewControllers?.first as? MangaPageController else { return }
        
        currentPage = currentController.pageInfo.page
        currentChapter = manga.chapters.first(where: { $0.id == currentController.pageInfo.chapter })
        
        toggleProgressView()
        continueReadingView.alpha = isCoverPage ? 1 : 0
        
        MangaPrefetcher.shared.fetchPages(for: currentChapter!, from: currentPage, limit: 5) {
            
        }
        
        if isMangaPreviouslyRead() || currentPage > 9 {
            readManga()
        }
    }
}

extension MangaReaderController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let x = scrollView.contentOffset.x
        let width = scrollView.bounds.width
        
        let diff = (x - width) / width
        
        if currentPage == 0 {
            if diff > 0 {
                let alpha = 1 - diff
                progressView.alpha = alpha
                continueReadingView.alpha = 1 - alpha
            }
        }
        
        if currentPage == -1 {
            if diff < 0 {
                let alpha = 1 + diff
                continueReadingView.alpha = alpha
            }
        }
        
        NotificationCenter.default.post(name: .MangaScrolledNotification, object: nil)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

    }
    
}

extension MangaReaderController: SideBarViewDelegate {
    func sideBarViewDidTapInfo(_ view: SideBarView) {
        let infoController = MangaInfoController()
        infoController.presenter = MangaInfoPresenter(manga: manga)
        if let sheet = infoController.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
        }
        
        present(infoController, animated: true, completion: nil)
    }
    
    func sideBarViewDidTapLike(_ view: SideBarView) {
        isLiked = !isLiked
        view.set(liked: isLiked)
        
        guard let userId = UserManager.shared.userId else { return }
        UserMangaManager.shared.likeManga(manga, isLiked: isLiked, userId: userId) { error in
            
        }
    }
    
    func sideBarViewDidTapShare(_ view: SideBarView) {
        let shareItem = manga.coverImageUrl
        let shareController = UIActivityViewController(activityItems: [shareItem], applicationActivities: nil)
        present(shareController, animated: true, completion: nil)
    }
    
    func sideBarViewDidTapComment(_ view: SideBarView) {
        let alertController = UIAlertController(title: "Oops!", message: "This is an early access feature. You can go Pro to unlock comments!", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
}
