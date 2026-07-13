//
//  HorizontalLayout.swift
//  PopPangListKit
//
//  Created by 김동현 on 7/8/26.
//

import UIKit

/// 이 레이아웃은 가로 스크롤을 지원합니다.
///
/// 셀의 너비와 높이가 모두 콘텐츠 크기에 맞게 설정되어 있다면,
/// 이 레이아웃을 가로 스크롤 UI 형태로 사용할 수 있습니다.
/// - Note: 가로 레이아웃을 사용할 때는 컴포넌트의 레이아웃 모드가 반드시 Fit Content여야 합니다.
@MainActor
public struct HorizontalLayout: @MainActor CompositionalLayoutSectionFactory {
 
    /// Cell 사이 간격
    private let spacing: CGFloat
    
    /// 섹션의 가로 스크롤 동작 방식 (예: continuous, paging 등)
    private let scrollingBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior
    
    /// Section Padding
    private var sectionInsets: NSDirectionalEdgeInsets?
    
    /// Header sticky 여부
    private var headerPinToVisibleBounds: Bool?
    
    /// Footer sticky 여부
    private var footerPinToVisibleBounds: Bool?
    
    /// 스크롤 시 visible item 변화 감지 헨들러
    private var visibleItemsInvalidationHandler: NSCollectionLayoutSectionVisibleItemsInvalidationHandler?
    
    /// 새로운 가로 레이아웃을 초기화합니다.
    /// - Parameters:
    ///   - spacing: 아이템 간 간격 (기본값: 0.0)
    ///   - scrollingBehavior: 스크롤 동작 방식 (기본값: .continuous)
    public init(
        spacing: CGFloat = 0.0,
        scrollingBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior = .continuous
    ) {
        self.spacing = spacing
        self.scrollingBehavior = scrollingBehavior
    }
    
    /// 섹션에 대한 레이아웃을 생성합니다.
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
        { context -> NSCollectionLayoutSection? in
            
            /// 가로 방향 그룹 생성
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: .init(
                    /// 컨테이너 크기를 기준으로 "추정 너비"설정(동적 콘텐츠 대응)
                    widthDimension: .estimated(context.environment.container.contentSize.width),
                    /// 컨테이너 크기를 기준으로 "추정 높이" 설정
                    heightDimension: .estimated(context.environment.container.contentSize.height)
                ),
                subitems: layoutCellItems(
                    cells: context.section.cells,
                    sizeStorage: context.sizeStorage
                )
            )
            
            /// 아이템 간 간격 설정
            group.interItemSpacing = .fixed(spacing)
            
            /// 섹션 설정
            let section = NSCollectionLayoutSection(group: group)
            
            /// 섹션 inset 적용
            if let sectionInsets {
                section.contentInsets = sectionInsets
            }
            
            /// visible item 변화 시 처리 로직 설정
            if let visibleItemsInvalidationHandler {
                section.visibleItemsInvalidationHandler = visibleItemsInvalidationHandler
            }
            
            /// 가로 스크롤 활성화
            section.orthogonalScrollingBehavior = scrollingBehavior
            
            /// 헤더 생성
            let headerItem = layoutHeaderItem(
                section: context.section,
                sizeStorage: context.sizeStorage
            )
            
            /// 헤더 고정 여부 설정
            if let headerPinToVisibleBounds {
                headerItem?.pinToVisibleBounds = headerPinToVisibleBounds
            }
            
            /// 푸터 생성
            let footerItem = layoutFooterItem(
                section: context.section,
                sizeStorage: context.sizeStorage
            )
            
            /// 푸터 고정 여부 설정
            if let footerPinToVisibleBounds {
                footerItem?.pinToVisibleBounds = footerPinToVisibleBounds
            }
            
            /// 헤더 + 푸터를 섹션에 등록
            section.boundarySupplementaryItems = [
                headerItem,
                footerItem
            ].compactMap { $0 }
            
            return section
        }
    }
}

// MARK: - Modifier
extension HorizontalLayout {
    
    /// 섹션의 inset을 설정합니다.
    public func insets(_ insets: NSDirectionalEdgeInsets?) -> Self {
        var copy = self
        copy.sectionInsets = insets
        return copy
    }
    
    /// 헤더 고정 여부를 설정합니다.
    public func headerPinToVisibleBounds(_ pinToVisibleBounds: Bool?) -> Self {
        var copy = self
        copy.headerPinToVisibleBounds = pinToVisibleBounds
        return copy
    }
    
    /// 푸터 고정 여부를 설정합니다.
    public func footerPinToVisibleBounds(_ pinToVisibleBounds: Bool?) -> Self {
        var copy = self
        copy.footerPinToVisibleBounds = pinToVisibleBounds
        return copy
    }
    
    /// visible item 변경 시 실행될 핸들러를 설정합니다.
    public func withVisibleItemsInvalidationHandler(
        _ handler: NSCollectionLayoutSectionVisibleItemsInvalidationHandler?
    ) -> Self {
        var copy = self
        copy.visibleItemsInvalidationHandler = handler
        return copy
    }
}
