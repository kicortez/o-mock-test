//
//  MangaPageController.swift
//  mangakingdom-ios-mock
//
//  Created by Kim Cortez on 5/5/22.
//

import UIKit
import SDWebImage

struct PageInfo {
    var imageSource: URL!
    var page: Int!
    var chapter: String!
}

class MangaPageController: UIViewController {

    var imageView: UIImageView!
    
    var pageInfo: PageInfo!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    private func setupUI() {
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .systemBackground
        imageView.sd_setImage(with: pageInfo.imageSource)
        
        view.addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

}
