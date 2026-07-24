//
//  CompositionalLayoutSectionFactory.swift
//  PopPangListKitTests
//
//  Created by 김동현 on 7/7/26.
//

import UIKit

/// 섹션의 레이아웃을 생성하고 반환하는 프로토콜
///
/// 이 프로토콜을 채택한 타입은 `NSCollectionLayoutSection`을 생성하는 책임을 가진다.
/// 또한 Cell과 ReusableView의 사이즈를 계산하는 기본 구현을 제공한다.
public protocol CompositionalLayoutSectionFactory {
    
    /// 레이아웃 생성에 필요한 컨텍스트 타입
    /// section, index, layout 환경, 사이즈 저장소를 포함한다.
    /// `ComponentSizeStorage`는 컴포넌트의 실제 사이즈를 캐싱한다.
    ///  NSCollectionLayoutEnvironment: (컨테이너 크기, 다크모드 등)
    ///  ComponentSizeStorage: 사이즈 캐시
    typealias LayoutContext = (
        section: Section,
        index: Int,
        environment: NSCollectionLayoutEnvironment,
        sizeStorage: ComponentSizeStorage
    )
    
    /// 섹션 레이아웃을 생성하는 클로저 타입
    typealias SectionLayout = (
        _ context: LayoutContext
    ) -> NSCollectionLayoutSection?
    
    /// 섹션 레이아웃 생성
    ///
    /// - Returns: 섹션 레이아웃 클로저
    func makeSectionLayout() -> SectionLayout?
    
    /// 셀 레이아웃 아이템 생성
    ///
    /// - Parameters:
    ///   - cells: 사이즈 계산 대상 셀
    ///   - sizeStorage: 셀 사이즈 캐시 저장소
    /// - Returns: NSCollectionLayoutItem 배열
    func layoutCellItems(
        cells: [Cell],
        sizeStorage: ComponentSizeStorage
    ) -> [NSCollectionLayoutItem]
    
    /// 헤더 레이아웃 생성
    ///
    /// - Parameters:
    ///   - section: 헤더가 포함된 섹션
    ///   - sizeStorage: 헤더 사이즈 캐시
    /// - Returns: 헤더 레이아웃 아이템
    func layoutHeaderItem(
        section: Section,
        sizeStorage: ComponentSizeStorage
    ) -> NSCollectionLayoutBoundarySupplementaryItem?
    
    /// 푸터 레이아웃 생성
    ///
    /// - Parameters:
    ///   - section: 푸터가 포함된 섹션
    ///   - sizeStorage: 푸터 사이즈 캐시
    /// - Returns: 푸터 레이아웃 아이템
    func layoutFooterItem(
        section: Section,
        sizeStorage: ComponentSizeStorage
    ) -> NSCollectionLayoutBoundarySupplementaryItem?
}

@MainActor
extension CompositionalLayoutSectionFactory {
    
    /// `ContentLayoutMode`를 `NSCollectionLayoutSize`로 변환합니다.
    ///
    /// 이 버전은 "실제 size를 아직 모를 때" 사용합니다.
    /// 즉, estimated 값만 가지고 layout size를 만듭니다.
    ///
    /// 각 모드 의미:
    ///
    /// - `.fitContainer`
    ///   부모 컨테이너 크기에 맞춰 꽉 차게 만듭니다.
    ///   width/height 모두 fractional 값 사용
    ///
    /// - `.flexibleWidth(estimatedWidth)`
    ///   높이는 부모 기준으로 꽉 차고,
    ///   너비는 estimated width를 사용합니다.
    ///
    /// - `.flexibleHeight(estimatedHeight)`
    ///   너비는 부모 기준으로 꽉 차고,
    ///   높이는 estimated height를 사용합니다.
    ///
    /// - `.fitContent(estimatedSize)`
    ///   width/height 모두 content 기준으로 잡되,
    ///   아직 실제 값을 모르므로 estimated size를 사용합니다.
    ///
    /// - Parameter mode: 컴포넌트의 레이아웃 모드
    /// - Returns: compositional layout size
    private func makeLayoutSize(
        mode: ContentLayoutMode
    ) -> NSCollectionLayoutSize {
        switch mode {
        case .fitContainer:
            return .init(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
        case .flexibleWidth(let estimatedWidth):
            return .init(
                widthDimension: .estimated(estimatedWidth),
                heightDimension: .fractionalHeight(1.0)
            )
        case .flexibleHeight(let estimatedHeight):
            return .init(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(estimatedHeight)
            )
        case .fitContent(let estimatedSize):
            return .init(
                widthDimension: .estimated(estimatedSize.width),
                heightDimension: .estimated(estimatedSize.height)
            )
        }
    }
    
    /// `ContentLayoutMode`와 실제 측정된 `CGSize`를 바탕으로
    /// `NSCollectionLayoutSize`를 생성합니다.
    ///
    /// 이 버전은 "이미 실제 size를 알고 있을 때" 사용합니다.
    /// 즉, sizeStorage에 들어 있는 측정 결과를 반영할 때 사용됩니다.
    ///
    /// 주의할 점은,
    /// mode에 따라 실제 size를 전부 쓰는 것이 아니라
    /// 필요한 축만 실제 size를 사용한다는 점입니다.
    ///
    /// 예를 들어:
    /// - `flexibleWidth`면 width만 실제 size.width를 사용
    /// - `flexibleHeight`면 height만 실제 size.height를 사용
    /// - `fitContainer`는 애초에 부모 기준이라 실제 size를 써도 의미가 없으므로 무시
    ///
    /// - Parameters:
    ///   - mode: 컴포넌트의 레이아웃 모드
    ///   - size: 실제 측정된 size
    ///
    /// - Returns: 실제 size가 반영된 compositional layout size
    private func makeLayoutSize(
        mode: ContentLayoutMode,
        size: CGSize
    ) -> NSCollectionLayoutSize {
        switch mode {
        case .fitContainer:
            return .init(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
        case .flexibleWidth:
            return .init(
                widthDimension: .estimated(size.width),
                heightDimension: .fractionalHeight(1.0)
            )
        case .flexibleHeight:
            return .init(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(size.height)
            )
        case .fitContent:
            return .init(
                widthDimension: .estimated(size.width),
                heightDimension: .estimated(size.height)
            )
        }
    }
}

@MainActor
extension CompositionalLayoutSectionFactory {
    
    /// 셀 레이아웃 기본 구현
    ///
    /// 캐시된 사이즈가 존재하고 Item이 동일하면 실제 사이즈를 사용한다.
    /// 그렇지 않으면 estimated 사이즈를 사용한다.
    public func layoutCellItems(
        cells: [Cell],
        sizeStorage: ComponentSizeStorage
    ) -> [NSCollectionLayoutItem] {
        cells.map {
            if let sizeContext = sizeStorage.cellSize(for: $0.internalIdentity),
               sizeContext.item == $0.component.item {
                return NSCollectionLayoutItem(
                    layoutSize: makeLayoutSize(
                        mode: $0.component.layoutMode,
                        size: sizeContext.size
                    )
                )
            } else {
                return NSCollectionLayoutItem(
                    layoutSize: makeLayoutSize(
                        mode: $0.component.layoutMode)
                )
            }
        }
    }
    
    /// 헤더 레이아웃 기본 구현
    ///
    /// 캐시된 사이즈와 ViewModel이 동일하면 실제 사이즈 사용
    /// 아니면 estimated 사이즈 사용
    public func layoutHeaderItem(
        section: Section,
        sizeStorage: ComponentSizeStorage
    ) -> NSCollectionLayoutBoundarySupplementaryItem? {
        guard let header = section.header else {
            return nil
        }
        
        if let sizeContext = sizeStorage.headerSize(for: section.id),
            sizeContext.item == header.component.item {
                return NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: makeLayoutSize(
                        mode: header.component.layoutMode,
                        size: sizeContext.size
                    ),
                    elementKind: header.kind,
                    alignment: header.alignment
                )
        } else {
            return NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: makeLayoutSize(
                    mode: header.component.layoutMode
                ),
                elementKind: header.kind,
                alignment: header.alignment
            )
        }
    }
    
    /// 푸터 레이아웃 기본 구현
    ///
    /// 헤더와 동일한 로직으로 동작
    public func layoutFooterItem(
        section: Section,
        sizeStorage: ComponentSizeStorage
    ) -> NSCollectionLayoutBoundarySupplementaryItem? {
        guard let footer = section.footer else {
            return nil
        }
        
        if let sizeContext = sizeStorage.footerSize(for: section.id),
           sizeContext.item == footer.component.item {
            return NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: makeLayoutSize(
                    mode: footer.component.layoutMode,
                    size: sizeContext.size
                ),
                elementKind: footer.kind,
                alignment: footer.alignment
            )
        } else {
            return NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: makeLayoutSize(
                    mode: footer.component.layoutMode
                ),
                elementKind: footer.kind,
                alignment: footer.alignment
            )
        }
    }
}
