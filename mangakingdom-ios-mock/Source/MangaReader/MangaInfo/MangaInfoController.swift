//
//  MangaInfoController.swift
//  mangakingdom-ios-mock
//
//  Created by Kim Cortez on 5/27/22.
//

import UIKit

class MangaInfoController: UIViewController {

    var coverImageView: UIImageView = UIImageView()
    var titleLabel: UILabel = UILabel()
    var authorLabel: UILabel = UILabel()
    var descriptionLabel: UILabel = UILabel()
    var likesLabel: UILabel = UILabel()
    var scrollView: UIScrollView = UIScrollView()
    var scrollContentView: UIView = UIView()
    
    var presenter: MangaInfoPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setUIValues()
    }
    
    private func setUIValues() {
        coverImageView.sd_setImage(with: presenter.getCoverImage())
        titleLabel.text = presenter.getTitle()
        authorLabel.text = presenter.getAuthor()
        likesLabel.text = presenter.getTotalLikes()
        descriptionLabel.text = presenter.getDescription()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        setupCoverImageView()
        setupLabels()
        setupScrollView()
        
        let mainStackView = UIStackView()
        let detailStackView = UIStackView()
        let detailStackContainerView = UIStackView()
        let topStackView = UIStackView()
        
        view.addSubview(scrollView)
        detailStackContainerView.axis = .horizontal
        detailStackContainerView.alignment = .top
        detailStackContainerView.addArrangedSubview(detailStackView)
        
        detailStackView.axis = .vertical
        detailStackView.spacing = 12.0
        detailStackView.addArrangedSubview(titleLabel)
        detailStackView.addArrangedSubview(authorLabel)
        detailStackView.addArrangedSubview(likesLabel)
        
        topStackView.axis = .horizontal
        topStackView.spacing = 16.0
        topStackView.addArrangedSubview(coverImageView)
        topStackView.addArrangedSubview(detailStackContainerView)
        
        mainStackView.axis = .vertical
        mainStackView.spacing = 16.0
        mainStackView.addArrangedSubview(topStackView)
        mainStackView.addArrangedSubview(descriptionLabel)
        
        scrollContentView.addSubview(mainStackView)
        
        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16.0)
        }
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        scrollContentView.snp.makeConstraints { make in
            make.width.equalTo(view.snp.width)
        }
    }
    
    private func setupScrollView() {
        scrollView.addSubview(scrollContentView)
        
        scrollContentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupCoverImageView() {
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.clipsToBounds = true
        
        coverImageView.snp.makeConstraints { make in
            make.width.height.equalTo(150.0)
        }
    }
    
    private func setupLabels() {
        titleLabel.numberOfLines = 0
        authorLabel.numberOfLines = 0
        descriptionLabel.numberOfLines = 0
        likesLabel.numberOfLines = 0
    }
    
}
