//
//  BottomBarView.swift
//  mangakingdom-ios-mock
//
//  Created by Kim Cortez on 5/23/22.
//

import UIKit

class BottomBarView: UIView {
    
    var homeImageView: UIImageView!
    var rankingImageView: UIImageView!
    var whatsNewImageView: UIImageView!
    var profileImageView: UIImageView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        setupHomeButton()
        setupProfileButton()
        setupRankingButton()
        setupWhatsNewButton()
        
        let stackView = UIStackView()
        stackView.spacing = 32.0
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        
        stackView.addArrangedSubview(homeImageView)
        stackView.addArrangedSubview(rankingImageView)
        stackView.addArrangedSubview(whatsNewImageView)
        stackView.addArrangedSubview(profileImageView)
        
        let containerView = UIView()
        containerView.backgroundColor = .Theme.light
        containerView.addSubview(stackView)
        containerView.layer.cornerRadius = 32
        containerView.layer.borderColor = UIColor.systemGray.cgColor
        containerView.layer.borderWidth = 1.0
        
        addSubview(containerView)
        
        homeImageView.snp.makeConstraints { make in
            make.width.equalTo(32)
            make.height.equalTo(32)
        }
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16.0)
        }
    }
    
    private func setupHomeButton() {
        homeImageView = UIImageView(image: UIImage(systemName: "house"))
        homeImageView.contentMode = .scaleAspectFill
        homeImageView.tintColor = .Theme.accent
    }
    
    private func setupProfileButton() {
        profileImageView = UIImageView(image: UIImage(systemName: "person"))
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.tintColor = .Theme.dark
    }
    
    private func setupRankingButton() {
        rankingImageView = UIImageView(image: UIImage(systemName: "flame"))
        rankingImageView.contentMode = .scaleAspectFill
        rankingImageView.tintColor = .Theme.dark
    }
    
    private func setupWhatsNewButton() {
        whatsNewImageView = UIImageView(image: UIImage(systemName: "sparkles"))
        whatsNewImageView.contentMode = .scaleAspectFill
        whatsNewImageView.tintColor = .Theme.dark
    }

}
