//
//  CompositionalLayoutSectionFactory.swift
//  PopPangListKitTests
//
//  Created by 김동현 on 7/7/26.
//

import UIKit

public protocol CompositionalLayoutSectionFactory {
    
    typealias LayoutContext = (
        section: Section,
        index: Int,
        enviroment: NSCollectionLayoutEnvironment
    )
    
    typealias SectionLayout = (
        _ context: LayoutContext
    ) -> NSCollectionLayoutSection
    
    func makeSectionLayout() -> SectionLayout?
    
    func layoutCellItems(
        cells: [Cell],
        sizeStorage: ComponentSizeStorage
    ) -> [NSCollectionLayoutItem]
    
    func layoutHeaderItem(
        section: [Section],
        sizeStorage: ComponentSizeStorage
    ) -> NSCollectionLayoutBoundarySupplementaryItem?
    
    func layoutFooterItem(
        section: [Section],
        sizeStorage: ComponentSizeStorage
    ) -> NSCollectionLayoutBoundarySupplementaryItem?
}

extension CompositionalLayoutSectionFactory {
    
}
