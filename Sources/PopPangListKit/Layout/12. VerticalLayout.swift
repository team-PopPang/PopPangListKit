//
//  VerticalLayout.swift
//  PopPangListKit
//
//  Created by 김동현 on 7/8/26.
//

import UIKit

/// 세로 스크롤(vertical scrolling)을 지원하는 레이아웃.
///
/// Cell의 width는 CollectionView의 전체 width를 그대로 사용하고,
/// height는 content 크기에 맞게 자동으로 조정되는 경우에 적합하다.
/// 즉, 우리가 흔히 사용하는 "세로 리스트 UI"에 해당한다.
///
/// - Note:
/// 이 레이아웃을 사용할 때는 component의 layoutMode가
/// 반드시 flexibleHeight여야 정상 동작한다.
@MainActor
public struct VerticalLayout: @MainActor CompositionalLayoutSectionFactory {
    
    /// Cell 사이 간격
    private let spacing: CGFloat
    
    /// Section Padding
    private var sectionInsets: NSDirectionalEdgeInsets?
    
    /// Header sticky 여부
    private var headerPinToVisibleBounds: Bool?
    
    /// Footer sticky 여부
    private var footerPinToVisibleBounds: Bool?
    
    /// 스크롤 시 visible item 변화 감지 헨들러
    /*
     // 섹션의 항목이 표시되기 전에 수정을 할 수 있도록 각 레이아웃을 주기전에 호출되는 클로저
     // https://medium.com/@wconceptTech/compositional-layout%EC%97%90-%EB%8C%80%ED%95%B4%EC%84%9C-9b8adf182e03
    typealias NSCollectionLayoutSectionVisibleItemsInvalidationHandler
    = (
        [any NSCollectionLayoutVisibleItem], // Item
        CGPoint,                             // 현재 위치
        any NSCollectionLayoutEnvironment    // 환경
    ) -> Void
     */
    private var visibleItemsInvalidationHandler: NSCollectionLayoutSectionVisibleItemsInvalidationHandler?
    
    /// 초기화
    ///
    /// - Parameter spacing: Cell 간 간격 (기본값 0)
    public init(spacing: CGFloat = 0.0) {
        self.spacing = spacing
    }
    
    /// Section 레이아웃 생성 (핵심)
    /*
     typealias LayoutContext = (
         section: Section,
         index: Int,
         environment: NSCollectionLayoutEnvironment,
         sizeStorage: ComponentSizeStorage
     )
     
     /// 섹션 레이아웃을 생성하는 클로저 타입
     typealias SectionLayout = (
         _ context: LayoutContext
     ) -> NSCollectionLayoutSection
     */
    public func makeSectionLayout() -> SectionLayout? {
        { context -> NSCollectionLayoutSection in
            /// 새로 그룹(리스트 형태)
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: .init(
                    widthDimension: .fractionalWidth(1.0), /// width는 전체 채움
                    heightDimension: .estimated(           /// height는 content 기반 (estimated)
                        context.environment.container.contentSize.height
                    )
                ),
                /// 각 cell들을 그대로 세로로 쌓음
                subitems: layoutCellItems(
                    cells: context.section.cells,
                    sizeStorage: context.sizeStorage
                )
            )
            
            /// cell 간 간격
            group.interItemSpacing = .fixed(spacing)
            
            /// section 생성
            let section = NSCollectionLayoutSection(group: group)
            
            /// inset 적용
            if let sectionInsets {
                section.contentInsets = sectionInsets
            }
            
            /// visible item 변화 감지
            if let visibleItemsInvalidationHandler {
                section.visibleItemsInvalidationHandler = visibleItemsInvalidationHandler
            }
            
            /// header 생성
            let headerItem = layoutHeaderItem(
                section: context.section,
                sizeStorage: context.sizeStorage
            )
            
            /// header sticky
            if let headerPinToVisibleBounds {
                headerItem?.pinToVisibleBounds = headerPinToVisibleBounds
            }
            
            /// footer 생성
            let footerItem = layoutFooterItem(
                section: context.section,
                sizeStorage: context.sizeStorage
            )
            
            /// footer sticky
            if let footerPinToVisibleBounds {
                footerItem?.pinToVisibleBounds = footerPinToVisibleBounds
            }
            
            /// header + footer 등록
            section.boundarySupplementaryItems = [
                headerItem,
                footerItem
            ].compactMap { $0 }
            
            return section
        }
    }
}

// MARK: - Modifier
extension VerticalLayout {
    
    /// section inset 설정
    public func insets(_ insets: NSDirectionalEdgeInsets?) -> Self {
        var copy = self
        copy.sectionInsets = insets
        return copy
    }
    
    /// header sticky 설정
    public func headerPinToVisibleBounds(_ pinToVisibleBounds: Bool?) -> Self {
        var copy = self
        copy.headerPinToVisibleBounds = pinToVisibleBounds
        return copy
    }
    
    /// footer sticky 설정
    public func footerPinToVisibleBounds(_ pinToVisibleBounds: Bool?) -> Self {
        var copy = self
        copy.footerPinToVisibleBounds = pinToVisibleBounds
        return copy
    }
    
    /// visible item 변화 감지 핸들러 설정
    public func withVisibleItemsInvalidationHandler(
        _ handler: NSCollectionLayoutSectionVisibleItemsInvalidationHandler?
    ) -> Self {
        var copy = self
        copy.visibleItemsInvalidationHandler = handler
        return copy
    }
}
