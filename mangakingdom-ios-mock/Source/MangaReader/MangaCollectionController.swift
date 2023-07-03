//
//  MangaCollectionController.swift
//  mangakingdom-ios-mock
//
//  Created by Kim Cortez on 5/3/22.
//

import UIKit
import SnapKit

enum HomeSectionWrapper: Hashable {
    case manga(manga: Manga)
}

enum HomeItemWrapper: Hashable {
    case page(page: Page)
    case cover(manga: Manga)
}

typealias HomeDataSource = UICollectionViewDiffableDataSource<HomeSectionWrapper, HomeItemWrapper>
typealias HomeSnapshot = NSDiffableDataSourceSnapshot<HomeSectionWrapper, HomeItemWrapper>

protocol MangaCollectionControllerDataSource: AnyObject {
    func mangaCollectionControllerShouldShowSidebar() -> Bool
}

class MangaCollectionController: UIViewController {

    private lazy var dataSource: HomeDataSource = {
        let dataSource = createDataSource()
        return dataSource
    }()
    
    private var lastXOffset: CGFloat = 0
    private var collectionView: UICollectionView!
    
    weak var readerDatasource: MangaCollectionControllerDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupData()
        applySnapshot()
    }
    
    private func setupData() {
        collectionView.dataSource = dataSource
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        createUIComponents()
        
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped)))
    }
    
    private func applySnapshot() {
        var snapshot = HomeSnapshot()
        
        let manga = MangaManager.shared.mangaCollection
        for item in manga {
            snapshot.appendSections([.manga(manga: item)])
            snapshot.appendItems([.cover(manga: item)])
            for chapter in item.chapters {
                snapshot.appendItems(chapter.pages.map({ .page(page: $0) }))
            }
            
        }
        
        dataSource.apply(snapshot)
    }
    
    @objc private func viewTapped() {
        NotificationCenter.default.post(name: .MangaTappedNotification, object: nil)
    }
    
}

// Create UI
extension MangaCollectionController {
    
    private func createUIComponents() {
        createCollectionView()
    }
    
    private func createCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.register(cell: MangaCell.self)
        collectionView.isPagingEnabled = true
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.semanticContentAttribute = .forceRightToLeft
    }
    
}

// CollectionView
extension MangaCollectionController {
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIdentifier, environment in
            let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: size)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)),subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 0.0
            section.orthogonalScrollingBehavior = .paging
            section.visibleItemsInvalidationHandler =  { [weak self] visibleItems, point, environment in
                if self?.lastXOffset != point.x {
                    NotificationCenter.default.post(name: .MangaScrolledNotification, object: nil)
                    self?.lastXOffset = point.x
                }
            }
            
            return section
        }

        return layout
    }
    
    private func createDataSource() -> HomeDataSource {
        let dataSource = HomeDataSource(collectionView: collectionView) { [weak self] collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MangaCell.reuseIdentifier, for: indexPath) as! MangaCell
            
            var sideBarDisplayed = self?.readerDatasource?.mangaCollectionControllerShouldShowSidebar() ?? true
            
            switch itemIdentifier {
            case .page(let page):
                cell.imageView.sd_setImage(with: page.url)
            case .cover(let manga):
                sideBarDisplayed = true
                cell.hidesSidebar = false
                cell.imageView.sd_setImage(with: manga.coverImageUrl)
            }
            
            if let section = self?.dataSource.sectionIdentifier(for: indexPath.section) {
                switch section {
                case .manga(let manga):
                    cell.sideBarView.config = SideBarConfig(isLiked: true, infoImageURL: manga.coverImageUrl)
                }
            }
            
            cell.toggleSideBar(displayed: sideBarDisplayed, animated: false)
            
            return cell
        }
        
        return dataSource
    }
    
}
