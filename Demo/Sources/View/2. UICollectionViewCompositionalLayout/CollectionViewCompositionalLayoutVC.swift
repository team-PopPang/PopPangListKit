//
//  CollectionViewCompositionalLayoutVC.swift
//  PopPangListKit
//
//  Created by 김동현 on 7/8/26.
//

// https://developer.apple.com/documentation/uikit/uicollectionviewcompositionallayout/
// https://dev-with-precious-dreams.tistory.com/209
// https://medium.com/@geun2121/swift-compositional-layout이용해서-collectionview-구성하기-f2e611004fbe
// https://ios-development.tistory.com/945
// https://thingjin.tistory.com/entry/iOS-Compositional-Layout-으로-복잡한-CollectionView-구현-TVING-메인-뷰-클론코딩-3편
import UIKit

final class CollectionViewCompositionalLayoutVC: UIViewController {
    private enum Section: Int, CaseIterable {
        case grid
        case horizontal
        case list
    }
    
    private let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: CollectionViewCompositionalLayoutVC.makeLayout()
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Compositional Layout"
        view.backgroundColor = .systemBackground
        
        collectionView.backgroundColor = .systemBackground
        collectionView.dataSource = self
        collectionView.register(
            CompositionalCell.self,
            forCellWithReuseIdentifier: CompositionalCell.reuseIdentifier
        )
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension CollectionViewCompositionalLayoutVC {

    private static func makeLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { sectionIndex, environment in
            let section = Section(rawValue: sectionIndex)!

            switch section {
            case .grid:
                return makeGridSection()

            case .horizontal:
                return makeHorizontalSection()

            case .list:
                return makeListSection()
            }
        }
    }

    private static func makeGridSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .absolute(120)
        )

        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 8, leading: 8, bottom: 8, trailing: 8)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(120)
        )

        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            repeatingSubitem: item,
            count: 2
        )

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 16, leading: 16, bottom: 24, trailing: 16)

        return section
    }

    private static func makeHorizontalSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(180),
            heightDimension: .absolute(120)
        )

        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 8, leading: 8, bottom: 8, trailing: 8)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(180),
            heightDimension: .absolute(120)
        )

        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = .init(top: 0, leading: 16, bottom: 24, trailing: 16)

        return section
    }

    private static func makeListSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(64)
        )

        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 4, leading: 16, bottom: 4, trailing: 16)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(64)
        )

        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 0, leading: 0, bottom: 24, trailing: 0)

        return section
    }
}

extension CollectionViewCompositionalLayoutVC: UICollectionViewDataSource {

    func numberOfSections(
        in collectionView: UICollectionView
    ) -> Int {
        Section.allCases.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        switch Section(rawValue: section)! {
        case .grid:
            return 6

        case .horizontal:
            return 10

        case .list:
            return 8
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CompositionalCell.reuseIdentifier,
            for: indexPath
        ) as? CompositionalCell else {
            return UICollectionViewCell()
        }
        
        cell.configure(
            title: "Section \(indexPath.section), Item \(indexPath.item)"
        )
        return cell
    }
}

#Preview {
    CollectionViewCompositionalLayoutVC()
}
