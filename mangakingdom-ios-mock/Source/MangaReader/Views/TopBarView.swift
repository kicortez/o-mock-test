//
//  TopBarView.swift
//  mangakingdom-ios-mock
//
//  Created by Kim Cortez on 6/6/22.
//

import UIKit

class TopBarView: UIView {

    private var searchTextfield: UITextField = UITextField()
    private var searchImageView: UIImageView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        setupSearchTextfield()
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8.0
        stackView.alignment = .center
        stackView.distribution = .fill
        
        stackView.addArrangedSubview(searchImageView)
        stackView.addArrangedSubview(searchTextfield)
        
        let containerView = UIView()
        containerView.backgroundColor = .Theme.light
        containerView.addSubview(stackView)
        containerView.layer.cornerRadius = 28
        containerView.layer.borderColor = UIColor.systemGray.cgColor
        containerView.layer.borderWidth = 1.0
        
        containerView.addSubview(stackView)
        addSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        searchImageView.snp.makeConstraints { make in
            make.height.width.equalTo(24)
        }
        
        searchTextfield.snp.makeConstraints { make in
            make.height.equalTo(32)
        }
        
        stackView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(12.0)
            make.horizontalEdges.equalToSuperview().inset(24.0)
        }
    }
    
    private func setupSearchTextfield() {
        searchTextfield.borderStyle = .none
        searchTextfield.placeholder = "What are you looking for?"
    }
    
}
