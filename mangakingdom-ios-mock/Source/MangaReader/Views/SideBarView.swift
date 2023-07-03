//
//  SideBarView.swift
//  mangakingdom-ios-mock
//
//  Created by Kim Cortez on 5/24/22.
//

import Foundation
import UIKit

protocol SideBarViewDelegate: AnyObject {
    func sideBarViewDidTapInfo(_ view: SideBarView)
    func sideBarViewDidTapLike(_ view: SideBarView)
    func sideBarViewDidTapShare(_ view: SideBarView)
    func sideBarViewDidTapComment(_ view: SideBarView)
}

struct SideBarConfig {
    var isLiked: Bool = false
    var infoImageURL: URL?
}

class SideBarView: UIView {
    
    var shareImageView: UIImageView!
    var likeImageView: UIImageView!
    var comentImageView: UIImageView!
    var infoImageView: UIImageView!
    
    private let iconSize: Double = 32.0
    private let sideMargin: Double = 16.0
    
    var config: SideBarConfig? {
        didSet {
            prepare(for: config)
        }
    }
    
    weak var delegate: SideBarViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        setupShareButton()
        setupLikeButton()
        setupCommentButton()
        setupInfoButton()
        
        let stackView = UIStackView()
        stackView.spacing = 16.0
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        
        stackView.addArrangedSubview(likeImageView)
        stackView.addArrangedSubview(comentImageView)
        stackView.addArrangedSubview(shareImageView)
        stackView.addArrangedSubview(infoImageView)
        
        let containerView = UIView()
        containerView.backgroundColor = .Theme.light
        containerView.addSubview(stackView)
        containerView.layer.cornerRadius = ((sideMargin * 2) + iconSize) / 2
        containerView.layer.borderColor = UIColor.systemGray.cgColor
        containerView.layer.borderWidth = 1.0
        
        addSubview(containerView)
        
        shareImageView.snp.makeConstraints { make in
            make.width.equalTo(iconSize)
            make.height.equalTo(iconSize)
        }
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(sideMargin)
        }
    }
    
    private func setupShareButton() {
        shareImageView = UIImageView(image: UIImage(systemName: "arrowshape.turn.up.right"))
        shareImageView.contentMode = .scaleAspectFill
        shareImageView.tintColor = .Theme.dark
        
        shareImageView.isUserInteractionEnabled = true
        shareImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(shareTapped)))
    }
    
    private func setupLikeButton() {
        likeImageView = UIImageView(image: UIImage(systemName: "heart"))
        likeImageView.contentMode = .scaleAspectFill
        likeImageView.tintColor = .Theme.dark
        
        likeImageView.isUserInteractionEnabled = true
        likeImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(likeTapped)))
    }
    
    private func setupCommentButton() {
        comentImageView = UIImageView(image: UIImage(systemName: "text.bubble"))
        comentImageView.contentMode = .scaleAspectFill
        comentImageView.tintColor = .Theme.dark
        
        comentImageView.isUserInteractionEnabled = true
        comentImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(commentTapped)))
    }
    
    private func setupInfoButton() {
        infoImageView = UIImageView(image: UIImage(systemName: "info.circle"))
        infoImageView.contentMode = .scaleAspectFill
        infoImageView.clipsToBounds = true
        infoImageView.tintColor = .Theme.dark
        infoImageView.layer.cornerRadius = iconSize / 2
        
        infoImageView.isUserInteractionEnabled = true
        infoImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(infoTapped)))
    }

    private func prepare(for config: SideBarConfig?) {
        guard let config = config else { return }
        
        // Info image
        infoImageView.sd_setImage(with: config.infoImageURL)
        
        // Like
        set(liked: config.isLiked)
    }
    
    @objc private func infoTapped() {
        delegate?.sideBarViewDidTapInfo(self)
    }
    
    @objc private func likeTapped() {
        delegate?.sideBarViewDidTapLike(self)
    }
    
    @objc private func shareTapped() {
        delegate?.sideBarViewDidTapShare(self)
    }
    
    @objc private func commentTapped() {
        delegate?.sideBarViewDidTapComment(self)
    }
    
    // MARK: - Public methods
    func set(liked: Bool) {
        likeImageView.image = liked ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
        likeImageView.tintColor = liked ? .Theme.accent : .Theme.dark
    }
    
}
