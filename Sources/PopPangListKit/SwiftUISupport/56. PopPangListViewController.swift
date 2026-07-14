//
//  PopPangListViewController.swift
//  PopPangListKit
//
//  Created by 김동현 on 7/11/26.
//

import UIKit

@MainActor
final class PopPangListViewController: UIViewController {
    private let layoutAdapter: CollectionViewLayoutAdapter
    let collectionView: UICollectionView
    private let adapter: CollectionViewAdapter
    
    init(
        configuration: CollectionViewAdapterConfiguration,
        prefetchingPlugins: [CollectionViewPrefetchingPlugin]
    ) {
        let layoutAdapter = CollectionViewLayoutAdapter()
        let collectionView = UICollectionView(layoutAdapter: layoutAdapter)
        
        self.layoutAdapter = layoutAdapter
        self.collectionView = collectionView
        self.adapter = CollectionViewAdapter(
            configuration: configuration,
            collectionView: collectionView,
            layoutAdapter: layoutAdapter,
            prefetchingPlugins: prefetchingPlugins
        )
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    func apply(_ list: List) {
        loadViewIfNeeded()
        adapter.apply(list)
    }
}

extension PopPangListViewController: PopPangListScrollControlling {
    func scrollToTop(animated: Bool) -> Bool {
        adapter.scrollToTop(animated: animated)
    }

    func scrollToSection(
        id: AnyHashable,
        position: PopPangListScrollPosition,
        animated: Bool
    ) -> Bool {
        adapter.scrollToSection(
            id: id,
            position: position,
            animated: animated
        )
    }
}
