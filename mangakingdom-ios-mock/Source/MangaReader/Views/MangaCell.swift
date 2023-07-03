//
//  MangaCell.swift
//  mangakingdom-ios-mock
//
//  Created by Kim Cortez on 5/28/22.
//

import UIKit
import SnapKit
import Combine

class MangaCell: UICollectionViewCell {

    let imageView = UIImageView()
    let sideBarView = SideBarView()
    let sideBarContainerView = UIView()
    
    var hidesSidebar = true
    
    private var sidebarTrailingConstraint: ConstraintMakerFinalizable!
    private var isHidingSideBar = false
    
    private var cancellables = Set<AnyCancellable>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
    }
    
    private func setup() {
        setupUI()
        setupNotifications()
    }
    
    private func setupUI() {
        setupSidebar()
        
        imageView.contentMode = .scaleAspectFit
        contentView.addSubview(imageView)
        contentView.addSubview(sideBarContainerView)
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        sideBarContainerView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.bottom.equalTo(contentView.snp.bottom).inset(100)
        }
    }
    
    private func setupSidebar() {
        sideBarContainerView.addSubview(sideBarView)
        sideBarContainerView.backgroundColor = .clear
        
        sideBarView.snp.makeConstraints { make in
            sidebarTrailingConstraint = make.trailing.equalToSuperview().inset(16).priority(.high)
            make.leading.equalTo(sideBarContainerView.snp.trailing).priority(.medium)
            make.verticalEdges.equalToSuperview()
        }
        
        sideBarContainerView.snp.makeConstraints { make in
            make.width.equalTo(sideBarView.snp.width)
        }
    }
    
    func toggleSideBar(displayed: Bool, animated: Bool = true) {
        func completeToggle(show: Bool) {
            self.sideBarContainerView.alpha = show ? 1.0 : 0.0
            self.sideBarContainerView.layoutIfNeeded()
        }
        
        guard hidesSidebar else {
            sidebarTrailingConstraint.constraint.update(priority: .high)
            completeToggle(show: true)
            return
        }
        
        guard !isHidingSideBar else { return }
        
        sidebarTrailingConstraint.constraint.update(priority: displayed ? .high : .low)
        
        guard animated else {
            completeToggle(show: displayed)
            return
        }
        
        isHidingSideBar = true
        UIView.animate(withDuration: 0.25) {
            completeToggle(show: displayed)
        } completion: { _ in
            self.isHidingSideBar = false
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
        hidesSidebar = true
        toggleSideBar(displayed: true, animated: false)
    }
    
    private func setupNotifications() {
        NotificationCenter.default
            .publisher(for: .BottomBarHiddenNotification)
            .sink { notif in
                self.toggleSideBar(displayed: false)
            }
            .store(in: &cancellables)
        
        NotificationCenter.default
            .publisher(for: .BottomBarDisplayedNotification)
            .sink { notif in
                self.toggleSideBar(displayed: true)
            }
            .store(in: &cancellables)
    }
    
}
