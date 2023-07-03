//
//  HomeController.swift
//  mangakingdom-ios-mock
//
//  Created by Kim Cortez on 5/24/22.
//

import UIKit
import SnapKit

class HomeController: UIViewController {

    let containerView: UIView = UIView()
    let bottomBarContainerView: UIView = UIView()
    let topBarContainerView: UIView = UIView()
    let bottomBarView: BottomBarView = BottomBarView(frame: .zero)
    let topBarView: TopBarView = TopBarView(frame: .zero)
    
    var mangaBrowserController: MangaBrowserController!
    var mangaCollectionController: MangaCollectionController!
    
    private var bottomBarBottomConstraint: ConstraintMakerFinalizable!
    private var topBarTopConstraint: ConstraintMakerFinalizable!
    private var isBottomBarShown = true
    private var isHidingBottomBar = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNotifications()
        setupUI()
        setupTabControllers()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(containerView)
        view.addSubview(bottomBarContainerView)
        view.addSubview(topBarContainerView)
        
        setupBottomBar()
        setupTopBarView()
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        bottomBarContainerView.snp.makeConstraints { make in
            make.centerX.equalTo(view.snp.centerX)
            make.bottom.equalTo(view.snp.bottom)
        }
        
        topBarContainerView.snp.makeConstraints { make in
            make.centerX.equalTo(view.snp.centerX)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(8.0)
            make.height.equalTo(topBarView.snp.height)
        }
    }
    
    private func setupBottomBar() {
        bottomBarContainerView.addSubview(bottomBarView)
        bottomBarContainerView.backgroundColor = .clear
        
        bottomBarView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            bottomBarBottomConstraint = make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(8.0).priority(.high)
            make.top.equalTo(bottomBarContainerView.snp.bottom).priority(.medium)
        }
    }
    
    private func setupTopBarView() {
        topBarContainerView.addSubview(topBarView)
        topBarContainerView.backgroundColor = .clear
        
        topBarView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
             make.top.equalToSuperview().priority(.medium)
            topBarTopConstraint = make.bottom.equalTo(view.snp.top).priority(.low)
        }
    }
    
    private func setupTabControllers() {
        mangaBrowserController = MangaBrowserController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        mangaBrowserController.readerDataSource = self
        
        mangaCollectionController = MangaCollectionController()
        mangaCollectionController.readerDatasource = self
        
        add(asChild: mangaBrowserController, container: containerView)
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(mangaTapped),
                                               name: .MangaTappedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(mangaScrolled),
                                               name: .MangaScrolledNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(forceShowBars),
                                               name: .ForceShowBarsNotification, object: nil)
    }
    
    @objc private func mangaTapped() {
        view.endEditing(true)
        toggleBottomBar(displayed: !isBottomBarShown)
    }
    
    @objc private func mangaScrolled() {
        guard isBottomBarShown else { return }
        toggleBottomBar(displayed: false)
    }
    
    @objc private func forceShowBars() {
        toggleBottomBar(displayed: true, forced: true)
    }
    
    private func toggleBottomBar(displayed: Bool, forced: Bool = false) {
        guard !isHidingBottomBar || forced else { return }
        
        bottomBarBottomConstraint.constraint.update(priority: displayed ? .high : .low)
        topBarTopConstraint.constraint.update(priority: displayed ? .low : .high)
        isBottomBarShown = displayed
        
        if displayed {
            NotificationCenter.default.post(name: .BottomBarDisplayedNotification, object: nil)
        }
        else {
            NotificationCenter.default.post(name: .BottomBarHiddenNotification, object: nil)
        }
        
        isHidingBottomBar = true
        UIView.animate(withDuration: 0.25) {
            self.bottomBarContainerView.layoutIfNeeded()
            self.topBarContainerView.layoutIfNeeded()
        } completion: { _ in
            self.isHidingBottomBar = false
        }
    }

}

extension HomeController: MangaReaderControllerDataSource {
    func mangaReaderControllerSideBarShown() -> Bool {
        return isBottomBarShown
    }
}

extension HomeController: MangaCollectionControllerDataSource {
    func mangaCollectionControllerShouldShowSidebar() -> Bool {
        return isBottomBarShown
    }
}
