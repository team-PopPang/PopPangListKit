//
//  VerticalLayoutVC.swift
//  PopPangListKit
//
//  Created by 김동현 on 7/8/26.
//

import UIKit
import PopPangListKit

final class VerticalLayoutVC: UIViewController {
    private enum Const {
        static let pageSize = 100
        static let maximumViewModelCount = 10000
    }
    
    private let layoutAdapter = CollectionViewLayoutAdapter()
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(layoutAdapter: layoutAdapter)
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()
    
    private lazy var collectionViewAdapter = CollectionViewAdapter(
        configuration: CollectionViewAdapterConfiguration(
            refreshControl: .enabled(
                tintColor: .clear,
                text: "새로고침 중...",
                textColor: .white
            ),
            refreshControlAppearance: .init(
                indicator: .image(UIImage(systemName: "arrow.clockwise")!)
                    .size(22)
                    .tintColor(.systemGray)
                    .spin(duration: 0.8)
            )
        ),
        collectionView: collectionView,
        layoutAdapter: layoutAdapter
    )
    
    private var items: [VerticalLayoutComponent.Item] = [] {
        didSet {
            guard items != oldValue else { return }
            applyItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Sample Auto Layout"
        view.backgroundColor = .systemBackground
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        resetItems()
    }
    
    private func resetItems() {
        items = (0..<Const.pageSize).map { _ in .random() }
        print("✅ resetItems:", items.count)
    }
    
    private func appendItems() {
        guard items.count < Const.maximumViewModelCount else { return }
        
        let remainingCount = Const.maximumViewModelCount - items.count
        let nextCount = min(Const.pageSize, remainingCount)
        guard nextCount > 0 else { return }
        
        items.append(contentsOf: (0..<nextCount).map { _ in .random() })
        print("✅ appendItems:", items.count)
    }
}

extension VerticalLayoutVC {
    private func applyItems() {
        print("✅ applyItems:", items.count)
        let list = List {
            Section(id: "Section") {
                for item in items {
                    Cell(
                        id: item.id,
                        component: VerticalLayoutComponent(item: item)
                    )
                    .willDisplay { context in
                        let model = context.anyComponent.baseComponent.item as! VerticalLayoutComponent.Item
                        print("표시직전: \(model.title ?? "")")
                    }
                    .didEndDisplay { context in
                        let model = context.anyComponent.baseComponent.item as! VerticalLayoutComponent.Item
                        print("사라짐:  \(model.title ?? "")")
                    }
                    .onHighlight { context in
                        let model = context.anyComponent.baseComponent.item as! VerticalLayoutComponent.Item
                        print("눌림:  \(model.title ?? "")")
                    }
                    .onUnhighlight { context in
                        let model = context.anyComponent.baseComponent.item as! VerticalLayoutComponent.Item
                        print("눌림취소:  \(model.title ?? "")")
                    }
                }
            }
            .withHeader(
                SectionHeaderComponent(
                    item: .init(title: "헤더 타이틀", subtitle: "헤더 서브 타이틀")
                )
            )
            .withSectionLayout(
                DefaultCompositionalLayoutSectionFactory.vertical(spacing: 0)
                    .withSectionContentInsets(.init(top: 16, leading: 20, bottom: 8, trailing: 20))
                    .withHeaderPinToVisibleBounds(true)
            )
        }
        .onRefresh { [weak self] _ in
            self?.resetItems()
            print("새로고침!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
        }
        .onReachEnd(offsetFromEnd: .relativeToContainerSize(multiplier: 1.0)) { [weak self] _ in
            self?.appendItems()
        }
        .didEndDecelerating { _ in
            print("스크롤 감속 종료")
        }
        
        collectionViewAdapter.apply(list)
    }
}
